import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<void> upsert(Customer customer);
  Future<void> delete(String id);
}

class LocalCustomerRepository implements CustomerRepository {
  static const String _key = 'raigon_customers_v1';

  Future<void> _queue = Future<void>.value();

  Future<List<Customer>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List;

      return [
        for (final item in decoded)
          Customer.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (error, stackTrace) {
      debugPrint('Failed to read customers: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _write(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString(
      _key,
      jsonEncode([for (final customer in customers) customer.toJson()]),
    );

    if (!saved) {
      throw StateError('Could not save customers locally.');
    }
  }

  Future<void> _enqueue(Future<void> Function() job) {
    final next = _queue.then((_) => job());

    _queue = next.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Customer persistence failed: $error');
      },
    );

    return next;
  }

  @override
  Future<List<Customer>> getAll() async {
    await _queue;
    return _read();
  }

  @override
  Future<void> upsert(Customer customer) {
    return _enqueue(() async {
      final list = await _read();
      final index = list.indexWhere((c) => c.id == customer.id);

      if (index == -1) {
        list.insert(0, customer);
      } else {
        list[index] = customer;
      }

      await _write(list);
    });
  }

  @override
  Future<void> delete(String id) {
    return _enqueue(() async {
      final list = await _read()
        ..removeWhere((customer) => customer.id == id);

      await _write(list);
    });
  }
}
