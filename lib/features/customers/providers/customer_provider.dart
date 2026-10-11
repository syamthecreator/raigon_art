import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/models/customer_model.dart';
import 'package:raigon_art/features/customers/repository/customer_repository.dart';

/// Customer state and all customer data operations.
class CustomerProvider extends ChangeNotifier {
  CustomerProvider({CustomerRepository? repository})
    : _repository = repository ?? LocalCustomerRepository();

  final CustomerRepository _repository;

  List<Customer> _customers = [];
  bool _isLoading = false;
  bool _initialized = false;
  Object? _error;

  List<Customer> get customers => List.unmodifiable(_customers);
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;
  Object? get error => _error;

  Future<void> init() async {
    if (_initialized || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _repository.getAll();
      _initialized = true;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _error = null;

    try {
      _customers = await _repository.getAll();
      _initialized = true;
      notifyListeners();
    } catch (error) {
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  String nextId() {
    var maxNumber = 1000;

    for (final customer in _customers) {
      final match = RegExp(r'(\d+)$').firstMatch(customer.id);

      if (match != null) {
        maxNumber = math.max(maxNumber, int.parse(match.group(1)!));
      }
    }

    return 'RA-${maxNumber + 1}';
  }

  Future<void> add(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);

    if (index != -1) {
      throw StateError('Customer ID already exists: ${customer.id}');
    }

    // Optimistic UI update.
    _customers = [customer, ..._customers];
    _error = null;
    notifyListeners();

    try {
      await _repository.upsert(customer);
    } catch (error) {
      _customers = _customers.where((c) => c.id != customer.id).toList();
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> update(Customer customer) async {
    final previous = List<Customer>.of(_customers);
    final index = _customers.indexWhere((c) => c.id == customer.id);

    if (index == -1) {
      throw StateError('Customer not found: ${customer.id}');
    }

    _customers = [
      for (final existing in _customers)
        existing.id == customer.id ? customer : existing,
    ];
    _error = null;
    notifyListeners();

    try {
      await _repository.upsert(customer);
    } catch (error) {
      _customers = previous;
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final previous = List<Customer>.of(_customers);

    _customers = _customers.where((c) => c.id != id).toList();
    _error = null;
    notifyListeners();

    try {
      await _repository.delete(id);
    } catch (error) {
      _customers = previous;
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  // CSV export logic moved here from customer_csv.dart.
  static const List<String> csvHeader = [
    'Customer ID',
    'Name',
    'Phone',
    'City',
    'Frame Size',
    'Frame Type',
    'Qty',
    'Total Amount',
    'Advance Paid',
    'Balance',
    'Order Status',
    'Order Date',
  ];

  static String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }

    return value;
  }

  static String _csvDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    // Retains the existing Excel date-text behavior.
    return '\u200B${two(date.day)}-${two(date.month)}-${date.year}';
  }

  String buildCustomersCsv([List<Customer>? source]) {
    final list = source ?? _customers;
    final rows = <String>[csvHeader.map(_escapeCsv).join(',')];

    for (final customer in list) {
      rows.add(
        [
          _escapeCsv(customer.id),
          _escapeCsv(customer.name),
          '="${customer.phone.replaceAll('"', '""')}"',
          _escapeCsv(customer.city),
          _escapeCsv(customer.frameSize),
          _escapeCsv(customer.frameType),
          customer.qty.toString(),
          customer.total.toString(),
          customer.advance.toString(),
          customer.balance.toString(),
          _escapeCsv(customer.status.label),
          _csvDate(customer.orderDate),
        ].join(','),
      );
    }

    return rows.join('\r\n');
  }

  String csvFileName([DateTime? now]) {
    final date = now ?? DateTime.now();

    String two(int value) => value.toString().padLeft(2, '0');

    return 'Raigon_Customers_'
        '${date.year}-${two(date.month)}-${two(date.day)}.csv';
  }
}
