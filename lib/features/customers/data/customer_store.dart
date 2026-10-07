import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/data/customer_mock.dart';

class CustomerStore {
  CustomerStore._();

  static final ValueNotifier<List<Customer>> customers =
      ValueNotifier<List<Customer>>(List.of(mockCustomers));

  static void add(Customer customer) {
    customers.value = [customer, ...customers.value];
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