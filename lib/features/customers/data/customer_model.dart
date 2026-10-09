import 'dart:convert';
import 'dart:typed_data';

import 'package:raigon_art/features/customers/data/frame_spec.dart';
import 'package:raigon_art/features/dashboard/models/order_status.dart';

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
    this.photoNames = const [],
    this.photoSizeLabels = const [],
  });

  final String id;
  final String name;
  final String city;
  final String phone;
  final String address;
  final int photoCount;
  final List<String> photoNames;
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
  final List<FrameSpec> frames;
  final List<Uint8List> photoBytes;
  final List<String> photoSizeLabels;

  int get balance => total - advance;
  String get orderDateLabel => formatDate(orderDate);

  List<FrameSpec> get effectiveFrames => frames.isNotEmpty
      ? frames
      : [
          FrameSpec(
            size: frameSize,
            unit: 'Inch',
            frameType: frameType,
            material: 'Teak Wood Moulding',
            finish: 'Walnut Brown',
            orientation: 'Landscape (Horizontal)',
            qty: qty,
          ),
        ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'phone': phone,
    'altPhone': altPhone,
    'address': address,
    'pincode': pincode,
    'photoCount': photoCount,
    'photoNames': photoNames,
    'photoUrls': photoUrls,
    'photoSizeLabels': photoSizeLabels,
    'photoBytes': [for (final b in photoBytes) base64Encode(b)],
    'frameSize': frameSize,
    'frameType': frameType,
    'qty': qty,
    'total': total,
    'advance': advance,
    'paymentStatus': paymentStatus,
    'status': status.name,
    'orderDate': orderDate.toIso8601String(),
    'expectedDelivery': expectedDelivery?.toIso8601String(),
    'frames': [for (final f in frames) f.toJson()],
  };

  factory Customer.fromJson(Map<String, dynamic> j) {
    List<String> strings(String key) => [
      for (final v in (j[key] as List? ?? const [])) v as String,
    ];

    return Customer(
      id: j['id'] as String,
      name: j['name'] as String? ?? '',
      city: j['city'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      altPhone: j['altPhone'] as String? ?? '',
      address: j['address'] as String? ?? '',
      pincode: j['pincode'] as String? ?? '',
      photoCount: j['photoCount'] as int? ?? 0,
      photoNames: strings('photoNames'),
      photoUrls: strings('photoUrls'),
      photoSizeLabels: strings('photoSizeLabels'),
      photoBytes: [
        for (final s in (j['photoBytes'] as List? ?? const []))
          base64Decode(s as String),
      ],
      frameSize: j['frameSize'] as String? ?? '',
      frameType: j['frameType'] as String? ?? '',
      qty: j['qty'] as int? ?? 1,
      total: j['total'] as int? ?? 0,
      advance: j['advance'] as int? ?? 0,
      paymentStatus: j['paymentStatus'] as String? ?? 'Unpaid',
      status: OrderStatus.values.firstWhere(
        (s) => s.name == j['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(j['orderDate'] as String),
      expectedDelivery: j['expectedDelivery'] == null
          ? null
          : DateTime.parse(j['expectedDelivery'] as String),
      frames: [
        for (final f in (j['frames'] as List? ?? const []))
          FrameSpec.fromJson(Map<String, dynamic>.from(f as Map)),
      ],
    );
  }

  Customer copyWith({OrderStatus? status, String? paymentStatus}) => Customer(
    id: id,
    name: name,
    city: city,
    phone: phone,
    address: address,
    photoCount: photoCount,
    frameSize: frameSize,
    frameType: frameType,
    qty: qty,
    total: total,
    advance: advance,
    status: status ?? this.status,
    orderDate: orderDate,
    photoUrls: photoUrls,
    altPhone: altPhone,
    pincode: pincode,
    expectedDelivery: expectedDelivery,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    frames: frames,
    photoBytes: photoBytes,
    photoNames: photoNames,
    photoSizeLabels: photoSizeLabels,
  );
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
