import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/service/csv/csv_downloader.dart';
import 'package:raigon_art/core/widgets/app_dropdown.dart';
import 'package:raigon_art/core/widgets/app_snackbar.dart';
import 'package:raigon_art/features/customers/data/customer_csv.dart';
import 'package:raigon_art/features/customers/data/customer_mock.dart';
import 'package:raigon_art/features/customers/data/customer_store.dart';
import 'package:raigon_art/features/customers/presentation/widgets/customers_table.dart';
import 'package:raigon_art/features/dashboard/data/dashboard_mock.dart';
import 'package:raigon_art/features/shell/presentation/shell_scope.dart';

enum StatusFilter {
  all('All Statuses', null),
  pending('Pending', OrderStatus.pending),
  inProgress('In Progress', OrderStatus.inProgress),
  completed('Completed', OrderStatus.completed),
  cancelled('Cancelled', OrderStatus.cancelled);

  const StatusFilter(this.label, this.status);
  final String label;
  final OrderStatus? status;
}

enum SortOption {
  newest('Newest First'),
  oldest('Oldest First'),
  name('Name (A-Z)'),
  amount('Total Amount (High-Low)');

  const SortOption(this.label);
  final String label;
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  static const int _pageSize = 10;

  final _searchCtrl = TextEditingController();
  StatusFilter _status = StatusFilter.all;
  SortOption _sort = SortOption.newest;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    CustomerStore.customers.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    CustomerStore.customers.removeListener(_onStoreChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Customer> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final list = CustomerStore.customers.value.where((c) {
      final statusOk = _status.status == null || c.status == _status.status;
      final searchOk =
          q.isEmpty ||
          [
            c.id,
            c.name,
            c.phone,
            c.city,
            c.address,
          ].any((s) => s.toLowerCase().contains(q));
      return statusOk && searchOk;
    }).toList();
    switch (_sort) {
      case SortOption.newest:
        list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      case SortOption.oldest:
        list.sort((a, b) => a.orderDate.compareTo(b.orderDate));
      case SortOption.name:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case SortOption.amount:
        list.sort((a, b) => b.total.compareTo(a.total));
    }
    return list;
  }

  Future<void> _exportCsv() async {
    final list = _filtered;
    if (list.isEmpty) {
      AppSnackBar.error(context, 'No customers to export.');
      return;
    }
    try {
      await downloadCsv(csvFileName(), buildCustomersCsv(list));
      if (!mounted) return;
      AppSnackBar.success(context, 'Customer data exported successfully.');
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Could not export CSV. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final all = _filtered;
    final totalPages = math.max(1, (all.length / _pageSize).ceil());
    final page = _page.clamp(1, totalPages);
    final pageItems = all.skip((page - 1) * _pageSize).take(_pageSize).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(p, wide),
              const SizedBox(height: 24),
              Container(
                decoration: p.card(),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: _toolbar(p, wide),
                    ),
                    CustomersTable(
                      customers: pageItems,
                      onView: (c) {},
                      onWhatsApp: (c) {},
                      onEdit: (c) {},
                      onDelete: (c) {},
                    ),
                    _footer(p, all.length, page, totalPages),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(AppPalette p, bool wide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage customer details and photo frame orders',
                style: TextStyle(fontSize: 15.5, color: p.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: _exportCsv,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 20 : 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: p.chipFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: p.isDark ? p.border : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.fileExport,
                  size: 17,
                  color: p.textPrimary,
                ),
                if (wide) ...[
                  const SizedBox(width: 10),
                  Text(
                    'Export CSV',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: p.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
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
                const Icon(Icons.person_add, size: 20, color: Colors.white),
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
    );
  }

  Widget _searchField(AppPalette p) {
    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: w),
    );
    return SizedBox(
      width: 270,
      height: 46,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() => _page = 1),
        cursorColor: p.textPrimary,
        style: TextStyle(fontSize: 15, color: p.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search customer, phone, ID...',
          hintStyle: TextStyle(fontSize: 15, color: p.textMuted),
          prefixIcon: Icon(Icons.search, size: 21, color: p.textMuted),
          filled: true,
          fillColor: p.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: border(p.border),
          focusedBorder: border(AppColors.gold, 1.4),
        ),
      ),
    );
  }

  Widget _toolbar(AppPalette p, bool wide) {
    final status = AppDropdown<StatusFilter>(
      value: _status,
      items: StatusFilter.values,
      labelOf: (s) => s.label,
      width: 175,
      onChanged: (v) => setState(() {
        _status = v;
        _page = 1;
      }),
    );
    final sort = AppDropdown<SortOption>(
      value: _sort,
      items: SortOption.values,
      labelOf: (s) => s.label,
      width: 200,
      onChanged: (v) => setState(() => _sort = v),
    );
    if (wide) {
      return Row(
        children: [
          _searchField(p),
          const SizedBox(width: 14),
          status,
          const Spacer(),
          sort,
        ],
      );
    }
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [_searchField(p), status, sort],
    );
  }

  Widget _footer(AppPalette p, int total, int page, int totalPages) {
    final start = total == 0 ? 0 : (page - 1) * _pageSize + 1;
    final end = math.min(page * _pageSize, total);
    final bold = TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary);

    Widget pageButton(
      String label,
      IconData icon,
      bool enabled,
      bool prev,
      VoidCallback onTap,
    ) {
      final fg = enabled ? p.textPrimary : p.textMuted;
      final iconW = Icon(icon, size: 18, color: fg);
      final text = Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg),
      );
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: prev
                ? [iconW, const SizedBox(width: 4), text]
                : [text, const SizedBox(width: 4), iconW],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.rowDivider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 16,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14.5, color: p.textMuted),
              children: [
                const TextSpan(text: 'Showing '),
                TextSpan(text: '$start–$end', style: bold),
                const TextSpan(text: ' of '),
                TextSpan(text: '$total', style: bold),
                const TextSpan(text: ' customers'),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pageButton(
                'Previous',
                Icons.chevron_left,
                page > 1,
                true,
                () => setState(() => _page = page - 1),
              ),
              const SizedBox(width: 14),
              Text(
                'Page $page of $totalPages',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(width: 14),
              pageButton(
                'Next',
                Icons.chevron_right,
                page < totalPages,
                false,
                () => setState(() => _page = page + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
