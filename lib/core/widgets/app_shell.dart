import 'package:flutter/material.dart';
import 'package:raigon_art/app/app_router.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/features/customers/presentation/widgets/add_customer_dialog.dart';
import 'package:raigon_art/core/widgets/app_sidebar.dart';
import 'package:raigon_art/core/widgets/app_snackbar.dart';
import 'package:raigon_art/core/widgets/app_top_bar.dart';
import 'package:raigon_art/core/widgets/notification_mock.dart';
import 'package:raigon_art/core/widgets/notification_panel.dart';
import 'package:raigon_art/features/customers/presentation/screens/customers_screen.dart';
import 'package:raigon_art/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:raigon_art/features/frame_sizes/presentation/screens/frame_sizes_screen.dart';
import 'package:raigon_art/features/orders/presentation/screens/orders_screen.dart';
import 'package:raigon_art/features/photo_collection/presentation/screens/photo_collection_screen.dart';
import 'package:raigon_art/features/settings/presentation/screens/settings_screen.dart';
import 'package:raigon_art/features/shell/presentation/shell_scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavDestination _current = NavDestination.dashboard;
  bool? _collapsedOverride;
  bool _showNotifications = false;

  bool get _collapsed =>
      _collapsedOverride ?? MediaQuery.of(context).size.width < 1000;

  void _goTo(NavDestination d) {
    setState(() {
      _current = d;
      _showNotifications = false;
    });
  }

  void _openAddCustomer() {
    showAddCustomerDialog(context);
  }

  void _logout() {
    AppSnackBar.success(context, 'Logged out successfully.');
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.auth, (_) => false);
  }

  Widget _page() => switch (_current) {
    NavDestination.dashboard => const DashboardScreen(),
    NavDestination.customers => const CustomersScreen(),
    NavDestination.orders => const OrdersScreen(),
    NavDestination.photoCollection => const PhotoCollectionScreen(),
    NavDestination.frameSizes => const FrameSizesScreen(),
    NavDestination.settings => const SettingsScreen(),
    _ => _PlaceholderScreen(title: _current.label),
  };

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return ShellScope(
      goTo: _goTo,
      openAddCustomer: _openAddCustomer,
      child: Scaffold(
        backgroundColor: p.pageBg,
        body: Stack(
          children: [
            Row(
              children: [
                AppSidebar(
                  collapsed: _collapsed,
                  current: _current,
                  onToggle: () =>
                      setState(() => _collapsedOverride = !_collapsed),
                  onSelect: _goTo,
                  onLogout: _logout,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                        child: AppTopBar(
                          notificationCount: mockNotifications.length,
                          onBellTap: () => setState(
                            () => _showNotifications = !_showNotifications,
                          ),
                        ),
                      ),
                      Expanded(
                        child: KeyedSubtree(
                          key: ValueKey(_current),
                          child: _page(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showNotifications) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _showNotifications = false),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                top: 76,
                right: 28,
                child: NotificationPanel(
                  onClose: () => setState(() => _showNotifications = false),
                  onViewDetails: () => _goTo(NavDestination.orders),
                  onViewAll: () => _goTo(NavDestination.orders),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
      ),
    );
  }
}
