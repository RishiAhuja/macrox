import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/common/widgets/appbar/drawer.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          print(state.userEntity.email);
          context.go('/home', extra: state.userEntity);
        }
      },
      child: Scaffold(
          drawer: context.isMobile ? const BasicDrawer() : null,
          appBar: const BasicAppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'The place you tinker. The place you learn.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BasicButton(
                      onPressed: () {
                        context.go('/signup');
                      },
                      text: 'Sign up',
                      dynamic: true,
                    ),
                    BasicButton(
                      onPressed: () {
                        context.go('/signin');
                      },
                      text: 'Login',
                      color: Colors.white,
                      dynamic: true,
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

//space grotesk
