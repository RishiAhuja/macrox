import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/animated_popup/animated_popup.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_bloc.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_event.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String username;
  final String bio;
  final Map<String, dynamic> socials;
  const EditProfilePage(
      {super.key,
      required this.name,
      required this.username,
      required this.bio,
      required this.socials});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      _instagramController.text = widget.socials['instagram'] ?? '';
      _linkedinController.text = widget.socials['linkedin'] ?? '';
      _twitterController.text = widget.socials['twitter'] ?? '';
      _githubController.text = widget.socials['github'] ?? '';
      _nameController.text = widget.name;
      _bioController.text = widget.bio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileBloc(),
      child: Scaffold(
        appBar: const BasicAppBar(isLanding: false),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: SizedBox(
              width: context.isMobile
                  ? double.infinity
                  : MediaQuery.of(context).size.width * .41,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: context.isMobile ? 25 : 40,
                          ),
                        ),
                        Text(
                          'Manage your profile',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: context.isMobile ? 18 : 24,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                            width: context.isMobile ? double.infinity : 200,
                            child: const Divider()),
                        const SizedBox(height: 20),
                        _nameField(),
                        const SizedBox(height: 20),
                        _bioField(),
                        const SizedBox(height: 30),
                        Text(
                          'Socials',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: context.isMobile ? 18 : 24,
                          ),
                        ),
                        Text(
                          'The social links will show up on your profile.',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: context.isMobile ? 12 : 18,
                              color: Colors.grey),
                        ),
                        SizedBox(
                            width: context.isMobile ? double.infinity : 200,
                            child: const Divider()),
                        const SizedBox(height: 20),
                        _socialField('X/Twitter', _twitterController),
                        const SizedBox(height: 20),
                        _socialField('Github', _githubController),
                        const SizedBox(height: 20),
                        _socialField('Linkedin', _linkedinController),
                        const SizedBox(height: 20),
                        _socialField('Instagram', _instagramController),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  BlocConsumer<EditProfileBloc, EditProfileState>(
                    listener: (context, state) {
                      if (state is EditProfileSuccess) {
                        customAnimatedSnackbar(
                            context,
                            'Profile Edited Successfully',
                            Colors.green,
                            Icons.check);
                      }
                      if (state is EditProfileError) {
                        customAnimatedSnackbar(
                            context, state.message, Colors.red, Icons.error);
                      }
                    },
                    builder: (context, state) {
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              // borderRadius: BorderRadius.circular(30),
                              color: context.isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightLightBackground,
                              // border: Border.all(color: Colors.grey)
                              border: const Border(
                                  top: BorderSide(color: Colors.grey))),
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: BasicButton(
                                        onPressed: () {
                                          context.read<EditProfileBloc>().add(
                                                  UpdateProfile(
                                                      name: _nameController.text
                                                          .trim(),
                                                      username: widget.username,
                                                      bio: _bioController.text
                                                          .trim(),
                                                      socials: {
                                                    'instagram':
                                                        _instagramController
                                                            .text,
                                                    'linkedin':
                                                        _linkedinController
                                                            .text,
                                                    'twitter':
                                                        _twitterController.text,
                                                    'github':
                                                        _githubController.text
                                                  }));
                                        },
                                        width: 100,
                                        customWidget: (state
                                                is EditProfileLoading)
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                'Update',
                                                style: GoogleFonts.robotoMono(
                                                    fontSize: 18),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20)
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: GoogleFonts.spaceGrotesk(fontSize: context.isMobile ? 14 : 18),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: context.isMobile
              ? double.infinity
              : MediaQuery.of(context).size.width * .4,
          child: TextFormField(
            controller: _nameController,
            style: GoogleFonts.robotoMono(),
            cursorColor: AppColors.primaryLight,
          ),
        )
      ],
    );
  }

  Widget _bioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: GoogleFonts.spaceGrotesk(fontSize: context.isMobile ? 14 : 18),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: context.isMobile
              ? double.infinity
              : MediaQuery.of(context).size.width * .4,
          child: TextFormField(
            controller: _bioController,
            maxLines: 4,
            style: GoogleFonts.robotoMono(),
            cursorColor: AppColors.primaryLight,
          ),
        )
      ],
    );
  }

  Widget _socialField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(fontSize: context.isMobile ? 14 : 18),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: context.isMobile
              ? double.infinity
              : MediaQuery.of(context).size.width * .4,
          child: TextFormField(
            controller: controller,
            maxLines: 1,
            style: GoogleFonts.robotoMono(),
            cursorColor: AppColors.primaryLight,
          ),
        )
      ],
    );
  }
}
