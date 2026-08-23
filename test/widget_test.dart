import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mototaller/data/app_database.dart';
import 'package:mototaller/main.dart';
import 'package:mototaller/services/license_service.dart';

void main() {
  final clienteOriginal = LicenseService.client;

  setUp(() {
    AppDatabase.resetForTest();
  });

  tearDown(() {
    LicenseService.client = clienteOriginal;
  });

  testWidgets('Sin licencia guardada, pide un código en vez de dar acceso libre', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MotoTallerApp());
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu código para empezar'), findsOneWidget);
  });

  testWidgets('Con licencia PRO guardada, entra directo al dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'mototaller_licencia_key': '"PRO-TEST-0000"'});
    LicenseService.client = MockClient((request) async => http.Response(jsonEncode({'valid': true, 'type': 'pro'}), 200));

    await tester.pumpWidget(const MotoTallerApp());
    await tester.pumpAndSettle();

    expect(find.text('MotoTaller'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
