// =============================================================================
// YOUR ANALYSIS
// =============================================================================

// ISSUE #1:
// Root StreamBuilder rebuilds the whole MainLayout every 30 seconds.
// IMPACT: HIGH
// WHY: Rebuilding the full Stack, banners, layout body, counters, and wallet
// layer on a periodic timer causes unnecessary work and dropped frames.
// FIX:
/*
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainLayoutContent();
  }
}

class _MainLayoutContent extends StatelessWidget {
  const _MainLayoutContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        GiftBannerLayer(),
        GameBannerLayer(),
        LuckyBannerLayer(),
        OnlineBadgeLayer(),
        LayoutBodyLayer(),
        UnreadCounterLayer(),
        WalletDisplayLayer(),
      ],
    );
  }
}
*/
// If the timer is needed, move it to a tiny isolated widget or cubit instead
// of rebuilding the whole screen.


// ISSUE #2:
// Three separate BlocBuilders listen to FetchUserDataBloc for bannerData.
// IMPACT: HIGH
// WHY: All three banner widgets rebuild on every FetchUserDataState change even
// when unrelated fields like unreadCount or isOnline change.
// FIX:
/*
class BannerOverlays extends StatelessWidget {
  const BannerOverlays({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FetchUserDataBloc, FetchUserDataState, Map<String, dynamic>?>(
      bloc: di<FetchUserDataBloc>(),
      selector: (state) => state.bannerData,
      builder: (_, bannerData) {
        final gift = bannerData?['gift'];
        final game = bannerData?['game'];
        final lucky = bannerData?['lucky'];

        return Stack(
          children: [
            if (gift != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _GiftBanner(),
              ),
            if (game != null)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: _GameBanner(),
              ),
            if (lucky != null)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: _LuckyBanner(),
              ),
          ],
        );
      },
    );
  }
}
*/


// ISSUE #3:
// Online badge uses BlocBuilder without buildWhen for a single boolean.
// IMPACT: MEDIUM
// WHY: The badge rebuilds for every user state change although it only depends
// on isOnline.
// FIX:
/*
BlocSelector<FetchUserDataBloc, FetchUserDataState, bool>(
  bloc: di<FetchUserDataBloc>(),
  selector: (state) => state.isOnline,
  builder: (_, isOnline) {
    if (!isOnline) return const SizedBox.shrink();
    return const Positioned(
      top: 10,
      right: 10,
      child: _OnlineBadge(),
    );
  },
)
*/


// ISSUE #4:
// Layout body BlocBuilder has no buildWhen.
// IMPACT: MEDIUM
// WHY: IndexedStack rebuilds whenever any LayoutState field changes, even if
// currentIndex did not change.
// FIX:
/*
BlocBuilder<LayoutBloc, LayoutState>(
  bloc: di<LayoutBloc>(),
  buildWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
  builder: (context, layoutState) {
    return IndexedStack(
      index: layoutState.currentIndex,
      children: const [
        HomeTabShell(),
        ChatPage(),
        ProfilePage(),
        SettingsPage(),
      ],
    );
  },
)
*/


// ISSUE #5:
// Nested BlocBuilders for unread counter cause double rebuilds.
// IMPACT: HIGH
// WHY: The widget rebuilds when either user state or layout state changes, and
// nesting increases unnecessary rebuild propagation.
// FIX:
/*
class UnreadCounterLayer extends StatelessWidget {
  const UnreadCounterLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LayoutBloc, LayoutState, int>(
      bloc: di<LayoutBloc>(),
      selector: (state) => state.currentIndex,
      builder: (_, currentIndex) {
        if (currentIndex != 1) return const SizedBox.shrink();

        return BlocSelector<FetchUserDataBloc, FetchUserDataState, int>(
          bloc: di<FetchUserDataBloc>(),
          selector: (state) => state.unreadCount,
          builder: (_, unreadCount) {
            return Positioned(
              bottom: 70,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
*/


