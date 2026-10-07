import 'dart:typed_data';

import 'package:raigon_art/features/customers/data/frame_spec.dart';
import 'package:raigon_art/features/dashboard/data/dashboard_mock.dart';

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.city,
    required this.phone,
    required this.address,
    required this.photoCount,
    required this.frameSize,
    required this.frameType,
    required this.qty,
    required this.total,
    required this.advance,
    required this.status,
    required this.orderDate,
    this.photoUrls = const [],
    this.altPhone = '',
    this.pincode = '',
    this.expectedDelivery,
    this.paymentStatus = 'Unpaid',
    this.frames = const [],
    this.photoBytes = const [],
  });

  final String id;
  final String name;
  final String city;
  final String phone;
  final String address;
  final int photoCount;

  /// Optional thumbnail URLs. Empty entries show a placeholder tile.
  final List<String> photoUrls;
  final String frameSize;
  final String frameType;
  final int qty;
  final int total;
  final int advance;
  final OrderStatus status;
  final DateTime orderDate;
  final String altPhone;
  final String pincode;
  final DateTime? expectedDelivery;
  final String paymentStatus;

  /// Full frame configuration(s) entered in the Add Customer dialog.
  final List<FrameSpec> frames;

  /// Photos picked locally (thumbnails). Use [photoUrls] for server images.
  final List<Uint8List> photoBytes;

  int get balance => total - advance;

  String get orderDateLabel => formatDate(orderDate);
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// Mock data. Replace with API results.
final List<Customer> mockCustomers = [
  Customer(id: 'RA-1001', name: 'Arun Kumar', city: 'Trivandrum', phone: '7902261255', address: 'TC 14/201, MG Road, Overbridge', photoCount: 5, frameSize: '12 × 18 inch', frameType: 'Wooden Frame', qty: 2, total: 4500, advance: 2000, status: OrderStatus.inProgress, orderDate: DateTime(2026, 8, 27)),
  Customer(id: 'RA-1002', name: 'Fathima', city: 'Kochi', phone: '7902261255', address: 'Flat 4B, Marine Drive Towers', photoCount: 3, frameSize: '8 × 12 inch', frameType: 'Premium Frame', qty: 1, total: 2200, advance: 2200, status: OrderStatus.completed, orderDate: DateTime(2026, 8, 26)),
  Customer(id: 'RA-1003', name: 'Rahul Raj', city: 'Kollam', phone: '7902261255', address: 'Near Beach Road, Kadappakada', photoCount: 2, frameSize: '16 × 20 inch', frameType: 'Classic Frame', qty: 4, total: 12000, advance: 3000, status: OrderStatus.pending, orderDate: DateTime(2026, 8, 25)),
  Customer(id: 'RA-1004', name: 'Ananya Nair', city: 'Kozhikode', phone: '7902261255', address: '12/450, Calicut Beach Avenue', photoCount: 2, frameSize: '20 × 30 inch', frameType: 'Canvas Float', qty: 1, total: 6800, advance: 6800, status: OrderStatus.completed, orderDate: DateTime(2026, 8, 24)),
  Customer(id: 'RA-1005', name: 'Deepak Varma', city: 'Kottayam', phone: '7902261255', address: 'Baker Junction, Kanjikuzhy', photoCount: 1, frameSize: '8 × 10 inch', frameType: 'Box Frame', qty: 3, total: 3600, advance: 0, status: OrderStatus.cancelled, orderDate: DateTime(2026, 8, 23)),
  Customer(id: 'RA-0995', name: 'Suresh Nair', city: 'Trivandrum', phone: '9847011223', address: 'Vazhuthacaud Junction', photoCount: 0, frameSize: '12 × 18 inch', frameType: 'Wooden Frame', qty: 2, total: 5400, advance: 5400, status: OrderStatus.completed, orderDate: DateTime(2026, 7, 10)),
  Customer(id: 'RA-0988', name: 'Vinod Kumar', city: 'Trivandrum', phone: '9895233445', address: 'Kowdiar Avenue', photoCount: 0, frameSize: '8 × 12 inch', frameType: 'Classic Frame', qty: 2, total: 4000, advance: 4000, status: OrderStatus.completed, orderDate: DateTime(2026, 6, 12)),
];