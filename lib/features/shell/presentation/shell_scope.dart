import 'package:flutter/material.dart';

enum NavDestination {
  dashboard,
  customers,
  orders,
  photoCollection,
  frameSizes,
  reports,
  settings,
}

extension NavDestinationX on NavDestination {
  String get label => switch (this) {
    NavDestination.dashboard => 'Dashboard',
    NavDestination.customers => 'Customers',
    NavDestination.orders => 'Orders',
    NavDestination.photoCollection => 'Photo Collection',
    NavDestination.frameSizes => 'Frame Sizes',
    NavDestination.reports => 'Reports',
    NavDestination.settings => 'Settings',
  };

  IconData get icon => switch (this) {
    NavDestination.dashboard => Icons.pie_chart,
    NavDestination.customers => Icons.groups,
    NavDestination.orders => Icons.move_to_inbox,
    NavDestination.photoCollection => Icons.photo_library,
    NavDestination.frameSizes => Icons.straighten,
    NavDestination.reports => Icons.bar_chart,
    NavDestination.settings => Icons.tune,
  };
}

class ShellScope extends InheritedWidget {
  const ShellScope({
    super.key,
    required this.goTo,
    required this.openAddCustomer,
    required super.child,
  });

  final ValueChanged<NavDestination> goTo;
  final VoidCallback openAddCustomer;

  static ShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellScope>();

    assert(scope != null, 'ShellScope not found in widget tree.');

    return scope!;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) {
    return goTo != oldWidget.goTo ||
        openAddCustomer != oldWidget.openAddCustomer;
  }
}
