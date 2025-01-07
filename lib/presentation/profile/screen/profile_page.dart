import 'package:blog/common/helper/extensions/get_initials.dart';
import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/profile/bloc/follow_bloc/follow_bloc.dart';
import 'package:blog/presentation/profile/bloc/profile_data_bloc/profile_bloc.dart';
import 'package:blog/presentation/profile/bloc/profile_data_bloc/profile_event.dart';
import 'package:blog/presentation/profile/bloc/profile_data_bloc/profile_state.dart';
import 'package:blog/responsive/responsive_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  final String userUid;
  final String username;
  final String? name;
  final String? email;
  const ProfilePage(
      {super.key,
      required this.userUid,
      required this.username,
      this.name,
      this.email});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => ProfileBloc()..add(LoadUserData(userUid)),
        ),
        BlocProvider(
          create: (context) => FollowBloc(),
        ),
      ],
      child: ProfilePageContent(
          userUid: userUid, username: username, name: name, email: email),
    );
  }
}

class ProfilePageContent extends StatefulWidget {
  final String userUid;
  final String username;
  final String? name;
  final String? email;
  const ProfilePageContent(
      {super.key,
      required this.userUid,
      required this.username,
      this.name,
      this.email});

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  bool isLocal = false;

  @override
  void initState() {
    super.initState();
    (context.read<AuthBloc>().state is AuthSuccess)
        ? isLocal =
            (context.read<AuthBloc>().state as AuthSuccess).userEntity.id ==
                (widget.userUid)
        : isLocal = false;
    print("isLocal: $isLocal");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(
        isLanding: false,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(
                child: Column(
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
                                          name: state.userData.name,
                                          bio: state.userData.bio ?? "",
                                          username: state.userData.username,
                                          followerCount:
                                              state.userData.followerCount,
                                          followingCount:
                                              state.userData.followingCount),
                                      _infoPlaformRight(),
                                      const SizedBox(height: 18),
                                      _joiningDate(state.userData.createdAt),
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
                                            username: state.userData.username,
                                            followerCount:
                                                state.userData.followerCount,
                                            followingCount:
                                                state.userData.followingCount),
                                        _infoPlaformRight(),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _joiningDate(state.userData.createdAt),
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
      int? followerCount}) {
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
            Text(
              bio,
              style: GoogleFonts.robotoMono(
                  fontSize: 12.sp,
                  color: context.isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
            _followStats(followingCount, followerCount),
          ],
        ),
      ],
    );
  }

  Widget _followStats(int? followingCount, int? followerCount) {
    return Row(
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
        const SizedBox(
          width: 15,
        ),
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
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                  borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.ios_share_rounded, size: 25),
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
                      followingUid: widget.userUid,
                      followerUsername: localUser.username,
                      followingUsername: widget.username));
                } else {
                  // Redirect to Edit profile
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
        return const CircularProgressIndicator(
          color: Colors.white,
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
