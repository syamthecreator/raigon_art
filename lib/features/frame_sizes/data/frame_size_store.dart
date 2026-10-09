
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
      orders: json['orders'] as int? ?? 0,
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

  static Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;
        sizes.value = decoded
            .map((item) => FrameSize.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      } catch (e) {
        debugPrint('Could not load frame sizes: $e');
      }
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
    final updated = [...sizes.value, size];
    sizes.value = updated;
    await _persist();
  }

  static Future<void> update(FrameSize size) async {
    final updated = sizes.value.map((item) {
      return item.code == size.code ? size : item;
    }).toList();

    sizes.value = updated;
    await _persist();
  }

  static Future<void> remove(String code) async {
    sizes.value = sizes.value
        .where((item) => item.code != code)
        .toList();

    await _persist();
  }
}
