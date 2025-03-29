// Create a new file: /lib/presentation/shared/screen/main_container_page.dart

import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/explore/bloc/explore_bloc.dart';
import 'package:blog/presentation/explore/bloc/explore_event.dart';
import 'package:blog/presentation/explore/screen/explore_page.dart';
import 'package:blog/presentation/home/screens/home/home.dart';
import 'package:blog/presentation/landing/landing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MainContainerPage extends StatefulWidget {
  final int initialTabIndex;

  const MainContainerPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // Initialize the Explore BLoC when switching to that tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && _tabController.previousIndex != 1) {
        // Only reload explore content when switching to the explore tab
        context.read<ExploreBloc>().add(const LoadExploreSignals());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return const Landing();
        }

        return Scaffold(
          backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
          appBar: _buildAppBar(context, isDark, state),
          drawer: _buildDrawer(context, isDark, state),
          body: TabBarView(
            controller: _tabController,
            // Prevent swiping between tabs
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Home Tab
              Home(showAppBar: false),

              // Explore Tab
              BlocProvider(
                create: (context) =>
                    ExploreBloc()..add(const LoadExploreSignals()),
                child: const ExplorePageContent(showAppBar: false),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.go('/editor');
            },
            backgroundColor: NexusColors.primaryBlue,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(
              'New Signal',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isDark, AuthSuccess state) {
    return AppBar(
      backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
      elevation: 0,
      title: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NexusColors.gradientStart,
                  NexusColors.gradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: NexusColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.hub,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'NEXUS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        // Network status indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: NexusColors.signalGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: NexusColors.signalGreen.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Connected',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),

        // User profile
        GestureDetector(
          onTap: () {
            context.go('/profile/@${state.userEntity.username}');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: NexusColors.primaryBlue.withOpacity(0.15),
              child: Text(
                state.userEntity.name.isNotEmpty
                    ? state.userEntity.name[0].toUpperCase()
                    : '?',
                style: GoogleFonts.spaceGrotesk(
                  color: NexusColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

        // Settings menu
        PopupMenuButton(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          color: isDark ? NexusColors.darkSurface : Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Text(
                'My Profile',
                style: GoogleFonts.spaceGrotesk(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Text(
                'Settings',
                style: GoogleFonts.spaceGrotesk(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text(
                'Sign Out',
                style: GoogleFonts.spaceGrotesk(
                  color: isDark ? Colors.red[300] : Colors.red,
                ),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'profile') {
              context.go('/profile/@${state.userEntity.username}');
            } else if (value == 'logout') {
              // context.read<AuthBloc>().add(const AuthLogoutRequested());
            }
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: NexusColors.primaryBlue,
        unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
        indicatorColor: NexusColors.primaryBlue,
        indicatorWeight: 3,
        tabs: [
          Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Home',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Explore',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark, AuthSuccess state) {
    return Drawer(
      backgroundColor: isDark ? NexusColors.darkSurface : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : NexusColors.primaryBlue.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: NexusColors.primaryBlue.withOpacity(0.2),
                  child: Text(
                    state.userEntity.name.isNotEmpty
                        ? state.userEntity.name[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: NexusColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.userEntity.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '@${state.userEntity.username}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: Text(
              'Home',
              style: GoogleFonts.spaceGrotesk(),
            ),
            selected: _tabController.index == 0,
            selectedColor: NexusColors.primaryBlue,
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: Text(
              'Explore',
              style: GoogleFonts.spaceGrotesk(),
            ),
            selected: _tabController.index == 1,
            selectedColor: NexusColors.primaryBlue,
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              'My Profile',
              style: GoogleFonts.spaceGrotesk(),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile/@${state.userEntity.username}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(
              'New Signal',
              style: GoogleFonts.spaceGrotesk(),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go('/editor');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Sign Out',
              style: GoogleFonts.spaceGrotesk(),
            ),
            onTap: () {
              Navigator.pop(context);
              // context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
    );
  }
}
