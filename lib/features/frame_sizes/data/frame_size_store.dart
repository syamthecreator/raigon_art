import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrameSize {
  const FrameSize({
    required this.code,
    required this.name,
    required this.width,
    required this.height,
    required this.unit,
    required this.category,
    this.orders = 0,
    this.active = true,
  });

  final String code;
  final String name;
  final double width;
  final double height;
  final String unit;
  final String category;
  final int orders;
  final bool active;

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'width': width,
    'height': height,
    'unit': unit,
    'category': category,
    'orders': orders,
    'active': active,
  };

  factory FrameSize.fromJson(Map<String, dynamic> json) {
    return FrameSize(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      width: (json['width'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'Inch',
      category: json['category'] as String? ?? '',
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }
}

class FrameSizeStore {
  FrameSizeStore._();

  static const String _storageKey = 'raigon_frame_sizes';

  static final ValueNotifier<List<FrameSize>> sizes =
      ValueNotifier<List<FrameSize>>([]);

  static bool _initialized = false;

  // Default sizes for the first launch.
  static const List<FrameSize> _defaultSizes = [
    FrameSize(
      code: 'FS-01',
      name: '4 × 6 inch',
      width: 4,
      height: 6,
      unit: 'Inch',
      category: 'Standard',
    ),
    FrameSize(
      code: 'FS-02',
      name: '5 × 7 inch',
      width: 5,
      height: 7,
      unit: 'Inch',
      category: 'Standard',
    ),
    FrameSize(
      code: 'FS-03',
      name: '8 × 10 inch',
      width: 8,
      height: 10,
      unit: 'Inch',
      category: 'Standard',
    ),
    FrameSize(
      code: 'FS-04',
      name: '12 × 18 inch',
      width: 12,
      height: 18,
      unit: 'Inch',
      category: 'Standard',
    ),
  ];

  static Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;

        sizes.value = decoded
            .map(
              (item) =>
                  FrameSize.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } catch (e) {
        debugPrint('Could not load frame sizes: $e');

        // Recover with defaults if stored data is invalid.
        sizes.value = List<FrameSize>.from(_defaultSizes);
        await _persist();
      }
    } else {
      // Only use defaults when no saved data exists.
      sizes.value = List<FrameSize>.from(_defaultSizes);
      await _persist();
    }

    _initialized = true;
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      sizes.value.map((size) => size.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  static String nextCode() {
    var maxNumber = 0;

    for (final size in sizes.value) {
      final match = RegExp(r'(\d+)$').firstMatch(size.code);

      if (match != null) {
        final number = int.parse(match.group(1)!);
        if (number > maxNumber) maxNumber = number;
      }
    }

    return 'FS-${(maxNumber + 1).toString().padLeft(2, '0')}';
  }

  static Future<void> add(FrameSize size) async {
    sizes.value = [...sizes.value, size];
    await _persist();
  }

  static Future<void> update(FrameSize size) async {
    sizes.value = sizes.value.map((item) {
      return item.code == size.code ? size : item;
    }).toList();

    await _persist();
  }

  static Future<void> remove(String code) async {
    sizes.value = sizes.value.where((item) => item.code != code).toList();

    await _persist();
  }
}
