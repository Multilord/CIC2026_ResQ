import 'package:flutter/material.dart';
import 'data/network_service.dart';
import 'ui/workspace.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PrototypeApp(service: NetworkService()));
}
