import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/data/customer_mock.dart';

const _header = [
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

String _esc(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }

  return value;
}

String _csvDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');

  return '\u200B${two(date.day)}-${two(date.month)}-${date.year}';
}

String buildCustomersCsv(List<Customer> customers) {
  debugPrint('========== CSV EXPORT START ==========');
  debugPrint('Customer count: ${customers.length}');

  final rows = <String>[_header.map(_esc).join(',')];

  debugPrint('CSV header created');

  for (final customer in customers) {
    debugPrint(
      'Processing customer: '
      '${customer.id} | '
      '${customer.name} | '
      '${customer.phone}',
    );

    debugPrint(
      'Status: ${customer.status.label} | '
      'Total: ${customer.total} | '
      'Advance: ${customer.advance} | '
      'Balance: ${customer.balance}',
    );

    rows.add(
      [
        _esc(customer.id),
        _esc(customer.name),
        '="${customer.phone}"',
        _esc(customer.city),
        _esc(customer.frameSize),
        _esc(customer.frameType),
        customer.qty.toString(),
        customer.total.toString(),
        customer.advance.toString(),
        customer.balance.toString(),
        _esc(customer.status.label),
        _csvDate(customer.orderDate),
      ].join(','),
    );
  }

  final csv = rows.join('\r\n');

  debugPrint('CSV rows created: ${rows.length}');
  debugPrint('CSV length: ${csv.length} characters');
  debugPrint('CSV preview:');
  debugPrint(csv.length > 500 ? '${csv.substring(0, 500)}...' : csv);
  debugPrint('========== CSV EXPORT END ==========');

  return csv;
}

String csvFileName([DateTime? now]) {
  final date = now ?? DateTime.now();

  String two(int value) => value.toString().padLeft(2, '0');

  final fileName =
      'Raigon_Customers_'
      '${date.year}-'
      '${two(date.month)}-'
      '${two(date.day)}.csv';

  debugPrint('CSV file name: $fileName');

  return fileName;
}
