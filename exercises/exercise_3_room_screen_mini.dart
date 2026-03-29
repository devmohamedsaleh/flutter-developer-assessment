import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// MOCK DEPENDENCIES (do not modify)
// ---------------------------------------------------------------------------

final di = _MockDI();

class _MockDI {
  T call<T>() => throw UnimplementedError('Mock DI');
}

class ZegoService {
  Stream<Map<String, dynamic>> getCommandStream() =>
      Stream.periodic(const Duration(seconds: 5), (i) => {'type': 'ping'});

  Stream<Map<String, dynamic>> getMessageStream() =>
      Stream.periodic(const Duration(seconds: 3), (i) => {'msg': 'hello $i'});

  Stream<Map<String, dynamic>> getUserJoinStream() =>
      Stream.periodic(const Duration(seconds: 10), (i) => {'user': 'user_$i'});
}

final zegoService = ZegoService();

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

// Mock BLoC classes
class RoomState extends Equatable {
  final String roomMode;
  final bool isCommentLocked;
  final List<String> messages;
  final int seatCount;
  final bool isLoading;

  const RoomState({
    this.roomMode = 'normal',
    this.isCommentLocked = false,
    this.messages = const [],
    this.seatCount = 8,
    this.isLoading = false,
  });

  RoomState copyWith({
    String? roomMode,
    bool? isCommentLocked,
    List<String>? messages,
    int? seatCount,
    bool? isLoading,
  }) =>
      RoomState(
        roomMode: roomMode ?? this.roomMode,
        isCommentLocked: isCommentLocked ?? this.isCommentLocked,
        messages: messages ?? this.messages,
        seatCount: seatCount ?? this.seatCount,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props =>
      [roomMode, isCommentLocked, messages, seatCount, isLoading];
}

class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object?> get props => [];
}

class UpdateModeEvent extends RoomEvent {
  final String mode;
  const UpdateModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class AddMessageEvent extends RoomEvent {
  final String message;
  const AddMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(const RoomState()) {
    on<UpdateModeEvent>((event, emit) {
      emit(state.copyWith(roomMode: event.mode));
    });
    on<AddMessageEvent>((event, emit) {
      emit(state.copyWith(
        messages: [...state.messages, event.message],
      ));
    });
  }
}

class BannerState extends Equatable {
  final Map<String, dynamic>? activeBanner;
  final bool isVisible;

  const BannerState({this.activeBanner, this.isVisible = false});

  BannerState copyWith({
    Map<String, dynamic>? activeBanner,
    bool? isVisible,
  }) =>
      BannerState(
        activeBanner: activeBanner ?? this.activeBanner,
        isVisible: isVisible ?? this.isVisible,
      );

  @override
  List<Object?> get props => [activeBanner, isVisible];
}

class BannerEvent extends Equatable {
  const BannerEvent();
  @override
  List<Object?> get props => [];
}

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(const BannerState());
}

// ---------------------------------------------------------------------------
// FIXED SCREEN
// ---------------------------------------------------------------------------

class RoomScreenMini extends StatefulWidget {
  final int roomId;
  final bool isLocked;

  // FIX #0 (small quality fix): const constructor reduces unnecessary rebuild cost.
  const RoomScreenMini({super.key, required this.roomId, this.isLocked = false});

  @override
  State<RoomScreenMini> createState() => _RoomScreenMiniState();
}

