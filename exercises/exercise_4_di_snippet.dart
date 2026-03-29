// =============================================================================
// EXERCISE 4: Architecture & DI — "Fix the Dependency Injection Service"
// Time: 20 minutes
// =============================================================================

// ignore_for_file: unused_field, unused_local_variable

/// Mock GetIt instance
class _GetIt {
  static final _GetIt instance = _GetIt();

  void registerSingleton<T extends Object>(T instance) {}
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {}
  void registerFactory<T extends Object>(T Function() factoryFunc,
      {String? instanceName}) {}
  T call<T extends Object>({String? instanceName}) =>
      throw UnimplementedError();
}

final di = _GetIt.instance;

// ---------------------------------------------------------------------------
// MOCK CLASSES (do not modify — just for type reference)
// ---------------------------------------------------------------------------

class DioFactory {}

class HiveManager {}

class SharedPreferences {}

// Data Sources
class HomeRemoteDataSource {
  HomeRemoteDataSource(DioFactory dio);
}

class MessagesRemoteDataSource {
  MessagesRemoteDataSource(DioFactory dio);
}

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(DioFactory dio);
}

class PusherRemoteDataSource {
  PusherRemoteDataSource(dynamic pusher);
}

// Repositories
class HomeRepository {
  HomeRepository(HomeRemoteDataSource ds);
}

class MessagesRepository {
  MessagesRepository(MessagesRemoteDataSource ds);
}

class ProfileRepository {
  ProfileRepository(ProfileRemoteDataSource ds);
}

class PusherRepository {
  PusherRepository(PusherRemoteDataSource ds);
}

// Use Cases (each takes a repository)
class FetchRoomsUC {
  FetchRoomsUC(HomeRepository repo);
}

class FetchLiveRoomsUC {
  FetchLiveRoomsUC(HomeRepository repo);
}

class CreateRoomUC {
  CreateRoomUC(HomeRepository repo);
}

class FetchMessagesUC {
  FetchMessagesUC(MessagesRepository repo);
}

class SendMessageUC {
  SendMessageUC(MessagesRepository repo);
}

class DeleteMessageUC {
  DeleteMessageUC(MessagesRepository repo);
}

class FetchUserProfileUC {
  FetchUserProfileUC(ProfileRepository repo);
}

class FetchMyProfileUC {
  FetchMyProfileUC(ProfileRepository repo);
}

class UpdateProfileUC {
  UpdateProfileUC(ProfileRepository repo);
}

class FetchGiftHistoryUC {
  FetchGiftHistoryUC(ProfileRepository repo);
}

class FetchUserBadgesUC {
  FetchUserBadgesUC(ProfileRepository repo);
}

class FetchMyBadgesUC {
  FetchMyBadgesUC(ProfileRepository repo);
}

class FetchCpProfileUC {
  FetchCpProfileUC(ProfileRepository repo);
}

class FetchUserRoomsUC {
  FetchUserRoomsUC(ProfileRepository repo);
}

class FetchSupporterUC {
  FetchSupporterUC(ProfileRepository repo);
}

class FetchUserIntroUC {
  FetchUserIntroUC(ProfileRepository repo);
}

class FetchReelsUC {
  FetchReelsUC(HomeRepository repo);
}

class LikeReelUC {
  LikeReelUC(HomeRepository repo);
}

class ShareReelUC {
  ShareReelUC(HomeRepository repo);
}

class ViewReelUC {
  ViewReelUC(HomeRepository repo);
}

class FetchMomentsUC {
  FetchMomentsUC(HomeRepository repo);
}

class InitPusherUC {
  InitPusherUC(PusherRepository repo);
}

class SubscribeChatUC {
  SubscribeChatUC(PusherRepository repo);
}

class SubscribeMessagesUC {
  SubscribeMessagesUC(PusherRepository repo);
}

class ListenToBannersUC {
  ListenToBannersUC(PusherRepository repo);
}

class ListenToGamesUC {
  ListenToGamesUC(PusherRepository repo);
}

