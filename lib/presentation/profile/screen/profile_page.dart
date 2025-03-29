import 'package:blog/common/helper/extensions/get_initials.dart';
import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/router/app_router.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/domain/entities/profile/blogs_entity.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/profile/bloc/follow_bloc/follow_bloc.dart';
import 'package:blog/presentation/profile/bloc/load_blogs_bloc/load_blogs_bloc.dart';
import 'package:blog/presentation/profile/bloc/load_blogs_bloc/load_blogs_event.dart';
import 'package:blog/presentation/profile/bloc/load_blogs_bloc/load_blogs_state.dart';
import 'package:blog/presentation/profile/bloc/profile_data_bloc/profile_bloc.dart';
import 'package:blog/presentation/profile/bloc/profile_data_bloc/profile_event.dart';
import 'package:blog/presentation/profile/bloc/profile_data_bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String? username =
        GoRouterState.of(context).pathParameters['username'];
    if (username != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<AuthBloc>(),
          ),
          BlocProvider(
              create: (context) => ProfileBloc()
                ..add(LoadUserData(username: username.toLowerCase()))),
          BlocProvider(
            create: (context) => FollowBloc(),
          ),
          BlocProvider(
            create: (context) => LoadBlogsBloc()
              ..add(LoadUserBlogs(username: username.toLowerCase())),
          ),
        ],
        child: ProfilePageContent(username: username.toLowerCase()),
      );
    } else {
      return Center(
          child: Text(
              'User not found! Trying changing the username in the URL!',
              style: GoogleFonts.robotoMono(fontSize: 20)));
    }
  }
}

