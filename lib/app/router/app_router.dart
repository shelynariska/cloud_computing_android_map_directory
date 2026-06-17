import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cafescope_sby/presentation/screens/splash_screen.dart';
import 'package:cafescope_sby/presentation/screens/home_screen.dart';
import 'package:cafescope_sby/presentation/screens/cafe_detail_screen.dart';
import 'package:cafescope_sby/presentation/screens/map_page.dart';
import 'package:cafescope_sby/presentation/screens/favorites_screen.dart';
import 'package:cafescope_sby/presentation/screens/login_screen.dart';
import 'package:cafescope_sby/presentation/screens/register_screen.dart';
import 'package:cafescope_sby/presentation/screens/profile_screen.dart';

enum AppRoute {
  splash(name: 'splash', path: '/'),
  home(name: 'home', path: '/home'),
  cafeDetail(name: 'cafeDetail', path: '/cafe/:id'),
  map(name: 'map', path: '/map'),
  favorites(name: 'favorites', path: '/favorites'),
  login(name: 'login', path: '/login'),
  register(name: 'register', path: '/register'),
  profile(name: 'profile', path: '/profile');


  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}

Page<void> _noTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; 
    },
  );
}

final List<RouteBase> appRoutes = [
  GoRoute(
    path: AppRoute.splash.path,
    name: AppRoute.splash.name,
    builder: (context, state) => const SplashScreen(), 
    redirect: (context, state) async {
      await Future.delayed(const Duration(seconds: 2));
      return AppRoute.home.path;
    },
  ),
  GoRoute(
    path: AppRoute.home.path,
    name: AppRoute.home.name,
    pageBuilder: (context, state) => _noTransitionPage(const HomeScreen()),
  ),
  GoRoute(
    path: AppRoute.cafeDetail.path,
    name: AppRoute.cafeDetail.name,
    pageBuilder: (context, state) {
      final cafeId = state.pathParameters['id'] ?? '';
      return _noTransitionPage(CafeDetailScreen(cafeId: cafeId));
    },
  ),
  GoRoute(
    path: AppRoute.map.path,
    name: AppRoute.map.name,
    pageBuilder: (context, state) => _noTransitionPage(const MapPage()),
  ),
  GoRoute(
    path: AppRoute.favorites.path,
    name: AppRoute.favorites.name,
    pageBuilder: (context, state) => _noTransitionPage(const FavoritesScreen()),
  ),
  GoRoute(
    path: AppRoute.login.path,
    name: AppRoute.login.name,
    pageBuilder: (context, state) => _noTransitionPage(const LoginScreen()),
  ),
  GoRoute(
    path: AppRoute.register.path,
    name: AppRoute.register.name,
    pageBuilder: (context, state) => _noTransitionPage(const RegisterScreen()),
  ),
  GoRoute(
    path: AppRoute.profile.path,
    name: AppRoute.profile.name,
    pageBuilder: (context, state) => _noTransitionPage(const ProfileScreen()),
  ),
];