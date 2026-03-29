import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// BASE ARCHITECTURE (do not modify)
// ---------------------------------------------------------------------------

enum RequestState { idle, loading, loaded, error, offline, empty }

typedef ResultFuture<T> = Future<Either<NetworkExceptions, T>>;

class NetworkExceptions {
  const NetworkExceptions();

  static String getErrorMessage(NetworkExceptions exception) {
    if (exception is NoInternetConnection) return 'No internet connection';
    if (exception is RequestTimeout) return 'Request timed out';
    if (exception is ServerError) return 'Internal server error';
    if (exception is BadRequest) return exception.message;
    return 'An unexpected error occurred';
  }
}

class NoInternetConnection extends NetworkExceptions {
  const NoInternetConnection();
}

class RequestTimeout extends NetworkExceptions {
  const RequestTimeout();
}

class ServerError extends NetworkExceptions {
  const ServerError();
}

class BadRequest extends NetworkExceptions {
  final String message;
  const BadRequest(this.message);
}

ResultFuture<T> execute<T>(Future<T> Function() fun) async {
  try {
    final result = await fun();
    return Right(result);
  } catch (error) {
    return const Left(ServerError());
  }
}

abstract class UseCaseWithParams<T, Params> {
  const UseCaseWithParams();
  ResultFuture<T> call(Params params);
}

class BaseResponse<T> {
  final T? data;
  final PaginationMeta? paginates;

  const BaseResponse({this.data, this.paginates});
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

RequestState handleErrorResponse(NetworkExceptions error) {
  return error is NoInternetConnection
      ? RequestState.offline
      : RequestState.error;
}

RequestState handleLoadedResponse<T>(T? result) {
  if (result is List) {
    return result.isEmpty ? RequestState.empty : RequestState.loaded;
  }
  return RequestState.loaded;
}

List<T> handlePaginationResponse<T>({
  required List<T>? result,
  required List<T> currentList,
  required int currentPage,
}) {
  if (result == null) return currentList;
  if (currentList.isEmpty || currentPage == 1) {
    return result;
  } else {
    final Set<T> uniqueItems = Set<T>.from(currentList);
    uniqueItems.addAll(result);
    return uniqueItems.toList();
  }
}

void handleScrollListener({
  required ScrollController controller,
  required Function() fun,
  required int currentPage,
  required int lastPage,
}) {
  if (controller.position.pixels == controller.position.maxScrollExtent) {
    if (lastPage > currentPage) fun();
  }
}

// ---------------------------------------------------------------------------
// DOMAIN LAYER (do not modify)
// ---------------------------------------------------------------------------

class RoomEntity extends Equatable {
  final int id;
  final String roomName;
  final String? coverUrl;
  final int visitorsCount;
  final bool isLive;

  const RoomEntity({
    required this.id,
    required this.roomName,
    this.coverUrl,
    this.visitorsCount = 0,
    this.isLive = false,
  });

  @override
  List<Object?> get props => [id, roomName, coverUrl, visitorsCount, isLive];
}

class RoomParams {
  final int page;
  final int? countryId;