class SubscribeCounterUC {
  SubscribeCounterUC(PusherRepository repo);
}

class FetchConfigUC {
  FetchConfigUC(HomeRepository repo);
}

class FetchCountriesUC {
  FetchCountriesUC(HomeRepository repo);
}

class UpdateFCMTokenUC {
  UpdateFCMTokenUC(ProfileRepository repo);
}

class FetchLevelDataUC {
  FetchLevelDataUC(ProfileRepository repo);
}

class InitAnalyticsUC {
  InitAnalyticsUC(HomeRepository repo);
}

class FetchWalletUC {
  FetchWalletUC(ProfileRepository repo);
}

// BLoCs
class HomeBloc {
  HomeBloc(FetchRoomsUC uc1, FetchLiveRoomsUC uc2);
}

class CreateRoomBloc {
  CreateRoomBloc(CreateRoomUC uc);
}

class MessagesBloc {
  MessagesBloc(FetchMessagesUC uc, SendMessageUC uc2);
}

class DeleteMessageBloc {
  DeleteMessageBloc(DeleteMessageUC uc);
}

class GiftHistoryBloc {
  GiftHistoryBloc({required FetchGiftHistoryUC giftHistoryUseCase});
}

class GetBadgesBloc {
  GetBadgesBloc(
      {required FetchUserBadgesUC getBadgesUseCase,
        required FetchMyBadgesUC getMyAllBadgeUC});
}

class UserBadgesBloc {
  UserBadgesBloc({required FetchUserBadgesUC uc});
}

class GetUserBadgesBloc {
  GetUserBadgesBloc({required FetchUserBadgesUC uc});
}

class CpProfileBloc {
  CpProfileBloc({required FetchCpProfileUC uc});
}

class GetUserRoomsBloc {
  GetUserRoomsBloc({required FetchUserRoomsUC uc});
}

class GetSupporterBloc {
  GetSupporterBloc({required FetchSupporterUC uc});
}

class GetUserIntroBloc {
  GetUserIntroBloc({required FetchUserIntroUC uc});
}

class GetReelsBloc {
  GetReelsBloc(FetchReelsUC uc1, LikeReelUC uc2, ShareReelUC uc3, ViewReelUC uc4);
}

class ReelViewerBloc {
  ReelViewerBloc(ViewReelUC uc);
}

class MomentBloc {
  MomentBloc(FetchMomentsUC uc);
}

// The God-Class BLoC
class FetchUserDataBloc {
  FetchUserDataBloc(
      FetchMyProfileUC uc1,
      FetchUserProfileUC uc2,
      InitPusherUC uc3,
      SubscribeChatUC uc4,
      SubscribeMessagesUC uc5,
      ListenToBannersUC uc6,
      ListenToGamesUC uc7,
      SubscribeCounterUC uc8,
      FetchConfigUC uc9,
      FetchCountriesUC uc10,
      UpdateFCMTokenUC uc11,
      FetchUserBadgesUC uc12,
      FetchLevelDataUC uc13,
      InitAnalyticsUC uc14,
      FetchWalletUC uc15,
      FetchGiftHistoryUC uc16,
      FetchUserRoomsUC uc17,
      FetchSupporterUC uc18,
      FetchCpProfileUC uc19,
      FetchUserIntroUC uc20,
      FetchMyBadgesUC uc21,
      );
}

// =============================================================================
// REFACTORED DI SERVICE
// =============================================================================

class DependencyInjectionService {
  static Future<void> init() async {
    _initCore();
    _initDataSources();
    _initRepositories();
    _initUseCases();
    _initHomeFeature();
    _initMessagesFeature();
    _initProfileFeature();
    _initReelsFeature();
    _initMomentsFeature();
    _initBootstrapFeature();
  }

  static void _initCore() {
    di.registerSingleton<DioFactory>(DioFactory());
    di.registerSingleton<HiveManager>(HiveManager());
  }

