import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/core/widgets/status_pill.dart';
import 'package:raigon_art/features/customers/data/customer_mock.dart';

class CustomersTable extends StatefulWidget {
  const CustomersTable({
    super.key,
    required this.customers,
    this.onView,
    this.onWhatsApp,
    this.onEdit,
    this.onDelete,
  });

  final List<Customer> customers;
  final ValueChanged<Customer>? onView;
  final ValueChanged<Customer>? onWhatsApp;
  final ValueChanged<Customer>? onEdit;
  final ValueChanged<Customer>? onDelete;

  @override
  State<CustomersTable> createState() => _CustomersTableState();
}

class _CustomersTableState extends State<CustomersTable> {
  final ScrollController _scroll = ScrollController();

  static const _labels = [
    'CUSTOMER ID',
    'CUSTOMER NAME',
    'PHONE NO',
    'ADDRESS',
    'SELECTED PHOTOS',
    'FRAME SIZE',
    'FRAME TYPE',
    'QTY',
    'ORDER STATUS',
    'ORDER DATE',
    'ACTIONS',
  ];
  static const _w = <double>[120, 230, 150, 260, 220, 150, 160, 70, 170, 150];
  static const double _actionsMin = 200;
  static const double _hPad = 28;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fixed = _w.fold<double>(0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                math.max(constraints.maxWidth, fixed + _actionsMin + _hPad * 2);
            return ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: const WidgetStatePropertyAll(AppColors.gold),
                trackColor:
                    WidgetStatePropertyAll(AppColors.gold.withValues(alpha: 0.12)),
                thickness: const WidgetStatePropertyAll(6),
                radius: const Radius.circular(3),
              ),
              child: Scrollbar(
                controller: _scroll,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        _headerRow(p),
                        for (var i = 0; i < widget.customers.length; i++)
                          _row(p, widget.customers[i], i),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.customers.isEmpty)
          Container(
            height: 200,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open, size: 46, color: p.textMuted),
                const SizedBox(height: 10),
                Text(
                  'No customer records match your filter criteria.',
                  style: TextStyle(fontSize: 15, color: p.textMuted),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cells(List<Widget> cells, Widget actions) => Row(
        children: [
          for (var i = 0; i < _w.length; i++)
            SizedBox(width: _w[i], child: cells[i]),
          Expanded(child: actions),
        ],
      );

  Widget _headerRow(AppPalette p) {
    final style = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: p.headerText,
    );
    return Container(
      color: p.tableHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 22),
      child: _cells(
        [for (var i = 0; i < _w.length; i++) Text(_labels[i], style: style)],
        Align(
          alignment: Alignment.center,
          child: Text(_labels.last, style: style),
        ),
      ),
    );
  }

  Widget _row(AppPalette p, Customer c, int index) {
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
      padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 16),
      child: _cells(
        [
          Text(c.id, style: bold),
          Row(
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
                  c.name[0],
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
                      c.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                    Text(
                      c.city,
                      style: TextStyle(fontSize: 13, color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(c.phone, style: cell),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              c.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: cell,
            ),
          ),
          PhotoStrip(
            count: c.photoCount,
            urls: c.photoUrls,
            bytes: c.photoBytes,
            seed: index,
          ),
          Text(c.frameSize, maxLines: 1, overflow: TextOverflow.ellipsis, style: cell),
          Text(c.frameType, maxLines: 1, overflow: TextOverflow.ellipsis, style: cell),
          Text('${c.qty}', style: bold),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusPill(status: c.status),
          ),
          Text(c.orderDateLabel, style: cell),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _action(
              onTap: () => widget.onView?.call(c),
              child: Icon(Icons.visibility, size: 21, color: p.textPrimary),
            ),
            const SizedBox(width: 10),
            _action(
              onTap: () => widget.onWhatsApp?.call(c),
              fill: AppColors.green.withValues(alpha: p.isDark ? 0.25 : 0.18),
              child: const FaIcon(
                FontAwesomeIcons.whatsapp,
                size: 19,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 10),
            _action(
              onTap: () => widget.onEdit?.call(c),
              child: Icon(Icons.edit_outlined, size: 20, color: p.textPrimary),
            ),
            const SizedBox(width: 10),
            _action(
              onTap: () => widget.onDelete?.call(c),
              child: FaIcon(
                FontAwesomeIcons.trash,
                size: 17,
                color: p.isDark ? p.textMuted : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action({
    required VoidCallback onTap,
    required Widget child,
    Color? fill,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      );
}

class PhotoStrip extends StatelessWidget {
  const PhotoStrip({
    super.key,
    required this.count,
    required this.urls,
    required this.seed,
    this.bytes = const [],
  });

  final int count;
  final List<String> urls;
  final List<Uint8List> bytes;
  final int seed;

  static const _tones = [
    Color(0xFFB9B3A8),
    Color(0xFFD9C7AE),
    Color(0xFFC6CEC6),
    Color(0xFFCF8F6E),
    Color(0xFF7A86A3),
    Color(0xFFE2D8D0),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    if (count == 0) {
      return Text('No photos', style: TextStyle(fontSize: 13, color: p.textMuted));
    }
    final shown = math.min(count, 3);
    final extra = count - shown;
    return Row(
      children: [
        for (var i = 0; i < shown; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _thumb(i),
          ),
        if (extra > 0)
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A40),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              '+$extra',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text('($count)', style: TextStyle(fontSize: 12.5, color: p.textMuted)),
      ],
    );
  }

  Widget _thumb(int i) {
    final url = i < urls.length ? urls[i] : '';
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: i < bytes.length
          ? Image.memory(bytes[i], fit: BoxFit.cover)
          : url.isEmpty
          ? ColoredBox(color: _tones[(seed + i) % _tones.length])
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  ColoredBox(color: _tones[(seed + i) % _tones.length]),
            ),
    );
  }
}