import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/data/customer_model.dart';
import 'package:raigon_art/features/customers/repository/customer_repository.dart';

class CustomerStore {
  CustomerStore._();

  static CustomerRepository _repo = LocalCustomerRepository();

  static final ValueNotifier<List<Customer>> customers =
      ValueNotifier<List<Customer>>(const []);

  /// Call once in main() before runApp().
  /// Pass a different repository later (e.g. FirestoreCustomerRepository()).
  static Future<void> init([CustomerRepository? repository]) async {
    if (repository != null) _repo = repository;
    customers.value = await _repo.getAll();
  }

  static Future<void> add(Customer customer) async {
    customers.value = [customer, ...customers.value];
    await _repo.upsert(customer);
  }

  static Future<void> update(Customer customer) async {
    customers.value = [
      for (final c in customers.value) c.id == customer.id ? customer : c,
    ];
    await _repo.upsert(customer);
  }

  static Future<void> remove(String id) async {
    customers.value = customers.value.where((c) => c.id != id).toList();
    await _repo.delete(id);
  }

  static String nextId() {
    var maxN = 1000;
    for (final c in customers.value) {
      final m = RegExp(r'(\d+)$').firstMatch(c.id);
      if (m != null) maxN = math.max(maxN, int.parse(m.group(1)!));
    }
    return 'RA-${maxN + 1}';
  }
}
