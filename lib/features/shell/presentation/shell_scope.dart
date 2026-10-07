import 'package:flutter/material.dart';

enum NavDestination {
  dashboard,
  customers,
  addCustomer,
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
        NavDestination.addCustomer => 'Add New Customer',
        NavDestination.orders => 'Orders',
        NavDestination.photoCollection => 'Photo Collection',
        NavDestination.frameSizes => 'Frame Sizes',
        NavDestination.reports => 'Reports',
        NavDestination.settings => 'Settings',
      };

  IconData get icon => switch (this) {
        NavDestination.dashboard => Icons.pie_chart,
        NavDestination.customers => Icons.groups,
        NavDestination.addCustomer => Icons.person_add,
        NavDestination.orders => Icons.move_to_inbox,
        NavDestination.photoCollection => Icons.photo_library,
        NavDestination.frameSizes => Icons.straighten,
        NavDestination.reports => Icons.bar_chart,
        NavDestination.settings => Icons.tune,
      };
}

class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.goTo, required super.child});

  final void Function(NavDestination destination) goTo;

  static ShellScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>()!;

  @override
  bool updateShouldNotify(ShellScope oldWidget) => false;
}
