import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> downloadCsv(String fileName, String content) async {
  final bytes = Uint8List.fromList([
    0xEF,
    0xBB,
    0xBF,
    ...utf8.encode(content),
  ]);

  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(
      type: 'text/csv;charset=utf-8',
    ),
  );

  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a')
      as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.append(anchor);

  anchor.click();
  anchor.remove();

  web.URL.revokeObjectURL(url);
}