  static void _initDataSources() {
    di.registerLazySingleton<HomeRemoteDataSource>(
          () => HomeRemoteDataSource(di<DioFactory>()),
    );
    di.registerLazySingleton<MessagesRemoteDataSource>(
          () => MessagesRemoteDataSource(di<DioFactory>()),
    );
    di.registerLazySingleton<ProfileRemoteDataSource>(
          () => ProfileRemoteDataSource(di<DioFactory>()),
    );
  }

  static void _initRepositories() {
    di.registerLazySingleton<HomeRepository>(
          () => HomeRepository(di<HomeRemoteDataSource>()),
    );
    di.registerLazySingleton<MessagesRepository>(
          () => MessagesRepository(di<MessagesRemoteDataSource>()),
    );
    di.registerLazySingleton<ProfileRepository>(
          () => ProfileRepository(di<ProfileRemoteDataSource>()),
    );
  }

  static void _initUseCases() {
    di.registerLazySingleton(() => FetchRoomsUC(di()));
    di.registerLazySingleton(() => FetchLiveRoomsUC(di()));
    di.registerLazySingleton(() => CreateRoomUC(di()));
    di.registerLazySingleton(() => FetchMessagesUC(di()));
    di.registerLazySingleton(() => SendMessageUC(di()));
    di.registerLazySingleton(() => DeleteMessageUC(di()));
    di.registerLazySingleton(() => FetchUserProfileUC(di()));
    di.registerLazySingleton(() => FetchMyProfileUC(di()));
    di.registerLazySingleton(() => UpdateProfileUC(di()));
    di.registerLazySingleton(() => FetchGiftHistoryUC(di()));
    di.registerLazySingleton(() => FetchUserBadgesUC(di()));
    di.registerLazySingleton(() => FetchMyBadgesUC(di()));
    di.registerLazySingleton(() => FetchCpProfileUC(di()));
    di.registerLazySingleton(() => FetchUserRoomsUC(di()));
    di.registerLazySingleton(() => FetchSupporterUC(di()));
    di.registerLazySingleton(() => FetchUserIntroUC(di()));
    di.registerLazySingleton(() => FetchReelsUC(di()));
    di.registerLazySingleton(() => LikeReelUC(di()));
    di.registerLazySingleton(() => ShareReelUC(di()));
    di.registerLazySingleton(() => ViewReelUC(di()));
    di.registerLazySingleton(() => FetchMomentsUC(di()));
    di.registerLazySingleton(() => FetchConfigUC(di()));
    di.registerLazySingleton(() => FetchCountriesUC(di()));
    di.registerLazySingleton(() => UpdateFCMTokenUC(di()));
    di.registerLazySingleton(() => FetchLevelDataUC(di()));
    di.registerLazySingleton(() => InitAnalyticsUC(di()));
    di.registerLazySingleton(() => FetchWalletUC(di()));
  }

  static void _initHomeFeature() {
    // HomeBloc as factory:
    // screen-scoped state, should be recreated when the feature screen is reopened.
    di.registerFactory(() => HomeBloc(di(), di()));

    // CreateRoomBloc as factory:
    // transient form/action state should not be shared globally.
    di.registerFactory(() => CreateRoomBloc(di()));
  }

  static void _initMessagesFeature() {
    // MessagesBloc as factory:
    // chat screen state is session/UI specific and should not leak across screens.
    di.registerFactory(() => MessagesBloc(di(), di()));

    // DeleteMessageBloc as factory:
    // short-lived action bloc, better created per usage flow.
    di.registerFactory(() => DeleteMessageBloc(di()));
  }

