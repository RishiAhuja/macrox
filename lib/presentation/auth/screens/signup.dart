import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/animated_popup/animated_popup.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_event.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home', extra: state.userEntity);
        }
        if (state is AuthError) {
          failureAnimatedSnackbar(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor:
              isDark ? NexusColors.darkBackground : NexusColors.lightBackground,
          body: Center(
            child: Row(
              children: [
                if (!isMobile)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? NexusColors.darkSurface : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(5, 0),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        NexusColors.darkSurface,
                                        NexusColors.darkBackground
                                      ]
                                    : [
                                        NexusColors.lightBackground,
                                        Colors.white
                                      ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: -50,
                            top: screenHeight * 0.2,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    NexusColors.primaryBlue.withOpacity(0.4),
                                    NexusColors.primaryBlue.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -30,
                            bottom: screenHeight * 0.3,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    NexusColors.primaryPurple.withOpacity(0.3),
                                    NexusColors.primaryPurple.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: screenWidth * 0.15,
                            top: screenHeight * 0.35,
                            child: Container(
                              width: 120,
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    NexusColors.nexusTeal.withOpacity(0.0),
                                    NexusColors.nexusTeal.withOpacity(0.8),
                                    NexusColors.nexusTeal.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        NexusColors.gradientStart,
                                        NexusColors.gradientEnd,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: NexusColors.primaryBlue
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.hub,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  "NEXUS",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : NexusColors.signalGreen,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Create. Connect. Broadcast.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 50),
                                Container(
                                  width: 180,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? NexusColors.darkSurface
                                            .withOpacity(0.7)
                                        : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Already connected?",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextButton(
                                        onPressed: () => context.go('/login'),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: const BorderSide(
                                              color: NexusColors.primaryBlue,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "CONNECT",
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: NexusColors.primaryBlue,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  flex: isMobile ? 1 : 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 40,
                      vertical: 40,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 30),
                            width:
                                isMobile ? double.infinity : screenWidth / 2.8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isMobile) const SizedBox(height: 30),
                                Text(
                                  'Join the Network',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: isMobile ? 28 : 36,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Establish your connection to the Nexus',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: isMobile ? 16 : 18,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width:
                                isMobile ? double.infinity : screenWidth / 2.8,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 30,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? NexusColors.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : NexusColors.signalGray.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildInputField(
                                    controller: _nameController,
                                    label: 'Display Name',
                                    hint: 'Jane Smith',
                                    icon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    controller: _usernameController,
                                    label: 'Signal Identifier',
                                    hint: 'janesmith',
                                    icon: Icons.alternate_email,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a username';
                                      }
                                      if (!RegExp(r'^[a-zA-Z0-9_-]+$')
                                          .hasMatch(value)) {
                                        return 'Username can only contain letters, numbers, - and _';
                                      }
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    controller: _emailController,
                                    label: 'Network Identifier (Email)',
                                    hint: 'jane.smith@example.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    controller: _passwordController,
                                    label: 'Acess Key',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please create an access key';
                                      }
                                      if (value.length < 6) {
                                        return 'Access key must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 25),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<AuthBloc>()
                                            .add(SignUpRequested(
                                              username: _usernameController.text
                                                  .toLowerCase()
                                                  .trim(),
                                              name: _nameController.text.trim(),
                                              email:
                                                  _emailController.text.trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                            ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: NexusColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 16,
                                      ),
                                      elevation: 3,
                                      shadowColor: NexusColors.primaryBlue
                                          .withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: (state is AuthLoading)
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Establish Connection',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Mobile login link
                          if (isMobile)
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: GestureDetector(
                                onTap: () => context.go('/login'),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Already connected? '),
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                          color: NexusColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
      cursorColor: NexusColors.primaryBlue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: isDark
              ? NexusColors.primaryBlue.withOpacity(0.7)
              : NexusColors.primaryBlue.withOpacity(0.6),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : NexusColors.lightBackground.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : NexusColors.signalGray.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: NexusColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: NexusColors.dataOrange,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: NexusColors.dataOrange,
            width: 1.5,
          ),
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: isDark ? Colors.white70 : NexusColors.signalGray,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.spaceGrotesk(
          color:
              isDark ? Colors.white30 : NexusColors.signalGray.withOpacity(0.7),
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.spaceGrotesk(
          color: NexusColors.primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
