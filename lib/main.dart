import 'package:flutter/material.dart';
import 'package:raigon_art/features/customers/data/customer_store.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CustomerStore.init();
  runApp(const RaigonartApp());
}
