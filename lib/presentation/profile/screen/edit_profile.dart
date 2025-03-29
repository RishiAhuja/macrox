import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/animated_popup/animated_popup.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_bloc.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_event.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String username;
  final String bio;
  final Map<String, dynamic> socials;
  const EditProfilePage({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.socials,
  });

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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _instagramController.text = widget.socials['instagram'] ?? '';
    _linkedinController.text = widget.socials['linkedin'] ?? '';
    _twitterController.text = widget.socials['twitter'] ?? '';
    _githubController.text = widget.socials['github'] ?? '';
    _nameController.text = widget.name;
    _bioController.text = widget.bio;

    // Listen for changes to detect if user has modified anything
    _nameController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
    _instagramController.addListener(_checkForChanges);
    _linkedinController.addListener(_checkForChanges);
    _twitterController.addListener(_checkForChanges);
    _githubController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges = _nameController.text != widget.name ||
        _bioController.text != widget.bio ||
        _instagramController.text != (widget.socials['instagram'] ?? '') ||
        _linkedinController.text != (widget.socials['linkedin'] ?? '') ||
        _twitterController.text != (widget.socials['twitter'] ?? '') ||
        _githubController.text != (widget.socials['github'] ?? '');

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return BlocProvider(
      create: (context) => EditProfileBloc(),
      child: Scaffold(
        appBar: const BasicAppBar(isLanding: false),
        body: BlocConsumer<EditProfileBloc, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              customAnimatedSnackbar(
                context,
                'Profile updated successfully',
                NexusColors.successGreen,
                Icons.check_circle_outline,
              );

              // Navigate back after successful update
              Future.delayed(const Duration(seconds: 1), () {
                context.pop();
              });
            }
            if (state is EditProfileError) {
              customAnimatedSnackbar(
                context,
                state.message,
                NexusColors.errorRed,
                Icons.error_outline,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Main scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Container(
                        width: context.isMobile
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.isMobile ? 20 : 40,
                          vertical: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            _buildHeader(isDark),

                            const SizedBox(height: 30),

                            // Profile section
                            _buildSectionHeader(
                              'Profile Information',
                              'Update your personal information',
                              Icons.person_outline,
                              isDark,
                            ),

                            const SizedBox(height: 20),

                            // Name field
                            _buildTextField(
                              label: 'Display Name',
                              controller: _nameController,
                              icon: Icons.badge_outlined,
                              isDark: isDark,
                              maxLength: 50,
                            ),

                            const SizedBox(height: 24),

                            // Username field (read-only)
                            _buildTextField(
                              label: 'Username',
                              controller:
                                  TextEditingController(text: widget.username),
                              icon: Icons.alternate_email,
                              isDark: isDark,
                              readOnly: true,
                              helperText: 'Usernames cannot be changed',
                            ),

                            const SizedBox(height: 24),

                            // Bio field
                            _buildTextField(
                              label: 'Bio',
                              controller: _bioController,
                              icon: Icons.description_outlined,
                              isDark: isDark,
                              maxLines: 4,
                              maxLength: 160,
                              helperText: 'Tell others about yourself',
                            ),

                            const SizedBox(height: 40),

                            // Social links section
                            _buildSectionHeader(
                              'Social Links',
                              'Connect your other online profiles',
                              Icons.link_outlined,
                              isDark,
                            ),

                            const SizedBox(height: 20),

                            // Twitter field
                            _buildTextField(
                              label: 'X / Twitter',
                              controller: _twitterController,
                              icon: Icons.alternate_email,
                              isDark: isDark,
                              prefix: '@',
                              placeholder: 'username',
                            ),

                            const SizedBox(height: 24),

                            // GitHub field
                            _buildTextField(
                              label: 'GitHub',
                              controller: _githubController,
                              icon: Icons.code,
                              isDark: isDark,
                              prefix: '@',
                              placeholder: 'username',
                            ),

                            const SizedBox(height: 24),

                            // LinkedIn field
                            _buildTextField(
                              label: 'LinkedIn',
                              controller: _linkedinController,
                              icon: Icons.business_center_outlined,
                              isDark: isDark,
                              prefix: 'linkedin.com/in/',
                              placeholder: 'username',
                            ),

                            const SizedBox(height: 24),

                            // Instagram field
                            _buildTextField(
                              label: 'Instagram',
                              controller: _instagramController,
                              icon: Icons.camera_alt_outlined,
                              isDark: isDark,
                              prefix: '@',
                              placeholder: 'username',
                            ),

                            // Extra space at bottom for the action bar
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Fixed action bar at bottom
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? NexusColors.darkSurface : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel button
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white70 : Colors.black54,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Save button
                      ElevatedButton(
                        onPressed: _hasChanges && state is! EditProfileLoading
                            ? () {
                                FocusScope.of(context).unfocus();
                                context.read<EditProfileBloc>().add(
                                      UpdateProfile(
                                        name: _nameController.text.trim(),
                                        username: widget.username,
                                        bio: _bioController.text.trim(),
                                        socials: {
                                          'instagram':
                                              _instagramController.text.trim(),
                                          'linkedin':
                                              _linkedinController.text.trim(),
                                          'twitter':
                                              _twitterController.text.trim(),
                                          'github':
                                              _githubController.text.trim(),
                                        },
                                      ),
                                    );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NexusColors.primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          disabledForegroundColor:
                              isDark ? Colors.white38 : Colors.black38,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: state is EditProfileLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main heading
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NexusColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: NexusColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Profile',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Subheading
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            'Customize how others see you in the Nexus network',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, String subtitle, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: NexusColors.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    bool readOnly = false,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
    String? prefix,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Text field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.02),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            maxLength: maxLength,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: readOnly
                  ? isDark
                      ? Colors.white38
                      : Colors.black38
                  : isDark
                      ? Colors.white
                      : Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              counterText: '',
              hintText: placeholder,
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
              prefixText: prefix,
              prefixStyle: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
            cursorColor: NexusColors.primaryBlue,
          ),
        ),

        // Helper text
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6),
            child: Text(
              helperText,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
      ],
    );
  }
}
