import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CafeScopeSBYApp(),
    ),
  );
}

class CafeScopeSBYApp extends ConsumerWidget {
  const CafeScopeSBYApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'CafeScope SBY',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: appRoutes,
  );
});