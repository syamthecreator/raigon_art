import 'dart:convert';

import 'package:raigon_art/features/customers/models/customer_model.dart';
import 'package:raigon_art/features/customers/models/frame_spec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerImageStorage {
  static const String _prefix = 'raigon_customer_images_';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  String _key(String customerId) => '$_prefix$customerId';

  Future<void> save(Customer customer) async {
    final prefs = await _prefs;

    final data = {
      'photos': [
        for (var i = 0; i < customer.photoBytes.length; i++)
          {
            'name': i < customer.photoNames.length
                ? customer.photoNames[i]
                : 'Photo_${i + 1}.jpg',
            'bytes': base64Encode(customer.photoBytes[i]),
          },
      ],
      'frames': [
        for (final frame in customer.frames)
          {
            'photoName': frame.photoName,
            'photoBytes': frame.photoBytes == null
                ? null
                : base64Encode(frame.photoBytes!),
          },
      ],
    };

    final saved = await prefs.setString(_key(customer.id), jsonEncode(data));

    if (!saved) {
      throw StateError('Could not save customer images locally.');
    }
  }

  Future<Customer> attach(Customer customer) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key(customer.id));

    if (raw == null || raw.isEmpty) {
      return customer.copyWithImages(
        photoBytes: const [],
        photoNames: const [],
        photoUrls: const [],
        frames: [
          for (final frame in customer.frames)
            FrameSpec(
              size: frame.size,
              unit: frame.unit,
              customWidth: frame.customWidth,
              customHeight: frame.customHeight,
              frameType: frame.frameType,
              material: frame.material,
              finish: frame.finish,
              orientation: frame.orientation,
              qty: frame.qty,
              notes: frame.notes,
              photoName: frame.photoName,
            ),
        ],
        photoCount: 0,
      );
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final photos = (data['photos'] as List? ?? const [])
        .cast<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final savedFrames = (data['frames'] as List? ?? const [])
        .cast<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final photoBytes = photos
        .map((item) => base64Decode(item['bytes'] as String))
        .toList();

    final photoNames = photos
        .map((item) => item['name'] as String? ?? 'Photo.jpg')
        .toList();

    final frames = <FrameSpec>[
      for (var i = 0; i < customer.frames.length; i++)
        _attachFrame(
          customer.frames[i],
          i < savedFrames.length ? savedFrames[i] : null,
        ),
    ];

    return customer.copyWithImages(
      photoBytes: photoBytes,
      photoNames: photoNames,
      photoUrls: const [],
      frames: frames,
      photoCount: photoBytes.length,
    );
  }

  FrameSpec _attachFrame(FrameSpec frame, Map<String, dynamic>? saved) {
    if (saved == null) return frame;

    final encoded = saved['photoBytes'] as String?;

    return FrameSpec(
      size: frame.size,
      unit: frame.unit,
      customWidth: frame.customWidth,
      customHeight: frame.customHeight,
      frameType: frame.frameType,
      material: frame.material,
      finish: frame.finish,
      orientation: frame.orientation,
      qty: frame.qty,
      notes: frame.notes,
      photoName: saved['photoName'] as String? ?? frame.photoName,
      photoBytes: encoded == null ? null : base64Decode(encoded),
      photoUrl: null,
    );
  }

  Future<void> delete(String customerId) async {
    final prefs = await _prefs;
    await prefs.remove(_key(customerId));
  }
}
