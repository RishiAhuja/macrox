import 'package:blog/presentation/auth/screens/signin.dart';
import 'package:blog/presentation/auth/screens/signup.dart';
import 'package:blog/presentation/blog_editor/screen/blog_editor.dart';
import 'package:blog/presentation/landing/landing.dart';
import 'package:blog/presentation/preview/screen/blog_preview.dart';
import 'package:blog/presentation/profile/screen/edit_profile.dart';
import 'package:blog/presentation/profile/screen/profile_page.dart';
import 'package:blog/presentation/shared/screen/main_container_page.dart';
import 'package:blog/presentation/users/screen/users.dart';
import 'package:go_router/go_router.dart';

class AppRouterConstants {
  static const String newblog = '/editor';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String explore = '/explore';
  static const String home = '/home';
}

class AppRouter {
  final GoRouter router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const Landing()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUp()),
    GoRoute(path: '/signin', builder: (context, state) => SignIn()),
    GoRoute(path: '/login', builder: (context, state) => SignIn()),
    GoRoute(path: '/users', builder: (context, state) => const Users()),
    GoRoute(
        path: '${AppRouterConstants.newblog}/:uid',
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          return BlogEditor(
            published: extra?['published'] ?? false,
            userUid: extra?['userUid'] ?? '',
            uid: state.pathParameters['uid'] ?? '',
            title: extra?['title'],
            content: extra?['content'],
            htmlPreview: extra?['htmlPreview'],
          );
        }),
    GoRoute(
      path: '/home',
      name: AppRouterConstants.home,
      builder: (context, state) => const MainContainerPage(initialTabIndex: 0),
    ),
    GoRoute(
      path: '/explore',
      name: AppRouterConstants.explore,
      builder: (context, state) => const MainContainerPage(initialTabIndex: 1),
    ),
    GoRoute(
      path: '/blog/@:username/:uid',
      builder: (context, state) => const BlogPreview(),
    ),
    GoRoute(
      path: AppRouterConstants.profileEdit,
      builder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        return EditProfilePage(
          name: extra!['name'],
          bio: extra['bio'],
          username: extra['username'],
          socials: {
            'twitter': extra['socials']['twitter'] ?? '',
            'github': extra['socials']['github'] ?? '',
            'linkedin': extra['socials']['linkedin'] ?? '',
            'instagram': extra['socials']['instagram'] ?? '',
          },
        );
      },
    ),
    GoRoute(
      path: '${AppRouterConstants.profile}/@:username',
      builder: (context, state) {
        // final Map<String, dynamic>? extra =
        //     state.extra as Map<String, dynamic>?;
        return const ProfilePage(
            // email: extra!['email'],
            // name: extra['name'],
            // userUid: extra['userUid'],
            // username: extra['username'],
            );
      },
    ),
  ]);
}