  static void _initProfileFeature() {
    // GiftHistoryBloc as factory:
    // screen-specific paginated/filterable state; do not share globally.
    di.registerFactory(
          () => GiftHistoryBloc(giftHistoryUseCase: di()),
    );

    // GetBadgesBloc as factory:
    // feature state belongs to the current profile/badges screen.
    di.registerFactory(
          () => GetBadgesBloc(getBadgesUseCase: di(), getMyAllBadgeUC: di()),
    );

    // UserBadgesBloc as factory:
    // bound to a user/profile context and should be isolated per screen.
    di.registerFactory(
          () => UserBadgesBloc(uc: di()),
    );

    // GetUserBadgesBloc as factory:
    // same reasoning; screen-scoped fetching state.
    di.registerFactory(
          () => GetUserBadgesBloc(uc: di()),
    );

    // CpProfileBloc as factory:
    // profile details state should be recreated with each page flow.
    di.registerFactory(
          () => CpProfileBloc(uc: di()),
    );

    // GetUserRoomsBloc as factory:
    // state depends on the viewed user and filters, so factory is safer.
    di.registerFactory(
          () => GetUserRoomsBloc(uc: di()),
    );

    // GetSupporterBloc as factory:
    // page-scoped loaded state, no need for a global singleton bloc.
    di.registerFactory(
          () => GetSupporterBloc(uc: di()),
    );

    // GetUserIntroBloc as factory:
    // small feature-specific state, should not be shared across routes.
    di.registerFactory(
          () => GetUserIntroBloc(uc: di()),
    );
  }

  static void _initReelsFeature() {
    // GetReelsBloc as factory:
    // viewer/feed state is UI scoped and may differ across routes/tabs.
    di.registerFactory(
          () => GetReelsBloc(di(), di(), di(), di()),
    );

    // ReelViewerBloc as factory:
    // ephemeral viewer state per opened reel experience.
    di.registerFactory(
          () => ReelViewerBloc(di()),
    );
  }

  static void _initMomentsFeature() {
    // MomentBloc as factory:
    // timeline/feed state should be recreated for the owning screen.
    di.registerFactory(
          () => MomentBloc(di()),
    );
  }

  static void _initBootstrapFeature() {
    // NOTE:
    // We intentionally DO NOT register FetchUserDataBloc in its current form.
    // It is a god-class with too many responsibilities and should be split first.
  }
}

// =============================================================================
// YOUR ANSWERS
// =============================================================================

