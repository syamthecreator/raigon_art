import 'dart:typed_data';

class FrameSpec {
  const FrameSpec({
    required this.size,
    required this.unit,
    this.customWidth = '',
    this.customHeight = '',
    required this.frameType,
    required this.material,
    required this.finish,
    required this.orientation,
    required this.qty,
    this.notes = '',
    this.photoName,
    this.photoBytes,
  });

  final String size;
  final String unit;
  final String customWidth;
  final String customHeight;
  final String frameType;
  final String material;
  final String finish;
  final String orientation;
  final int qty;
  final String notes;
  final String? photoName;
  final Uint8List? photoBytes;

  String get sizeLabel =>
      (customWidth.isNotEmpty && customHeight.isNotEmpty)
          ? '$customWidth × $customHeight ${unit.toLowerCase()}'
          : size;
}

class PickedPhoto {
  const PickedPhoto({
    required this.name,
    required this.bytes,
    required this.size,
  });

  final String name;
  final Uint8List bytes;
  final int size;

  String get sizeLabel => size >= 1048576
      ? '${(size / 1048576).toStringAsFixed(1)} MB'
      : '${(size / 1024).toStringAsFixed(0)} KB';
}
