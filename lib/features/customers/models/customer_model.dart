import 'dart:convert';
import 'dart:typed_data';

import 'package:raigon_art/features/customers/data/frame_spec.dart';

enum OrderStatus { inProgress, completed, pending, cancelled }

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
    this.photoNames = const [],
    this.photoSizeLabels = const [],
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
  final List<String> photoNames;
  final List<String> photoUrls;
  final List<String> photoSizeLabels;
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
    'address': address,
    'photoCount': photoCount,
    'photoNames': photoNames,
    'photoUrls': photoUrls,
    'photoSizeLabels': photoSizeLabels,
    'frameSize': frameSize,
    'frameType': frameType,
    'qty': qty,
    'total': total,
    'advance': advance,
    'status': status.name,
    'orderDate': orderDate.toIso8601String(),
    'altPhone': altPhone,
    'pincode': pincode,
    'expectedDelivery': expectedDelivery?.toIso8601String(),
    'paymentStatus': paymentStatus,
    'frames': frames.map(_frameToJson).toList(),
    'photoBytes': photoBytes.map(base64Encode).toList(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photoCount: json['photoCount'] as int? ?? 0,
      photoNames: List<String>.from(json['photoNames'] ?? const []),
      photoUrls: List<String>.from(json['photoUrls'] ?? const []),
      photoSizeLabels: List<String>.from(json['photoSizeLabels'] ?? const []),
      frameSize: json['frameSize'] as String? ?? '',
      frameType: json['frameType'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      advance: json['advance'] as int? ?? 0,
      status: OrderStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate:
          DateTime.tryParse(json['orderDate'] as String? ?? '') ??
          DateTime.now(),
      altPhone: json['altPhone'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      expectedDelivery: DateTime.tryParse(
        json['expectedDelivery'] as String? ?? '',
      ),
      paymentStatus: json['paymentStatus'] as String? ?? 'Unpaid',
      frames: (json['frames'] as List<dynamic>? ?? const [])
          .map((item) => _frameFromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      photoBytes: (json['photoBytes'] as List<dynamic>? ?? const [])
          .map((item) => base64Decode(item as String))
          .toList(),
    );
  }
}

Map<String, dynamic> _frameToJson(FrameSpec frame) => {
  'size': frame.size,
  'unit': frame.unit,
  'customWidth': frame.customWidth,
  'customHeight': frame.customHeight,
  'frameType': frame.frameType,
  'material': frame.material,
  'finish': frame.finish,
  'orientation': frame.orientation,
  'qty': frame.qty,
  'notes': frame.notes,
  'photoName': frame.photoName,
  'photoBytes': frame.photoBytes == null
      ? null
      : base64Encode(frame.photoBytes!),
};

FrameSpec _frameFromJson(Map<String, dynamic> json) => FrameSpec(
  size: json['size'] as String? ?? '',
  unit: json['unit'] as String? ?? 'Inch',
  customWidth: json['customWidth'] as String? ?? '',
  customHeight: json['customHeight'] as String? ?? '',
  frameType: json['frameType'] as String? ?? '',
  material: json['material'] as String? ?? '',
  finish: json['finish'] as String? ?? '',
  orientation: json['orientation'] as String? ?? '',
  qty: json['qty'] as int? ?? 0,
  notes: json['notes'] as String? ?? '',
  photoName: json['photoName'] as String?,
  photoBytes: json['photoBytes'] == null
      ? null
      : base64Decode(json['photoBytes'] as String),
);

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

String formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';
