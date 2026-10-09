import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/data/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage contract. Implement this with Firestore later.
abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<void> upsert(Customer customer);
  Future<void> delete(String id);
}

/// SharedPreferences implementation (whole list stored as one JSON string).
class LocalCustomerRepository implements CustomerRepository {
  static const _key = 'raigon_customers_v1';

  // Serialises writes so quick successive saves can't overwrite each other.
  Future<void> _queue = Future.value();

  Future<List<Customer>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final e in list)
          Customer.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
    } catch (e, st) {
      debugPrint('Failed to read customers: $e\n$st');
      return [];
    }
  }

  Future<void> _write(List<Customer> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final c in list) c.toJson()]),
    );
  }

  Future<void> _enqueue(Future<void> Function() job) {
    _queue = _queue.then((_) => job()).catchError((Object e, StackTrace st) {
      debugPrint('Customer save failed: $e\n$st');
    });
    return _queue;
  }

  @override
  Future<List<Customer>> getAll() => _read();

  @override
  Future<void> upsert(Customer customer) => _enqueue(() async {
        final list = await _read();
        final i = list.indexWhere((c) => c.id == customer.id);
        if (i == -1) {
          list.insert(0, customer); // newest first
        } else {
          list[i] = customer;
        }
        await _write(list);
      });

  @override
  Future<void> delete(String id) => _enqueue(() async {
        final list = await _read()
          ..removeWhere((c) => c.id == id);
        await _write(list);
      });
}