class _RoomScreenMiniState extends State<RoomScreenMini>
    with WidgetsBindingObserver {
  // FIX #7: Instance maps avoid shared mutable state leaking across screen instances.
  final Map<String, GlobalKey> seatKeys = {};
  final Map<int, String> seatUserIds = {};

  final RoomBloc _roomBloc = RoomBloc();
  final BannerBloc _bannerBloc = BannerBloc();

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  late final ScrollController _chatScrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatScrollController = ScrollController();

    _initializeSubscriptions();
    _loadRoomData();
  }

  void _initializeSubscriptions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _subscriptions
      // FIX #3: Subscribe to messages and forward them to the bloc so the listener has real effect.
        ..add(zegoService.getMessageStream().listen((event) {
          final msg = event['msg'];
          if (msg is String && msg.isNotEmpty) {
            _roomBloc.add(AddMessageEvent(msg));
          }
        }))
        ..add(zegoService.getCommandStream().listen(_onCommandReceived))
        ..add(zegoService.getUserJoinStream().listen(_onUserJoined));
    });
  }

  Future<void> _loadRoomData() async {
    await Future.delayed(const Duration(seconds: 2));

    // FIX #1: mounted check prevents calling setState after the widget is disposed.
    if (!mounted) return;

    setState(() {
      seatKeys.clear();
      seatUserIds.clear();
      for (int i = 0; i < 8; i++) {
        seatKeys['seat_$i'] = GlobalKey();
      }
    });
  }

  void _onCommandReceived(Map<String, dynamic> data) {
    try {
      final String type = data['type'] ?? '';
      switch (type) {
        case 'mode_change':
          _roomBloc.add(UpdateModeEvent(data['mode'] ?? 'normal'));
          break;

        case 'ban_user':
        // FIX #5: Null-safe navigator access avoids crashing when no navigator state is attached.
          final navigator = navKey.currentState;
          if (navigator != null) {
            navigator.popUntil((route) => route.isFirst);
          }
          break;

        case 'lock_comments':
          _roomBloc.add(const UpdateModeEvent('locked'));
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void _onUserJoined(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is String && user.isNotEmpty) {
      _roomBloc.add(AddMessageEvent('$user joined the room'));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FIX #8: Lifecycle override must stay synchronous; async work is delegated to a separate method.
    super.didChangeAppLifecycleState(state);
    unawaited(_handleLifecycleChange(state));
  }

  Future<void> _handleLifecycleChange(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('Camera stopped');
    } else if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('Camera resumed');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // FIX #4: Cancel all subscriptions to prevent leaks and callbacks after dispose.
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _chatScrollController.dispose();
    _roomBloc.close();
    _bannerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Room'),
              background: Container(color: Colors.purple.shade900),
            ),
          ),

          // --- Room Mode Banner ---
          SliverToBoxAdapter(
            child: BlocBuilder<RoomBloc, RoomState>(
              bloc: _roomBloc,
              // FIX #6: buildWhen limits rebuilds to room mode changes only.
              buildWhen: (prev, curr) => prev.roomMode != curr.roomMode,
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: state.roomMode == 'locked'
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  child: Text('Mode: ${state.roomMode}'),
                );
              },
            ),
          ),

          // --- Seat Grid ---
          SliverPadding(
            // FIX #2: Use a sliver grid instead of shrinkWrap GridView inside CustomScrollView to preserve lazy rendering.
            padding: const EdgeInsets.all(8),
            sliver: BlocBuilder<RoomBloc, RoomState>(
              bloc: _roomBloc,
              buildWhen: (prev, curr) => prev.seatCount != curr.seatCount,
              builder: (context, state) {
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return Container(
                        key: seatKeys['seat_$index'],
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person, color: Colors.grey),
                              const SizedBox(height: 4),
                              Text(
                                'Seat ${index + 1}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: state.seatCount,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                );
              },
            ),
          ),

          // --- Banner Section ---
          SliverToBoxAdapter(
            child: BlocBuilder<BannerBloc, BannerState>(
              bloc: _bannerBloc,
              buildWhen: (prev, curr) =>
              prev.isVisible != curr.isVisible ||
                  prev.activeBanner != curr.activeBanner,
              builder: (context, state) {
                if (!state.isVisible) return const SizedBox.shrink();
                return Container(
                  height: 60,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      state.activeBanner?['text'] ?? 'Special Event!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Chat Messages ---
          SliverToBoxAdapter(
            child: BlocBuilder<RoomBloc, RoomState>(
              bloc: _roomBloc,
              buildWhen: (prev, curr) => prev.messages != curr.messages,
              builder: (context, state) {
                return SizedBox(
                  height: 300,
                  child: ListView.separated(
                    controller: _chatScrollController,
                    itemCount: state.messages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Text(
                          state.messages[index],
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.card_giftcard),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}