// QUESTION 1 [Junior]: Explain DI registration types
// ---------------------------------------------------
//
// registerSingleton:
// Creates the instance immediately and keeps one shared instance for the whole app.
// Use it for app-wide services that should live for the full app lifecycle, such as
// DioFactory, cache managers, analytics clients, or local database managers.
//
// registerLazySingleton:
// Similar to singleton, but the instance is created only on first use.
// Use it for shared dependencies that are expensive or unnecessary at startup,
// such as repositories, data sources, and many use cases.
//
// registerFactory:
// Creates a new instance every time it is requested.
// Use it for presentation-layer objects with short-lived UI state, especially
// BLoCs/Cubits that should be isolated per screen, route, or flow.
//
// Why having BOTH lazySingleton and factory for the same type is wrong:
// It creates conflicting lifecycle expectations for the same dependency.
// One path returns a shared instance, while another returns a fresh instance.
// This makes behavior inconsistent, harder to reason about, harder to test,
// and can cause state leaks or duplicate state depending on which registration
// gets resolved in practice.
//
//
// QUESTION 2 [Mid]: Refactored DI code
// ---------------------------------------------------
//
// Changes made:
// - Removed duplicate registrations for all BLoCs
// - Kept core services / repositories / use cases as singleton or lazy singleton
// - Converted presentation-layer BLoCs to factories because BLoCs usually own
//   screen-scoped or flow-scoped state and should not be shared globally
// - Removed FetchUserDataBloc registration pending architectural split
//
//
// QUESTION 3 [Senior]: Modular DI architecture + god-class refactor
// ---------------------------------------------------
//
// a) How would you split this 2000-line file into modules?
//
// I would split the DI setup by feature and layer:
//
// - di/core_di.dart
//   Registers core/shared services like DioFactory, HiveManager, app config,
//   storage, analytics clients, connectivity, etc.
//
// - di/data_sources_di.dart
//   Registers remote/local data sources
//
// - di/repositories_di.dart
//   Registers repositories
//
// - features/home/home_di.dart
// - features/messages/messages_di.dart
// - features/profile/profile_di.dart
// - features/reels/reels_di.dart
// - features/moments/moments_di.dart
// - features/bootstrap/app_bootstrap_di.dart
//
// Each feature file should expose a small init function like:
// initHomeFeatureDI(), initMessagesFeatureDI(), etc.
//
// b) How would you split FetchUserDataBloc into focused BLoCs?
//    List the new BLoCs and their responsibilities.
//
// I would replace FetchUserDataBloc with smaller focused units:
//
// 1. ProfileBootstrapCubit / ProfileBloc
//    - FetchMyProfileUC
//    - FetchUserProfileUC
//
// 2. RealtimeConnectionBloc
//    - InitPusherUC
//    - SubscribeChatUC
//    - SubscribeMessagesUC
//    - SubscribeCounterUC
//
// 3. HomeRealtimeContentBloc
//    - ListenToBannersUC
//    - ListenToGamesUC
//
// 4. AppConfigCubit
//    - FetchConfigUC
//    - FetchCountriesUC
//
// 5. NotificationTokenCubit
//    - UpdateFCMTokenUC
//
// 6. UserMetaBloc
//    - FetchUserBadgesUC
//    - FetchMyBadgesUC
//    - FetchLevelDataUC
//
// 7. WalletBloc
//    - FetchWalletUC
//
// 8. UserEngagementBloc
//    - FetchGiftHistoryUC
//    - FetchUserRoomsUC
//    - FetchSupporterUC
//    - FetchCpProfileUC
//    - FetchUserIntroUC
//
// 9. AnalyticsInitService / AnalyticsBootstrapCubit
//    - InitAnalyticsUC
//
// Then a lightweight AppBootstrapBloc or AppStartupCoordinator can orchestrate
// startup order without owning all business logic itself.
//
// c) Draw a simple dependency diagram (ASCII art is fine)
//
// AppStart
//    |
//    v
// AppBootstrapBloc / StartupCoordinator
//    |
//    +--> ProfileBootstrapCubit
//    |       +--> FetchMyProfileUC
//    |       +--> FetchUserProfileUC
//    |
//    +--> RealtimeConnectionBloc
//    |       +--> InitPusherUC
//    |       +--> SubscribeChatUC
//    |       +--> SubscribeMessagesUC
//    |       +--> SubscribeCounterUC
//    |
//    +--> HomeRealtimeContentBloc
//    |       +--> ListenToBannersUC
//    |       +--> ListenToGamesUC
//    |
//    +--> AppConfigCubit
//    |       +--> FetchConfigUC
//    |       +--> FetchCountriesUC
//    |
//    +--> NotificationTokenCubit
//    |       +--> UpdateFCMTokenUC
//    |
//    +--> UserMetaBloc
//    |       +--> FetchUserBadgesUC
//    |       +--> FetchMyBadgesUC
//    |       +--> FetchLevelDataUC
//    |
//    +--> WalletBloc
//    |       +--> FetchWalletUC
//    |
//    +--> UserEngagementBloc
//    |       +--> FetchGiftHistoryUC
//    |       +--> FetchUserRoomsUC
//    |       +--> FetchSupporterUC
//    |       +--> FetchCpProfileUC
//    |       +--> FetchUserIntroUC
//    |
//    +--> AnalyticsInitService
//            +--> InitAnalyticsUC
//
// Lazy feature loading strategy:
// - Register core services at app startup
// - Register repositories and feature use cases lazily
// - Register feature blocs only when the route/feature is opened
// - Optionally expose initFeatureX() methods and call them on first navigation
//   to that feature
//
// Testability implications:
// - Smaller feature-specific BLoCs are easier to unit test
// - Fewer constructor parameters reduce test setup complexity
// - Feature modules can be tested independently
// - Replacing implementations with mocks/fakes becomes simpler
// - Startup orchestration can be tested separately from feature behavior