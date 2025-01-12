import 'package:blog/common/helper/extensions/get_initials.dart';
import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/router/app_router.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/core/configs/constants/app_constants/constants.dart';
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
import 'package:blog/responsive/responsive_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  // final String userUid;
  // final String username;
  // final String? name;
  // final String? email;
  const ProfilePage({
    super.key,
    // required this.userUid,
    // required this.username,
    // this.name,
    // this.email
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

  @override
  void initState() {
    super.initState();
    (context.read<AuthBloc>().state is AuthSuccess)
        ? isLocal = (context.read<AuthBloc>().state as AuthSuccess)
                .userEntity
                .username ==
            (widget.username)
        : isLocal = false;
    print("isLocal: $isLocal");
  }

  void _shareLink(String link) {
    String message = 'Check out my profile: $link';
    Share.share(message, subject: 'Interesting Link');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(
        isLanding: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        'Loading user data',
                        style: GoogleFonts.robotoMono(),
                      )
                    ],
                  ));
                }
                if (state is UserError) {
                  return Center(
                    child: Text("Error: //${state.message}",
                        style: GoogleFonts.robotoMono()),
                  );
                }
                if (state is UserLoaded) {
                  return Center(
                    child: Column(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width *
                                (context.isMobile ? 1 : 0.8),
                            padding: EdgeInsets.all(context.isMobile ? 20 : 40),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    width: .4,
                                    color: (context.isMobile)
                                        ? Colors.transparent
                                        : Colors.grey[500] ?? Colors.grey)),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ResponsiveLayout(
                                      mobileWidget: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          children: [
                                            _infoPlatformLeft(
                                                name: (state).userData.name,
                                                bio: state.userData.bio ?? "",
                                                username:
                                                    state.userData.username,
                                                followerCount: state
                                                    .userData.followerCount,
                                                followingCount: state
                                                    .userData.followingCount),
                                            _infoPlaformRight(),
                                            const SizedBox(height: 18),
                                            _joiningDate(
                                                state.userData.createdAt),
                                          ],
                                        ),
                                      ),
                                      desktopWidget: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _infoPlatformLeft(
                                                  name: state.userData.name,
                                                  bio: state.userData.bio ?? "",
                                                  username:
                                                      state.userData.username,
                                                  followerCount: state
                                                      .userData.followerCount,
                                                  followingCount: state
                                                      .userData.followingCount,
                                                  followers:
                                                      state.userData.followers,
                                                  following:
                                                      state.userData.following),
                                              _infoPlaformRight(),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          _joiningDate(
                                              state.userData.createdAt),
                                        ],
                                      )),
                                ],
                              ),
                            ))
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            BlocBuilder<LoadBlogsBloc, LoadBlogsState>(
                builder: (context, state) {
              if (state is BlogsLoading) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Loading blogs data',
                      style: GoogleFonts.robotoMono(),
                    )
                  ],
                ));
              }
              if (state is BlogsError) {
                return Center(
                  child: Text("Error: //${state.message}",
                      style: GoogleFonts.robotoMono()),
                );
              }
              if (state is BlogsLoaded) {
                return Container(
                  width: MediaQuery.of(context).size.width *
                      (context.isMobile ? 1 : 0.8),
                  padding: const EdgeInsets.only(top: 20),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: GridView.builder(
                        // physics: const NeverScrollableScrollPhysics(),
                        key: const PageStorageKey('blog_grid'),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.isMobile ? 1 : 3,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.blogs.length,
                        itemBuilder: (context, index) {
                          final blog = state.blogs[index];
                          return BlogCard(
                            blog: blog,
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            })
          ],
        ),
      ),
    );
  }

  Widget _joiningDate(Timestamp stamp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              width: .2,
              color: context.isDark
                  ? Colors.grey[500] ?? Colors.grey
                  : Colors.grey[600] ?? Colors.grey)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_month,
            size: 20,
          ),
          const SizedBox(width: 18),
          Text('Member Since ${DateFormat('MMM d, y').format(stamp.toDate())}',
              style:
                  GoogleFonts.robotoMono(fontSize: context.isMobile ? 12 : 18))
        ],
      ),
    );
  }

  Widget _infoPlatformLeft(
      {required String name,
      required String username,
      required String bio,
      int? followingCount,
      int? followerCount,
      List? followers,
      List? following}) {
    return Row(
      children: [
        AdvancedAvatar(
          size: 25.sp,
          statusColor: AppColors.primaryLight,
          child: Text(
            name.toString().getInitials(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: context.isMobile ? 24 : 18.sp),
            ),
            Text(
              '@$username',
              style: GoogleFonts.robotoMono(
                  fontSize: context.isMobile ? 18 : 12.sp,
                  color: context.isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                bio,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.sp,
                    color:
                        context.isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _followStats(followingCount, followerCount, following, followers),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  void _showFollowersFollowing(
      BuildContext context, List list, bool isFollowers) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor:
            context.isDark ? AppColors.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: context.isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFollowers ? 'Followers' : 'Following',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          isFollowers ? 'No followers yet' : 'No following yet',
                          style: GoogleFonts.robotoMono(),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              '@${list[index]}',
                              style: GoogleFonts.robotoMono(),
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

  Widget _followStats(int? followingCount, int? followerCount, List? following,
      List? followers) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showFollowersFollowing(context, followers ?? [], true),
          child: Row(
            children: [
              Text(
                followerCount.toString(),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                'Followers',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        GestureDetector(
          onTap: () => _showFollowersFollowing(context, following ?? [], false),
          child: Row(
            children: [
              Text(
                followingCount.toString(),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                "Following",
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _infoPlaformRight() {
    final profileEntity =
        (context.read<ProfileBloc>().state as UserLoaded).userData;
    final localUser =
        (context.read<AuthBloc>().state as AuthSuccess).userEntity;
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        return Row(
          children: [
            GestureDetector(
              onTap: () => _shareLink(
                  'https://${Constants.domain}/profile/@${widget.username}'),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.ios_share_rounded, size: 25),
              ),
            ),
            BasicButton(
              enableBorder: state is FollowSuccess ? true : false,
              color: state is FollowSuccess ||
                      ((profileEntity.followers ?? [])
                          .contains(localUser.username))
                  ? Colors.transparent
                  : (context.isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight),
              dynamic: true,
              customWidget: Row(
                children: [
                  _buttonIcon(state),
                  const SizedBox(width: 8),
                  _followText(state)
                ],
              ),
              onPressed: () {
                if (!isLocal &&
                    (state is! FollowLoading || state is! FollowSuccess)) {
                  final localUser =
                      (context.read<AuthBloc>().state as AuthSuccess)
                          .userEntity;
                  context.read<FollowBloc>().add(FollowUser(
                      followerUid: localUser.id,
                      followingUid:
                          (context.read<ProfileBloc>().state as UserLoaded)
                              .userData
                              .uid,
                      followerUsername: localUser.username,
                      followingUsername: widget.username));
                } else {
                  final userData =
                      (context.read<ProfileBloc>().state as UserLoaded)
                          .userData;
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
                }
              },
              width: isLocal
                  ? 100
                  : (state is FollowSuccess ||
                          ((profileEntity.followers ?? [])
                              .contains(localUser.username))
                      ? 145
                      : 128),
            )
          ],
        );
      },
    );
  }

  Widget _followText(state) {
    final profileEntity =
        (context.read<ProfileBloc>().state as UserLoaded).userData;
    final localUser =
        (context.read<AuthBloc>().state as AuthSuccess).userEntity;
    if (isLocal) {
      return Text('Edit', style: GoogleFonts.robotoMono(fontSize: 18));
    } else {
      if (state is FollowLoading) {
        return const SizedBox.shrink();
      }
      if (state is FollowSuccess ||
          ((profileEntity.followers ?? []).contains(localUser.username))) {
        return Text('Following',
            style: GoogleFonts.robotoMono(
                fontSize: 16, color: AppColors.primaryLight));
      }
      return Text('Follow', style: GoogleFonts.robotoMono(fontSize: 18));
    }
  }

  Widget _buttonIcon(state) {
    final profileEntity =
        (context.read<ProfileBloc>().state as UserLoaded).userData;
    final localUser =
        (context.read<AuthBloc>().state as AuthSuccess).userEntity;
    if (isLocal) {
      return const Icon(
        Icons.edit,
        size: 20,
      );
    } else {
      if (state is FollowLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }
      if (state is FollowSuccess ||
          ((profileEntity.followers ?? []).contains(localUser.username))) {
        return const Icon(
          Icons.check,
          size: 20,
        );
      }
      return const Icon(
        Icons.add,
        size: 20,
      );
    }
  }
}

class BlogCard extends StatefulWidget {
  final ProfileBlogEntity blog;
  const BlogCard({super.key, required this.blog});

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        margin: EdgeInsets.symmetric(horizontal: context.isMobile ? 10 : 1),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered
              ? AppColors.primaryLight.withOpacity(0.4)
              : (context.isDark ? AppColors.darkBackground : Colors.white),
          border: Border.all(
            color: isHovered
                ? AppColors.primaryLight
                : (context.isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          onTap: () => context
              .go('/blog/@${widget.blog.authors[0]}/${widget.blog.blogUid}'),
          child: Card(
            key: ValueKey(widget.blog.blogUid),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: context.isDark ? AppColors.darkBackground : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.blog.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.blog.content,
                        style: GoogleFonts.robotoMono(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