// ISSUE #6:
// Wallet display creates a new ValueNotifier inside build.
// IMPACT: HIGH
// WHY: A new notifier is allocated every rebuild, resetting state and wasting
// memory/work.
// FIX:
/*
class WalletDisplayLayer extends StatefulWidget {
  const WalletDisplayLayer({super.key});

  @override
  State<WalletDisplayLayer> createState() => _WalletDisplayLayerState();
}

class _WalletDisplayLayerState extends State<WalletDisplayLayer> {
  late final ValueNotifier<String> walletNotifier;

  @override
  void initState() {
    super.initState();
    walletNotifier = ValueNotifier<String>('0');
  }

  @override
  void dispose() {
    walletNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: walletNotifier,
      builder: (_, value, __) {
        return Positioned(
          top: 50,
          right: 10,
          child: Text('💰 $value'),
        );
      },
    );
  }
}
*/
// Better yet, derive wallet balance directly from bloc state with BlocSelector.


// ISSUE #7:
// _buildHomePage wraps the entire tab area with one HomeBloc builder.
// IMPACT: HIGH
// WHY: Any HomeState change rebuilds the whole tab bar and all tab contents.
// FIX:
/*
class HomeTabShell extends StatelessWidget {
  const HomeTabShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HomeTabsHeader(),
        Expanded(child: HomeTabsBody()),
      ],
    );
  }
}
*/


// ISSUE #8:
// Home tab header rebuilds for all HomeState field changes.
// IMPACT: MEDIUM
// WHY: The tab bar only needs currentTabIndex, but it rebuilds when room lists,
// pages, and unrelated fields change.
// FIX:
/*
class HomeTabsHeader extends StatelessWidget {
  const HomeTabsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, int>(
      bloc: di<HomeBloc>(),
      selector: (state) => state.currentTabIndex,
      builder: (_, currentTabIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Popular',
                style: TextStyle(
                  fontWeight: currentTabIndex == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            const TextButton(onPressed: null, child: Text('Live')),
            const TextButton(onPressed: null, child: Text('Following')),
            const TextButton(onPressed: null, child: Text('Friends')),
          ],
        );
      },
    );
  }
}
*/


// ISSUE #9:
// IndexedStack body rebuilds all tab children when any HomeState field changes.
// IMPACT: HIGH
// WHY: Popular/live/following/friends lists are all recreated even if only one
// list changes.
// FIX:
/*
class HomeTabsBody extends StatelessWidget {
  const HomeTabsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, int>(
      bloc: di<HomeBloc>(),
      selector: (state) => state.currentTabIndex,
      builder: (_, currentTabIndex) {
        return IndexedStack(
          index: currentTabIndex,
          children: const [
            PopularRoomsTab(),
            LiveRoomsTab(),
            FollowingRoomsTab(),
            FriendsRoomsTab(),
          ],
        );
      },
    );
  }
}

class PopularRoomsTab extends StatelessWidget {
  const PopularRoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, List<dynamic>>(
      bloc: di<HomeBloc>(),
      selector: (state) => state.popularRooms,
      builder: (_, rooms) {
        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (_, i) => ListTile(title: Text('Popular $i')),
        );
      },
    );
  }
}
*/
// Apply the same pattern for LiveRoomsTab, FollowingRoomsTab, FriendsRoomsTab.


// ISSUE #10:
// BottomNavigationBar active icons use SVGA for simple tab states.
// IMPACT: HIGH
// WHY: SVGA animation rendering is expensive for something that changes only on
// tab selection; it increases CPU/GPU work and memory pressure.
// FIX:
/*
BottomNavigationBarItem(
  icon: const Icon(Icons.home_outlined),
  activeIcon: const Icon(Icons.home),
  label: 'Home',
)
*/
// If branding requires richer visuals, use a lightweight animated scale/fade
// with AnimatedSwitcher instead of SVGA.


// ISSUE #11:
// Static routes map keeps all route closures alive permanently.
// IMPACT: MEDIUM
// WHY: A large routes map with 100+ closures increases memory retention and
// keeps route construction logic centralized and less scalable.
// FIX:
// Migrate to onGenerateRoute (see senior bonus below).


// ISSUE #12:
// Repeated immediate ValueNotifier writes in onExitRoom.
// IMPACT: LOW
// WHY: The first assignment is overwritten instantly, causing pointless notifier
// emissions and wasted rebuilds.
// FIX:
/*
static void onExitRoom() {
  isKeepInRoom.value = false;
}
*/
// Or decide the correct final value once before notifying listeners.


