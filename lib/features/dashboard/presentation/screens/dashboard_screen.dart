import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/features/customers/data/customer_model.dart';
import 'package:raigon_art/features/customers/data/customer_store.dart';
import 'package:raigon_art/features/customers/presentation/widgets/add_customer_dialog.dart';
import 'package:raigon_art/features/customers/presentation/widgets/customer_view_dialog.dart';
import 'package:raigon_art/features/shell/presentation/shell_scope.dart';
import 'package:raigon_art/features/dashboard/models/order_status.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return ValueListenableBuilder<List<Customer>>(
      valueListenable: CustomerStore.customers,
      builder: (context, customers, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard Overview',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: p.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome back, Raigon Arts Workshop Manager',
                              style: TextStyle(
                                fontSize: 15.5,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => ShellScope.of(context).openAddCustomer(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 22 : 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.darkGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_add,
                                size: 20,
                                color: Colors.white,
                              ),
                              if (wide) ...[
                                const SizedBox(width: 10),
                                const Text(
                                  'Add New Customer',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dashboard statistics
                  _StatsGrid(
                    width: constraints.maxWidth - 48,
                    customers: customers,
                  ),

                  const SizedBox(height: 24),

                  // Fill the remaining available height
                  Expanded(child: _RecentOrdersCard(customers: customers)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.width, required this.customers});
  final double width;
  final List<Customer> customers;

  static String _inr(int v) {
    final s = v.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }

  static (IconData, String) _trend(num cur, num prev) {
    if (prev == 0) return (Icons.arrow_upward, cur > 0 ? 'New' : '0%');
    final pct = ((cur - prev) / prev * 100).round();
    return (
      pct >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
      '${pct >= 0 ? '+' : ''}$pct%',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    int count(OrderStatus s) => customers.where((c) => c.status == s).length;
    final billable = customers.where((c) => c.status != OrderStatus.cancelled);
    final revenue = billable.fold<int>(0, (a, c) => a + c.total);

    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    bool sameMonth(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month;

    final ordersNow = customers
        .where((c) => sameMonth(c.orderDate, now))
        .length;
    final ordersPrev = customers
        .where((c) => sameMonth(c.orderDate, lastMonth))
        .length;
    final revNow = billable
        .where((c) => sameMonth(c.orderDate, now))
        .fold<int>(0, (a, c) => a + c.total);
    final revPrev = billable
        .where((c) => sameMonth(c.orderDate, lastMonth))
        .fold<int>(0, (a, c) => a + c.total);
    final ordersTrend = _trend(ordersNow, ordersPrev);
    final revTrend = _trend(revNow, revPrev);

    final stats = <_StatData>[
      _StatData(
        'Total Frame Orders',
        '${customers.length}',
        Icons.move_to_inbox,
        p.tileNeutral,
        p.tileNeutralIcon,
        ordersTrend.$1,
        ordersTrend.$2,
        'vs last month',
        p.textPrimary,
      ),
      _StatData(
        'In Progress',
        '${count(OrderStatus.inProgress)}',
        Icons.handyman,
        p.tileTeal,
        AppPalette.teal,
        Icons.sync,
        'Active',
        'in workshop',
        AppPalette.teal,
      ),
      _StatData(
        'Completed Orders',
        '${count(OrderStatus.completed)}',
        Icons.check_circle,
        p.tileGreen,
        AppColors.green,
        Icons.check,
        'Ready',
        'for delivery',
        AppColors.green,
      ),
      _StatData(
        'Pending Orders',
        '${count(OrderStatus.pending)}',
        Icons.watch_later,
        p.tileOrange,
        AppPalette.orange,
        Icons.warning,
        'Urgent',
        'action needed',
        AppPalette.orange,
      ),
      _StatData(
        'Total Revenue',
        _inr(revenue),
        Icons.currency_rupee,
        p.tileNeutral,
        p.tileNeutralIcon,
        revTrend.$1,
        revTrend.$2,
        'vs last month',
        p.textPrimary,
      ),
    ];
    const gap = 20.0;
    final cols = width >= 1100
        ? 5
        : width >= 700
        ? 3
        : width >= 440
        ? 2
        : 1;
    final cardWidth = (width - gap * (cols - 1)) / cols;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final s in stats)
          SizedBox(
            width: math.max(cardWidth, 0),
            child: _StatCard(data: s),
          ),
      ],
    );
  }
}

class _StatData {
  const _StatData(
    this.title,
    this.value,
    this.icon,
    this.tileBg,
    this.tileIcon,
    this.footIcon,
    this.footStrong,
    this.footLight,
    this.footColor,
  );

  final String title;
  final String value;
  final IconData icon;
  final Color tileBg;
  final Color tileIcon;
  final IconData footIcon;
  final String footStrong;
  final String footLight;
  final Color footColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: p.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.value,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: data.tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: 22, color: data.tileIcon),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(painter: _DashedLinePainter(p.rowDivider)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(data.footIcon, size: 16, color: data.footColor),
              const SizedBox(width: 4),
              Text(
                data.footStrong,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: data.footColor,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.footLight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, color: p.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}

class _RecentOrdersCard extends StatefulWidget {
  const _RecentOrdersCard({required this.customers});

  final List<Customer> customers;

  @override
  State<_RecentOrdersCard> createState() => _RecentOrdersCardState();
}

class _RecentOrdersCardState extends State<_RecentOrdersCard> {
  static const int _pageSize = 5;
  final int _page = 1;

  static String _inr(int v) => _StatsGrid._inr(v);

  static const _cols = <_Col>[
    _Col('CUSTOMER ID', 12),
    _Col('CUSTOMER NAME', 24),
    _Col('PHONE NO', 18),
    _Col('FRAME SIZE', 16),
    _Col('FRAME TYPE', 18),
    _Col('QTY', 8),
    _Col('TOTAL', 13),
    _Col('STATUS', 17),
    _Col('ACTIONS', 12),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final sortedCustomers = [...widget.customers]
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    final totalPages = math.max(1, (sortedCustomers.length / _pageSize).ceil());

    final page = _page.clamp(1, totalPages);

    final recent = sortedCustomers
        .skip((page - 1) * _pageSize)
        .take(_pageSize)
        .toList();
    return Container(
      decoration: p.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Customer Frame Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      ShellScope.of(context).goTo(NavDestination.customers),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: p.chipFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All Customers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 17,
                          color: p.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = math.max(constraints.maxWidth, 1000.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      _headerRow(p),

                      if (recent.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Text(
                            'No orders yet',
                            style: TextStyle(fontSize: 15, color: p.textMuted),
                          ),
                        )
                      else
                        for (final c in recent) _orderRow(context, p, c),
                    ],
                  ),
                ),
              );
            },
          ),
          // AppPaginationFooter(
          //   totalItems: widget.customers.length,
          //   page: page,
          //   pageSize: _pageSize,
          //   itemLabel: 'orders',
          //   onPageChanged: (newPage) {
          //     setState(() => _page = newPage);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _headerRow(AppPalette p) => Container(
    color: p.tableHeaderBg,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
    child: Row(
      children: [
        for (final c in _cols)
          Expanded(
            flex: c.flex,
            child: Text(
              c.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: p.headerText,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _orderRow(BuildContext context, AppPalette p, Customer o) {
    final cell = TextStyle(fontSize: 15, color: p.textPrimary);
    final bold = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: p.textPrimary,
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.rowDivider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: _cols[0].flex,
            child: Text(o.id, style: bold),
          ),
          Expanded(
            flex: _cols[1].flex,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    o.name.isEmpty ? '?' : o.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: p.textPrimary,
                        ),
                      ),
                      Text(
                        o.city,
                        style: TextStyle(fontSize: 13, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _cols[2].flex,
            child: Text(o.phone, style: cell),
          ),
          Expanded(
            flex: _cols[3].flex,
            child: Text(o.frameSize, style: cell),
          ),
          Expanded(
            flex: _cols[4].flex,
            child: Text(o.frameType, style: cell),
          ),
          Expanded(
            flex: _cols[5].flex,
            child: Text('${o.qty}', style: bold),
          ),
          Expanded(
            flex: _cols[6].flex,
            child: Text(_inr(o.total), style: bold),
          ),
          Expanded(
            flex: _cols[7].flex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(status: o.status),
            ),
          ),
          Expanded(
            flex: _cols[8].flex,
            child: Row(
              children: [
                InkWell(
                  onTap: () => showViewCustomerDialog(context, o),
                  child: Icon(Icons.visibility, size: 21, color: p.textPrimary),
                ),
                const SizedBox(width: 18),
                InkWell(
                  onTap: () => showEditCustomerDialog(context, o),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: p.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Col {
  const _Col(this.label, this.flex);
  final String label;
  final int flex;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.inProgress => ('In Progress', AppPalette.statusGold),
      OrderStatus.completed => ('Completed', AppPalette.statusGreen),
      OrderStatus.pending => ('Pending', AppPalette.statusGold),
      OrderStatus.cancelled => ('Cancelled', AppPalette.statusRed),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
