import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizza_app_admin/src/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app_admin/src/modules/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app_admin/src/modules/auth/views/login_screen.dart';
import 'package:pizza_app_admin/src/modules/base/views/base_screen.dart';
import 'package:pizza_app_admin/src/modules/create_pizza/blocs/upload_picture_bloc/upload_picture_bloc.dart';
import 'package:pizza_app_admin/src/modules/create_pizza/views/create_pizza_screen.dart';
import 'package:pizza_app_admin/src/modules/home/views/home_screen.dart';
import 'package:pizza_app_admin/src/modules/splash/views/splash_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';

/*

THIS IS WHERE WE ARE IMPLEMENTING ALL OF OUR DIFFERENT ROUTES

*/

// Global navigation key
final _navKey = GlobalKey<NavigatorState>();

final _shellNavigationKey = GlobalKey<NavigatorState>();

GoRouter router(AuthenticationBloc authBloc) {
  return GoRouter(
    navigatorKey: _navKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (authBloc.state.status == AuthenticationStatus.unknown) {
        return '/';
      }
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigationKey,
        builder: (context, state, child) {
          if (state.fullPath == '/login' || state.fullPath == '/') {
            return child;
          } else {
            return BlocProvider(
              create: (context) => SignInBloc(
                context.read<AuthenticationBloc>().userRepository,
              ),
              child: BaseScreen(child),
            );
          }
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<AuthenticationBloc>.value(
              value: BlocProvider.of<AuthenticationBloc>(context),
              child: const SplashScreen(),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => BlocProvider<AuthenticationBloc>.value(
              value: BlocProvider.of<AuthenticationBloc>(context),
              child: BlocProvider<SignInBloc>(
                create: (context) => SignInBloc(
                  context.read<AuthenticationBloc>().userRepository,
                ),
                child: const SignInScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => BlocProvider(
              create: (context) => UploadPictureBloc(FirebasePizzaRepo()),
              child: const CreatePizzaScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
