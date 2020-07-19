import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docusign_sdk/docusign_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('docusign_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DocusignSdk.platformVersion, '42');
  });
}