class ProfilePageContent extends StatefulWidget {
  final String username;
  const ProfilePageContent({super.key, required this.username});

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  bool isLocal = false;
  final ScrollController _scrollController = ScrollController();
  bool showTopBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Check authentication state and redirect if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess) {
        // Redirect to sign-in page
        context.go('/signin',
            extra: {'redirectUrl': '/profile/@${widget.username}'});
        return;
      }

      isLocal = (authState).userEntity.username == widget.username;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !showTopBar) {
      setState(() {
        showTopBar = true;
      });
    } else if (_scrollController.offset <= 200 && showTopBar) {
      setState(() {
        showTopBar = false;
      });
    }
  }

  void _shareBeacon() {
    BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          final url = 'https://nexus.rishia.in/profile/@${widget.username}';
          final name = state.userData.name;
          Share.share('Connect with $name on Nexus Signal: $url');
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? NexusColors.darkSurface : Colors.white,
      appBar: const BasicAppBar(
        isLanding: false,
      ),
      floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is UserLoaded) {
            return FloatingActionButton(
              backgroundColor: NexusColors.primaryBlue,
              foregroundColor: Colors.white,
              onPressed: () => _shareBeacon(),
              tooltip: 'Share Profile Beacon',
              child: const Icon(Icons.share_outlined),
            );
          }
          return const SizedBox();
        },
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is UserLoading) {
                      return _buildLoadingState();
                    }
                    if (state is UserError) {
                      return _buildErrorState(state.message);
                    }
                    if (state is UserLoaded) {
                      return _buildProfileHeader(state, isDark);
                    }
                    return const SizedBox();
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      return _buildStatsRow(state, isDark);
                    }
                    return const SizedBox();
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: context.isMobile
                        ? 16
                        : MediaQuery.of(context).size.width * 0.1,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: NexusColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: NexusColors.primaryBlue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.radio_button_checked,
                              size: 16,
                              color: NexusColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Signal Beacons',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: NexusColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile
                      ? 16
                      : MediaQuery.of(context).size.width * 0.1,
                ),
                sliver: BlocBuilder<LoadBlogsBloc, LoadBlogsState>(
                  builder: (context, state) {
                    if (state is BlogsLoading) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(
                                  color: NexusColors.primaryBlue,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading signals...',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is BlogsError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: isDark ? Colors.red[300] : Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading signals',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is BlogsLoaded) {
                      if (state.blogs.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildEmptyState(isDark),
                        );
                      }

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.isMobile ? 1 : 2,
                          childAspectRatio: context.isMobile ? 2 : 2.9,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final blog = state.blogs[index];
                            return _buildSignalCard(blog, isDark);
                          },
                          childCount: state.blogs.length,
                        ),
                      );
                    }

                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
          if (showTopBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? NexusColors.darkSurface.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                NexusColors.primaryBlue.withOpacity(0.2),
                            child: Text(
                              state.userData.name.toString().getInitials(),
                              style: GoogleFonts.spaceGrotesk(
                                color: NexusColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.userData.name,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '@${state.userData.username}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLocal)
                            _buildFollowButton(state.userData, compact: true),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: NexusColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading profile data...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: context.isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: context.isDark ? Colors.red[300] : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading profile',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.spaceGrotesk(
              color: context.isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              context.read<ProfileBloc>().add(
                    LoadUserData(username: widget.username),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'Try Again',
              style: GoogleFonts.spaceGrotesk(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NexusColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.signal_cellular_alt_rounded,
              size: 48,
              color: NexusColors.primaryBlue.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No signals yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 280,
            child: Text(
              'This user hasn\'t published any signals to the network yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (isLocal)
            ElevatedButton.icon(
              onPressed: () {
                context.go('/editor');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(
                'Create Signal',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserLoaded state, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            context.isMobile ? 16 : MediaQuery.of(context).size.width * 0.1,
        vertical: 24,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdvancedAvatar(
                size: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NexusColors.primaryBlue.withOpacity(0.7),
                      NexusColors.primaryBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(42),
                ),
                child: Text(
                  state.userData.name.toString().getInitials(),
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.userData.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '@${state.userData.username}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.userData.bio ?? "No bio available",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Joined ${DateFormat('MMMM yyyy').format(state.userData.createdAt.toDate())}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!context.isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: () => _shareBeacon(),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        if (isLocal)
                          _buildEditButton(state.userData)
                        else
                          _buildFollowButton(state.userData),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSocialLinks(state.userData, isDark),
                  ],
                ),
            ],
          ),
          if (context.isMobile) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () => _shareBeacon(),
                  isDark: isDark,
                ),
                if (isLocal)
                  _buildEditButton(state.userData)
                else
                  _buildFollowButton(state.userData),
              ],
            ),
            const SizedBox(height: 16),
            _buildSocialLinks(state.userData, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.black87,
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(
        icon,
        size: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
      label: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEditButton(dynamic userData) {
    return ElevatedButton.icon(
      onPressed: () {
        context.go(AppRouterConstants.profileEdit, extra: {
          'username': widget.username,
          'name': userData.name,
          'bio': userData.bio,
          'socials': {
            'instagram': userData.socials?['instagram'],
            'twitter': userData.socials?['twitter'],
            'github': userData.socials?['github'],
            'linkedin': userData.socials?['linkedin'],
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: NexusColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: const Icon(Icons.edit_outlined, size: 14),
      label: Text(
        'Edit Profile',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFollowButton(dynamic profileEntity, {bool compact = false}) {
    final localUser =
        (context.read<AuthBloc>().state as AuthSuccess).userEntity;
    final bool isFollowing =
        (profileEntity.followers ?? []).contains(localUser.username);

    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        if (state is FollowLoading) {
          return SizedBox(
            height: compact ? 30 : 36,
            width: compact ? 30 : 36,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.isDark ? Colors.white : NexusColors.primaryBlue,
              ),
            ),
          );
        }

        if (isFollowing || state is FollowSuccess) {
          return OutlinedButton.icon(
            onPressed: () {
              // Unfollow not implemented in this example
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: NexusColors.primaryBlue,
              side: const BorderSide(color: NexusColors.primaryBlue),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 6 : 8,
              ),
              minimumSize: Size(0, compact ? 30 : 36),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.check, size: compact ? 14 : 16),
            label: Text(
              compact ? 'Following' : 'Following',
              style: GoogleFonts.spaceGrotesk(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: () {
            final localUser =
                (context.read<AuthBloc>().state as AuthSuccess).userEntity;
            context.read<FollowBloc>().add(FollowUser(
                followerUid: localUser.id,
                followingUid: profileEntity.uid,
                followerUsername: localUser.username,
                followingUsername: widget.username));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NexusColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 6 : 8,
            ),
            minimumSize: Size(0, compact ? 30 : 36),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.person_add_outlined, size: compact ? 14 : 16),
          label: Text(
            compact ? 'Follow' : 'Follow',
            style: GoogleFonts.spaceGrotesk(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLinks(dynamic userData, bool isDark) {
    final socials = userData.socials ?? {};

    if (socials.isEmpty) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (socials['twitter'] != null && socials['twitter'].isNotEmpty)
          _buildSocialIcon('twitter', socials['twitter'], isDark),
        if (socials['github'] != null && socials['github'].isNotEmpty)
          _buildSocialIcon('github', socials['github'], isDark),
        if (socials['linkedin'] != null && socials['linkedin'].isNotEmpty)
          _buildSocialIcon('linkedin', socials['linkedin'], isDark),
        if (socials['instagram'] != null && socials['instagram'].isNotEmpty)
          _buildSocialIcon('instagram', socials['instagram'], isDark),
      ],
    );
  }

  Widget _buildSocialIcon(String platform, String handle, bool isDark) {
    IconData icon;
    String url;

    switch (platform) {
      case 'twitter':
        icon = LucideIcons.twitter;
        url = handle;
        break;
      case 'github':
        icon = LucideIcons.github;
        url = handle;
        break;
      case 'linkedin':
        icon = LucideIcons.linkedin;
        url = handle;
        break;
      case 'instagram':
        icon = LucideIcons.instagram;
        url = handle;
        break;
      default:
        icon = Icons.link;
        url = handle;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        tooltip: 'Visit $platform',
      ),
    );
  }

  Widget _buildStatsRow(UserLoaded state, bool isDark) {
    return BlocBuilder<LoadBlogsBloc, LoadBlogsState>(
      builder: (context, blogsState) {
        // Get accurate post count from the blogs list
        final postCount = blogsState is BlogsLoaded
            ? blogsState.blogs.length.toString()
            : '${state.userData.postCount}';

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal:
                context.isMobile ? 16 : MediaQuery.of(context).size.width * 0.1,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Signals',
                  postCount, // Use the accurate count
                  Icons.signal_cellular_alt_rounded,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFollowersFollowing(
                    context,
                    state.userData.followers ?? [],
                    true,
                  ),
                  child: _buildStatCard(
                    'Receivers',
                    '${state.userData.followerCount}',
                    Icons.people_alt_outlined,
                    isDark,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFollowersFollowing(
                    context,
                    state.userData.following ?? [],
                    false,
                  ),
                  child: _buildStatCard(
                    'Connections', // Changed from "Following"
                    '${state.userData.followingCount}',
                    Icons.connect_without_contact_outlined,
                    isDark,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: NexusColors.primaryBlue,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowersFollowing(
      BuildContext context, List list, bool isFollowers) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor:
            context.isDark ? NexusColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width *
              (context.isMobile ? 0.9 : 0.4),
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFollowers
                            ? Icons.people_alt_outlined
                            : Icons.connect_without_contact_outlined,
                        color: NexusColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isFollowers ? 'Receivers' : 'Connections',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: context.isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isFollowers
                                  ? Icons.people_outline
                                  : Icons.person_add_disabled_outlined,
                              size: 48,
                              color: context.isDark
                                  ? Colors.white30
                                  : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFollowers
                                  ? 'No followers yet'
                                  : 'Not following anyone yet',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                color: context.isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  NexusColors.primaryBlue.withOpacity(0.2),
                              child: Text(
                                list[index][0].toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  color: NexusColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '@${list[index]}',
                              style: GoogleFonts.spaceGrotesk(
                                color: context.isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/profile/@${list[index]}');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalCard(ProfileBlogEntity blog, bool isDark) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go('/blog/@${blog.authors[0]}/${blog.blogUid}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14), // Reduced padding
          decoration: BoxDecoration(
            color: isDark ? NexusColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Keep column tight
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Signal badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: NexusColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          size: 10,
                          color: NexusColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Signal',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: NexusColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                blog.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15, // Slightly smaller font
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4), // Reduced spacing
              Text(
                extractPreviewText(blog.content),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  height: 1.3,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8), // Reduced spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Share button
                      IconButton(
                        onPressed: () {
                          final url =
                              'https://nexus.rishia.in/signal/@${blog.authors[0]}/${blog.blogUid}';
                          Share.share(
                              '${blog.title}\n\nConnect with this beacon on Nexus: $url');
                        },
                        icon: Icon(
                          Icons.share_outlined,
                          size: 16,
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                        tooltip: 'Share Signal',
                      ),
                      // Read button
                      TextButton(
                        onPressed: () => context
                            .go('/blog/@${blog.authors[0]}/${blog.blogUid}'),
                        style: TextButton.styleFrom(
                          foregroundColor: NexusColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'Read',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String extractPreviewText(String content) {
    if (content.isEmpty) return '';

    String preview = content;
    preview = preview.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');

    preview = preview.replaceAllMapped(
        RegExp(r'\[(.*?)\]\(.*?\)'), (match) => match.group(1) ?? '');

    preview = preview.replaceAll(RegExp(r'#{1,6}\s'), '');

    // Fix bold formatting
    preview = preview.replaceAllMapped(
        RegExp(r'(\*\*|__)(.*?)(\1)'), (match) => match.group(2) ?? '');

    // Fix italic formatting
    preview = preview.replaceAllMapped(
        RegExp(r'(\*|_)(.*?)(\1)'), (match) => match.group(2) ?? '');

    // Remove code blocks
    preview = preview.replaceAll(RegExp(r'```.*?```'), '');

    // Fix inline code
    preview = preview.replaceAllMapped(
        RegExp(r'`(.*?)`'), (match) => match.group(1) ?? '');

    // Remove blockquotes
    preview = preview.replaceAll(RegExp(r'>\s'), '');

    // Clean up whitespace
    preview = preview.replaceAll(RegExp(r'\n{2,}'), ' ');
    preview = preview.replaceAll(RegExp(r'\s{2,}'), ' ');

    return preview.trim();
  }
}
