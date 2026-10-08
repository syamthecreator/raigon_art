import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/features/customers/data/customer_mock.dart';
import 'package:raigon_art/features/customers/data/customer_store.dart';
import 'package:raigon_art/features/dashboard/data/dashboard_mock.dart';
import 'package:raigon_art/features/shell/presentation/shell_scope.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // null = All
  OrderStatus? _filter;
  String _query = '';

  /// Local status overrides made through the status dropdown.
  final Map<String, OrderStatus> _statusOverride = {};

  // Column flex values:
  // id, customer, phone, photos, specs, qty, total, payment, status, delivery, actions
  static const _flex = [
    15, // Order ID
    20, // Customer
    19, // Phone
    14, // Photos
    20, // Frame Specs
    10, // Qty
    20, // Total
    23, // Payment
    25, // Status
    23, // Delivery
    22, // Actions
  ];
  static const _headers = [
    'ORDER ID',
    'CUSTOMER',
    'PHONE NO',
    'PHOTOS',
    'FRAME SPECS',
    'QTY',
    'TOTAL AMOUNT',
    'PAYMENT',
    'ORDER STATUS',
    'DELIVERY DATE',
    'ACTIONS',
  ];

  OrderStatus _statusOf(Customer c) => _statusOverride[c.id] ?? c.status;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _date(DateTime? d) => d == null
      ? 'N/A'
      : '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

  Color _statusColor(OrderStatus s) => switch (s) {
    OrderStatus.inProgress => AppPalette.statusGold,
    OrderStatus.pending => AppPalette.orange,
    OrderStatus.completed => AppPalette.statusGreen,
    OrderStatus.cancelled => AppPalette.statusRed,
  };

  String _statusLabel(OrderStatus s) => switch (s) {
    OrderStatus.inProgress => 'In Progress',
    OrderStatus.pending => 'Pending',
    OrderStatus.completed => 'Completed',
    OrderStatus.cancelled => 'Cancelled',
  };

  String _paymentOf(Customer c) {
    if (c.advance <= 0) return 'Unpaid';
    if (c.advance >= c.total) return 'Paid';
    return 'Partial';
  }

  Color _paymentColor(String s) => switch (s) {
    'Paid' => AppPalette.statusGreen,
    'Partial' => AppPalette.statusGold,
    _ => AppPalette.statusRed,
  };

  String _money(int v) {
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

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return ValueListenableBuilder<List<Customer>>(
      valueListenable: CustomerStore.customers,
      builder: (context, all, _) {
        int count(OrderStatus? s) =>
            s == null ? all.length : all.where((c) => _statusOf(c) == s).length;

        final q = _query.trim().toLowerCase();
        final rows = all.where((c) {
          if (_filter != null && _statusOf(c) != _filter) return false;
          if (q.isEmpty) return true;
          return c.id.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleRow(p),
              const SizedBox(height: 28),
              _tabs(p, count),
              const SizedBox(height: 24),
              Container(
                decoration: p.card(radius: 16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _searchField(p),
                    ),
                    _table(p, rows),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── Title row ─────────────────────────

  Widget _titleRow(AppPalette p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Management',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track, update and manage wholesale & retail custom frame orders',
                style: TextStyle(fontSize: 14.5, color: p.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.darkGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => ShellScope.of(context).openAddCustomer(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt_1, size: 20, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Add New Customer',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Tabs ─────────────────────────

  Widget _tabs(AppPalette p, int Function(OrderStatus?) count) {
    final items = <(String, OrderStatus?)>[
      ('All', null),
      ('Pending', OrderStatus.pending),
      ('In Progress', OrderStatus.inProgress),
      ('Completed', OrderStatus.completed),
      ('Cancelled', OrderStatus.cancelled),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (label, status) in items)
              InkWell(
                onTap: () => setState(() => _filter = status),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _filter == status
                            ? AppColors.gold
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    '$label (${count(status)})',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: _filter == status ? AppColors.gold : p.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Search ─────────────────────────

  Widget _searchField(AppPalette p) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 340,
        height: 44,
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          cursorColor: p.textPrimary,
          style: TextStyle(fontSize: 14.5, color: p.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search order ID, customer name...',
            hintStyle: TextStyle(fontSize: 14.5, color: p.textMuted),
            prefixIcon: Icon(Icons.search, size: 22, color: p.textMuted),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: p.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.gold),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Table ─────────────────────────

  Widget _table(AppPalette p, List<Customer> rows) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = math.max(c.maxWidth, 1240.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: w,
            child: Column(
              children: [
                _headerRow(p),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'No orders found',
                      style: TextStyle(fontSize: 15, color: p.textMuted),
                    ),
                  )
                else
                  for (var i = 0; i < rows.length; i++)
                    _OrderRow(
                      p: p,
                      customer: rows[i],
                      isLast: i == rows.length - 1,
                      flex: _flex,
                      status: _statusOf(rows[i]),
                      statusColor: _statusColor,
                      statusLabel: _statusLabel,
                      payment: _paymentOf(rows[i]),
                      paymentColor: _paymentColor,
                      totalLabel: _money(rows[i].total),
                      deliveryLabel: _statusOf(rows[i]) == OrderStatus.cancelled
                          ? 'N/A'
                          : _date(rows[i].expectedDelivery),
                      onStatus: (s) =>
                          setState(() => _statusOverride[rows[i].id] = s),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerRow(AppPalette p) {
    return Container(
      height: 50,
      color: p.tableHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < _headers.length; i++)
            Expanded(
              flex: _flex[i],
              child: Text(
                _headers[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: p.headerText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Row ─────────────────────────

class _OrderRow extends StatefulWidget {
  const _OrderRow({
    required this.p,
    required this.customer,
    required this.isLast,
    required this.flex,
    required this.status,
    required this.statusColor,
    required this.statusLabel,
    required this.payment,
    required this.paymentColor,
    required this.totalLabel,
    required this.deliveryLabel,
    required this.onStatus,
  });

  final AppPalette p;
  final Customer customer;
  final bool isLast;
  final List<int> flex;
  final OrderStatus status;
  final Color Function(OrderStatus) statusColor;
  final String Function(OrderStatus) statusLabel;
  final String payment;
  final Color Function(String) paymentColor;
  final String totalLabel;
  final String deliveryLabel;
  final ValueChanged<OrderStatus> onStatus;

  @override
  State<_OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<_OrderRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final c = widget.customer;
    final f = widget.flex;

    Widget cell(int i, Widget child) => Expanded(
      flex: f[i],
      child: Align(alignment: Alignment.centerLeft, child: child),
    );

    TextStyle body({FontWeight w = FontWeight.w500}) =>
        TextStyle(fontSize: 15, fontWeight: w, color: p.textPrimary);

    final spec = c.effectiveFrames.first;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _hover
              ? (p.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFFCFBF8))
              : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(top: BorderSide(color: p.rowDivider)),
        ),
        child: Row(
          children: [
            cell(0, Text(c.id, style: body(w: FontWeight.w700))),
            cell(1, Text(c.name, style: body(w: FontWeight.w600))),
            cell(2, Text(c.phone, style: body())),
            cell(3, Text('${c.photoCount} Photos', style: body())),
            cell(
              4,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.frameSize, style: body()),
                  const SizedBox(height: 2),
                  Text(
                    c.frameType.isNotEmpty ? c.frameType : spec.frameType,
                    style: TextStyle(fontSize: 12.5, color: p.textMuted),
                  ),
                ],
              ),
            ),
            cell(5, Text('${c.qty}', style: body(w: FontWeight.w700))),
            cell(6, Text(widget.totalLabel, style: body(w: FontWeight.w700))),
            cell(7, _paymentChip()),
            cell(8, _statusDropdown()),
            cell(9, Text(widget.deliveryLabel, style: body())),
            cell(10, _actions()),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip() {
    final color = widget.paymentColor(widget.payment);
    return Container(
      width: 120,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.payment,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _statusDropdown() {
    final color = widget.statusColor(widget.status);
    return PopupMenuButton<OrderStatus>(
      tooltip: '',
      onSelected: widget.onStatus,
      offset: const Offset(0, 38),
      color: widget.p.surface,
      itemBuilder: (_) => [
        for (final s in OrderStatus.values)
          PopupMenuItem(
            value: s,
            child: Text(
              widget.statusLabel(s),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.statusColor(s),
              ),
            ),
          ),
      ],
      child: Container(
        width: 138,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.statusLabel(widget.status),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: color),
          ],
        ),
      ),
    );
  }

  Widget _actions() {
    final p = widget.p;
    const green = Color(0xFF25D366);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(icon: Icons.visibility, color: p.textPrimary, onTap: () {}),
        const SizedBox(width: 6),
        _iconBtn(
          icon: FontAwesomeIcons.whatsapp,
          color: green,
          fill: green.withValues(alpha: p.isDark ? 0.22 : 0.18),
          size: 18,
          onTap: () {},
        ),
        const SizedBox(width: 6),
        _iconBtn(icon: Icons.edit, color: p.textPrimary, onTap: () {}),
      ],
    );
  }

  Widget _iconBtn({
    required dynamic icon,
    required Color color,
    required VoidCallback onTap,
    Color? fill,
    double size = 20,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon is FaIconData
            ? FaIcon(icon, size: size, color: color)
            : Icon(icon as IconData, size: size, color: color),
      ),
    );
  }
}
