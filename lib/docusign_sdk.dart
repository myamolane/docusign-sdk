import 'dart:async';

import 'package:docusign_sdk/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum DocuSignSigningMode {
  online,
  offline
}

class DocusignSdk {
  static const MethodChannel _channel =
  const MethodChannel('docusign_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Map<String, Function(Map<dynamic, dynamic>)> _observers = Map<String, Function(Map<dynamic, dynamic>)>();

  static void _onEvent(String event, value) {
    print(_observers);
    var callback = _observers[event];
    print('---callback');
    print(callback);
    if (callback != null) {
      callback(value);
    }
  }

  static void addObserver(String event, Function(Map<dynamic, dynamic>) callback) {
    _observers[event] = callback;
    print(_observers);
  }

  static void removeObserver(String event) {
    _observers[event] = null;
  }

  static Future<dynamic> _handleMessages(MethodCall call) {
    switch (call.method) {
      case 'onSigned':
        print(call.arguments);
        _onEvent('onSigned', call.arguments);
        break;
    }
  }

  static init() {
    _channel.setMethodCallHandler(_handleMessages);
  }

  static Future<dynamic> loginWithEmail({
    String password,
    String email,
    String integratorKey,
    String host,
  }) async {
    final dynamic r = await _channel.invokeMethod('loginWithEmail', <String, String>{
      "password": password,
      "email": email,
      "integratorKey": integratorKey,
      "host": host,
    });
    print(r);
    return r;
  }

  static Future<dynamic> cacheTemplateWithId(String templateId) async {
    final dynamic r = await _channel.invokeMethod('cacheTemplateWithId', <String, String>{
      "templateId": templateId,
    });
    return r;
  }

  static Future<dynamic> renderWithTemplateId(String templateId, { DocuSignSigningMode signingMode: DocuSignSigningMode.online, bool animated: true, EnvelopeDefaults envelopeDefaults }) async {
    //envelopeDefaults:envelopeDefaults
    //pdfToInsert: nil
    //insertAtPosition:DSMDocumentInsertAtPositionEnd
    //
    //signingMode: DSMSigningModeOffline
    //presentingController: currentViewController
    //animated:YES

    print(signingMode.toString());
    print(signingMode.index);
    final dynamic r = await _channel.invokeMethod('renderWithTemplateId', <String, dynamic>{
      "templateId": templateId,
      "signingMode": signingMode.index,
      "animated": animated,
      "envelopeDefaults": envelopeDefaults?.toMap(),
    });
    return r;
  }

  static Future<dynamic> removeCachedTemplateWithId(String templateId) async {
    final dynamic r = await _channel.invokeMethod('removeCachedTemplateWithId', <String, String>{
      "templateId": templateId,
    });
    return r;
  }

  static Future<dynamic> cachedEnvelopeIds() async {
    final dynamic r = await _channel.invokeMethod('cachedEnvelopeIds');
    print('cachedEnvelopeIds');
    print(r);
    return r;
  }

  static Future removeCachedEnvelopes() async {
    await _channel.invokeMethod('removeCachedEnvelopes');
  }

  static Future syncEnvelopes() async {
    await _channel.invokeMethod('syncEnvelopes');
  }

  static Future starListenEnvelopNotification() async {
    await _channel.invokeMethod('starListenEnvelopNotification');
  }

  static Future removeCachedEnvelopeWithId(envelopeId) async {
    return await _channel.invokeMethod('removeCachedEnvelopeWithId', <String, String>{
      "envelopeId": envelopeId,
    });
  }
}