  const RoomParams({required this.page, this.countryId});
}

class FetchRoomsUseCase
    extends UseCaseWithParams<BaseResponse<List<RoomEntity>>, RoomParams> {
  @override
  ResultFuture<BaseResponse<List<RoomEntity>>> call(RoomParams params) async {
    await Future.delayed(const Duration(seconds: 1));
    final rooms = List.generate(
      20,
          (i) => RoomEntity(
        id: (params.page - 1) * 20 + i,
        roomName: 'Room ${(params.page - 1) * 20 + i}',
        visitorsCount: (i + 1) * 10,
        isLive: i % 3 == 0,
      ),
    );
    return Right(BaseResponse(
      data: rooms,
      paginates: PaginationMeta(
        currentPage: params.page,
        lastPage: 5,
        total: 100,
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// EVENTS
// ---------------------------------------------------------------------------

sealed class RoomListEvent extends Equatable {
  const RoomListEvent();
  @override
  List<Object?> get props => [];
}

final class FetchRoomsEvent extends RoomListEvent {
  const FetchRoomsEvent();
}

final class LoadMoreRoomsEvent extends RoomListEvent {
  const LoadMoreRoomsEvent();
}

// ---------------------------------------------------------------------------
// STATE
// ---------------------------------------------------------------------------

class RoomListState extends Equatable {
  final RequestState status;
  final List<RoomEntity> rooms;
  final String errorMessage;
  final int currentPage;
  final int lastPage;
  final int popularIndex;
  final int globalIndex;
  final bool isLoadingMore;
  final ScrollController scrollController;

  RoomListState({
    this.status = RequestState.idle,
    this.rooms = const [],
    this.errorMessage = '',
    this.currentPage = 1,
    this.lastPage = -1,
    this.popularIndex = 0,
    this.globalIndex = 0,
    this.isLoadingMore = false,
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  RoomListState copyWith({
    RequestState? status,
    List<RoomEntity>? rooms,
    String? errorMessage,
    int? currentPage,
    int? lastPage,
    int? popularIndex,
    int? globalIndex,
    bool? isLoadingMore,
  }) {
    return RoomListState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      popularIndex: popularIndex ?? this.popularIndex,
      globalIndex: globalIndex ?? this.globalIndex,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      scrollController: scrollController,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rooms,
    errorMessage,
    currentPage,
    lastPage,
    popularIndex,
    globalIndex,
    isLoadingMore,
  ];
}

// ---------------------------------------------------------------------------
// BLOC
// ---------------------------------------------------------------------------

class RoomListBloc extends Bloc<RoomListEvent, RoomListState> {
  final FetchRoomsUseCase _fetchRoomsUC;

  RoomListBloc(this._fetchRoomsUC) : super(RoomListState()) {
    on<FetchRoomsEvent>(_onFetchRooms);
    on<LoadMoreRoomsEvent>(_onLoadMore);
  }

  Future<void> _onFetchRooms(
      FetchRoomsEvent event,
      Emitter<RoomListState> emit,
      ) async {
    emit(state.copyWith(
      status: RequestState.loading,
      errorMessage: '',
      currentPage: 1,
      lastPage: -1,
      isLoadingMore: false,
      rooms: const [],
    ));

    final result = await _fetchRoomsUC(const RoomParams(page: 1));

    result.fold(
          (left) {
        emit(state.copyWith(
          status: handleErrorResponse(left),
          errorMessage: NetworkExceptions.getErrorMessage(left),
          isLoadingMore: false,
        ));
      },
          (right) {
        final rooms = right.data ?? [];
        final pagination = right.paginates;

        emit(state.copyWith(
          status: handleLoadedResponse(rooms),
          rooms: rooms,
          currentPage: pagination?.currentPage ?? 1,
          lastPage: pagination?.lastPage ?? 1,
          errorMessage: '',
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onLoadMore(
      LoadMoreRoomsEvent event,
      Emitter<RoomListState> emit,
      ) async {
    if (state.status != RequestState.loaded) return;
    if (state.isLoadingMore) return;
    if (state.lastPage != -1 && state.currentPage >= state.lastPage) return;

    final nextPage = state.currentPage + 1;

    emit(state.copyWith(isLoadingMore: true));

    final result = await _fetchRoomsUC(RoomParams(page: nextPage));

    result.fold(
          (left) {
        emit(state.copyWith(
          isLoadingMore: false,
          errorMessage: NetworkExceptions.getErrorMessage(left),
        ));
      },
          (right) {
        final mergedRooms = handlePaginationResponse<RoomEntity>(
          result: right.data,
          currentList: state.rooms,
          currentPage: nextPage,
        );

        emit(state.copyWith(
          status: handleLoadedResponse(mergedRooms),
          rooms: mergedRooms,
          currentPage: right.paginates?.currentPage ?? nextPage,
          lastPage: right.paginates?.lastPage ?? state.lastPage,
          isLoadingMore: false,
          errorMessage: '',
        ));
      },
    );
  }
}

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  late final RoomListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RoomListBloc(FetchRoomsUseCase());
    _bloc.add(const FetchRoomsEvent());

    _bloc.state.scrollController.addListener(() {
      handleScrollListener(
        controller: _bloc.state.scrollController,
        currentPage: _bloc.state.currentPage,
        lastPage: _bloc.state.lastPage,
        fun: () {
          _bloc.add(const LoadMoreRoomsEvent());
        },
      );
    });
  }

  @override
  void dispose() {
    _bloc.state.scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: BlocBuilder<RoomListBloc, RoomListState>(
        bloc: _bloc,
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.rooms != current.rooms ||
              previous.isLoadingMore != current.isLoadingMore;
        },
        builder: (context, state) {
          switch (state.status) {
            case RequestState.idle:
            case RequestState.loading:
              return const Center(child: CircularProgressIndicator());

            case RequestState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage.isEmpty
                          ? 'Something went wrong'
                          : state.errorMessage,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(const FetchRoomsEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case RequestState.offline:
              return const Center(child: Text('No internet connection'));

            case RequestState.empty:
              return const Center(child: Text('No rooms available'));

            case RequestState.loaded:
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(const FetchRoomsEvent());
                },
                child: ListView.builder(
                  controller: state.scrollController,
                  itemCount:
                  state.rooms.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.rooms.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final room = state.rooms[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(room.isLive ? '🔴' : '⚪'),
                      ),
                      title: Text(room.roomName),
                      subtitle: Text('${room.visitorsCount} visitors'),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

// ===========================================================================
// SENIOR EXERCISE ANSWER (written answer only)
// ===========================================================================

class FetchAllDataBloc extends Bloc<dynamic, dynamic> {
  FetchAllDataBloc(
      this._fetchMyDataUC,
      this._fetchUserDataUC,
      this._initPusherUC,
      this._subscribeToChatUC,
      this._subscribeToMessagesUC,
      this._listenToBannersUC,
      this._listenToGamesUC,
      this._subscribeCounterUC,
      this._fetchConfigUC,
      this._fetchCountriesUC,
      this._updateFCMTokenUC,
      this._fetchBadgesUC,
      this._fetchLevelDataUC,
      this._initAnalyticsUC,
      this._fetchWalletUC,
      ) : super(null);

  final dynamic _fetchMyDataUC;
  final dynamic _fetchUserDataUC;
  final dynamic _initPusherUC;
  final dynamic _subscribeToChatUC;
  final dynamic _subscribeToMessagesUC;
  final dynamic _listenToBannersUC;
  final dynamic _listenToGamesUC;
  final dynamic _subscribeCounterUC;
  final dynamic _fetchConfigUC;
  final dynamic _fetchCountriesUC;
  final dynamic _updateFCMTokenUC;
  final dynamic _fetchBadgesUC;
  final dynamic _fetchLevelDataUC;
  final dynamic _initAnalyticsUC;
  final dynamic _fetchWalletUC;
}

// ===========================================================================
// Written Answer:
// The anti-pattern here is a God Bloc / Mega Bloc.
// It owns too many unrelated responsibilities such as profile, chat,
// messages, banners, games, config, analytics, wallet, FCM, and countries.
//
// Problems:
// - Violates single responsibility principle
// - Hard to test and maintain
// - Causes tight coupling between unrelated features
// - Makes debugging and state reasoning harder
// - Increases regression risk
//
// Refactor:
// Split it into smaller feature-focused blocs/cubits/services, such as:
// - ProfileCubit
// - ChatConnectionBloc
// - MessagesBloc
// - BannerCubit
// - GamesCubit
// - ConfigCubit
// - WalletCubit
// - NotificationToken service/cubit
//
// App startup can be coordinated by a lightweight AppBootstrapBloc
// or app initializer layer.
// ===========================================================================