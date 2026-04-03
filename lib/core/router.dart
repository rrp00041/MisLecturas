import 'package:flutter/material.dart';

import '../features/analytics/analytics_page.dart';
import '../features/auth/login_page.dart';
import '../features/books/library_page.dart';

final appRouter = _SimpleRouter();

class _SimpleRouter extends RouterConfig<Object> {
  @override
  late final RouterDelegate<Object> routerDelegate = _AppRouterDelegate();

  @override
  late final RouteInformationParser<Object> routeInformationParser =
      _AppRouteParser();
}

class _AppRouteParser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation.location ?? '/';
  }
}

class _AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const LoginPage(),
      const LibraryPage(),
      const AnalyticsPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          _index = value;
          notifyListeners();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Auth'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Libros'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
        ],
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
