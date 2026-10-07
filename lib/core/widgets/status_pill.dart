import 'package:flutter/material.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/features/dashboard/data/dashboard_mock.dart';

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.inProgress => 'In Progress',
        OrderStatus.completed => 'Completed',
        OrderStatus.pending => 'Pending',
        OrderStatus.cancelled => 'Cancelled',
      };

  Color get color => switch (this) {
        OrderStatus.inProgress => AppPalette.statusGold,
        OrderStatus.completed => AppPalette.statusGreen,
        OrderStatus.pending => AppPalette.statusGold,
        OrderStatus.cancelled => AppPalette.statusRed,
      };
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
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
            status.label,
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
