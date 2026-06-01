import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cafescope_sby/presentation/screens/splash_screen.dart';
import 'package:cafescope_sby/presentation/screens/home_screen.dart';
import 'package:cafescope_sby/presentation/screens/cafe_detail_screen.dart';
import 'package:cafescope_sby/presentation/screens/map_page.dart';
import 'package:cafescope_sby/presentation/screens/favorites_screen.dart';

enum AppRoute {
  splash(name: 'splash', path: '/'),
  home(name: 'home', path: '/home'),
  cafeDetail(name: 'cafeDetail', path: '/cafe/:id'),
  map(name: 'map', path: '/map'),
  favorites(name: 'favorites', path: '/favorites');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
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
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: AppRoute.cafeDetail.path,
    name: AppRoute.cafeDetail.name,
    builder: (context, state) {
      final cafeId = state.pathParameters['id'] ?? '';
      return CafeDetailScreen(cafeId: cafeId);
    },
  ),
  GoRoute(
    path: AppRoute.map.path,
    name: AppRoute.map.name,
    builder: (context, state) => const MapPage(),
  ),
  GoRoute(
    path: AppRoute.favorites.path,
    name: AppRoute.favorites.name,
    builder: (context, state) => const FavoritesScreen(),
  ),
];