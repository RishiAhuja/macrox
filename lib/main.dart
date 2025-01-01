import 'package:blog/common/router/app_router.dart';
import 'package:blog/core/configs/constants/hive_constants/hive_constants.dart';
import 'package:blog/core/configs/theme/app_theme.dart';
import 'package:blog/data/models/hive/blog_model.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/theme_shift/bloc/theme_cubit.dart';
import 'package:blog/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: appDocumentDir,
    );
  } else {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorage.webStorageDirectory,
    );
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(BlogModelAdapter());
  await Hive.openBox<BlogModel>(HiveConstants.blogsBox);
  getDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (context) => sl<AuthBloc>()),
        //creates and provides an instance of the ThemeCubit to the widget tree
        //_ is a convention to indicate that the parameter is not used but is a buildcontext injecting into the cubit
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return Sizer(
            builder: (context, orientation, screenType) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    print('authsuccess in main, redirecting to /home');
                    appRouter.router.go('/home');
                  }
                },
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Blog',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: mode,
                  routerDelegate: appRouter.router.routerDelegate,
                  routeInformationParser:
                      appRouter.router.routeInformationParser,
                  routeInformationProvider:
                      appRouter.router.routeInformationProvider,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