// ISSUE #13:
// Missing const on simple widgets like SizedBox, Spacer, SizedBox.shrink.
// IMPACT: LOW
// WHY: Non-const widgets are recreated unnecessarily and miss Flutter's const
// canonicalization optimizations.
// FIX:
/*
static Widget buildDivider() => const SizedBox(height: 1);
static Widget buildSpacer() => const Spacer();
static Widget buildEmpty() => const SizedBox.shrink();
*/


// ISSUE #14:
// Returning plain SizedBox() instead of const SizedBox.shrink() in multiple places.
// IMPACT: LOW
// WHY: It creates unnecessary objects and is less explicit than a zero-size
// constant widget.
// FIX:
/*
if (data == null) return const SizedBox.shrink();
if (!state.isOnline) return const SizedBox.shrink();
if (layoutState.currentIndex != 1) return const SizedBox.shrink();
*/


// ISSUE #15:
// Using di<T>() repeatedly inside build methods.
// IMPACT: MEDIUM
// WHY: Repeated service locator lookups in build reduce clarity and may hide
// lifecycle problems; dependencies should be resolved once closer to ownership.
// FIX:
/*
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final fetchUserDataBloc = di<FetchUserDataBloc>();
    final layoutBloc = di<LayoutBloc>();
    final homeBloc = di<HomeBloc>();

    return _MainLayoutContent(
      fetchUserDataBloc: fetchUserDataBloc,
      layoutBloc: layoutBloc,
      homeBloc: homeBloc,
    );
  }
}
*/


// =============================================================================
// SENIOR BONUS #1: onGenerateRoute migration
// =============================================================================

/*
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<SplashBloc>()),
              BlocProvider.value(value: di<ConfigAppBloc>()),
              BlocProvider.value(value: di<ColorsBloc>()),
            ],
            child: const SplashPage(),
          ),
        );

      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<LoginBloc>(),
            child: const LoginPage(),
          ),
        );

      case Routes.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<RegisterBloc>(),
            child: const RegisterPage(),
          ),
        );

      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<HomeBloc>()),
              BlocProvider.value(value: di<FetchUserDataBloc>()),
            ],
            child: const HomePage(),
          ),
        );

      case Routes.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<ProfileBloc>(),
            child: const ProfilePage(),
          ),
        );

      case Routes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsPage(),
        );

      case Routes.room:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<RoomBloc>()),
              BlocProvider.value(value: di<FetchUserDataBloc>()),
            ],
            child: const RoomPage(),
          ),
        );

      case Routes.chat:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<ChatBloc>(),
            child: const ChatPage(),
          ),
        );

      case Routes.search:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<SearchBloc>(),
            child: const SearchPage(),
          ),
        );

      case Routes.reels:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<ReelsBloc>(),
            child: const ReelsPage(),
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
*/


// =============================================================================
// SENIOR BONUS #2: HomeState split proposal
// =============================================================================

// I would split HomeState into smaller focused sub-states:
//
// 1. HomeNavigationState
//    - currentTabIndex
//
// 2. PopularRoomsState
//    - popularRooms
//    - popularCurrentPage
//    - popular loading/error/hasMore fields
//
// 3. LiveRoomsState
//    - liveRooms
//    - liveCurrentPage
//    - live loading/error/hasMore fields
//
// 4. FollowingRoomsState
//    - followRooms
//    - followCurrentPage
//    - follow loading/error/hasMore fields
//
// 5. FriendsRoomsState
//    - friendsRooms
//    - friendsCurrentPage
//    - friends loading/error/hasMore fields
//
// 6. GlobalRoomsState
//    - globalRooms
//    - globalCurrentPage
//    - global loading/error/hasMore fields
//
// 7. FilteredRoomsState
//    - filteredRooms
//    - active filters
//    - filtered loading/error fields
//
// 8. LastCreatedRoomsState
//    - lastCreateRooms
//    - loading/error fields
//
// Then compose them using either:
// - multiple feature cubits/blocs, one per tab/data source
// - or a parent HomeScreenCoordinator that reads smaller blocs
//
// This reduces rebuild scope, improves testability, and makes pagination logic
// independent per tab instead of coupling everything into one large state object.