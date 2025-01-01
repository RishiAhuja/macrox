import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/common/widgets/neomorphic/blurry_container.dart';
import 'package:blog/core/configs/assets/app_images.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_event.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SignIn extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home', extra: state.userEntity);
        }
        if (state is AuthError) {
          _animatedAppbar(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        return Scaffold(
          // drawer: context.isMobile ? const BasicDrawer() : null,
          // appBar: const BasicAppBar(),
          body: Center(
              child: Row(
            children: [
              if (!context.isMobile)
                Expanded(
                  flex: 1,
                  child: BlurryGrainyContainer(
                    blur: 8.0,
                    grainOpacity: 0.1,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppImages.mesh),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _emailField(context, context.isMobile),
                            _passwordField(context, context.isMobile)
                          ],
                        )),
                    BasicButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(SignInRequested(
                                email: _emailController.text,
                                password: _passwordController.text));
                          }
                        },
                        dynamic: true,
                        width: context.isMobile ? 200 : 20.w,
                        customWidget: (state is AuthLoading)
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              )
                            : Text('Log In',
                                style: GoogleFonts.robotoMono(
                                    color: Colors.black,
                                    fontSize: (context.isMobile ? 18 : 24)))),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: _redirectLogin())
                  ],
                ),
              ),
            ],
          )),
        );
      },
    );
  }

  InputDecoration _inputDecor(String label, String hint, IconData icon) {
    return InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        focusColor: AppColors.primaryLight,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        prefixIcon: Icon(icon),
        hintStyle: GoogleFonts.robotoMono(),
        floatingLabelStyle:
            GoogleFonts.robotoMono(color: AppColors.primaryLight),
        filled: false,
        labelStyle: GoogleFonts.robotoMono(),
        fillColor: Colors.transparent);
  }

  Widget _emailField(BuildContext context, bool isMobile) {
    return Container(
      width: isMobile ? 230 : MediaQuery.of(context).size.width / 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextFormField(
          style: GoogleFonts.robotoMono(),
          cursorColor: AppColors.primaryLight,
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: _inputDecor('Email', 'Enter your email', Icons.email)),
    );
  }

  Widget _passwordField(BuildContext context, bool isMobile) {
    return Container(
      width: isMobile ? 230 : MediaQuery.of(context).size.width / 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextFormField(
          style: GoogleFonts.robotoMono(),
          controller: _passwordController,
          cursorColor: AppColors.primaryLight,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration:
              _inputDecor('Password', 'Enter your password', Icons.password)),
    );
  }

  Widget _redirectLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Don't have an account?",
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        Text('Sign up',
            style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline)),
      ],
    );
  }

  void _animatedAppbar(BuildContext context, String errorMessage) {
    return AnimatedSnackBar(
      builder: ((context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(255, 249, 79, 67)),
          padding: const EdgeInsets.all(8),
          height: 50,
          child: Row(
            children: [
              const Icon(Icons.error_outline_sharp, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                errorMessage,
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
      desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
    ).show(context);
  }
}
