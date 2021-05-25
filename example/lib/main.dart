import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:docusign_sdk/docusign_sdk.dart';
import 'package:docusign_sdk/model.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await DocusignSdk.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget buildApp(BuildContext context) {
    String templateId = "fa94302b-0049-4362-a074-19e8b371de84"; //fuck
    templateId = "aa9dff2e-5d7d-44a1-bf5c-19f343b2990c"; // inperson-fuck

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('removeCachedEnvelopes'),
            onPressed: () async {
              await DocusignSdk.removeCachedEnvelopes();
            },
          ),
          RaisedButton(
            child: Text('starListenEnvelopNotification'),
            onPressed: () async {
              await DocusignSdk.starListenEnvelopNotification();
            },
          ),
          RaisedButton(
            child: Text('sync'),
            onPressed: () async {
              await DocusignSdk.syncEnvelopes();
            },
          ),
          RaisedButton(
            child: Text('login'),
            onPressed: () async {
              print('start login');
              await DocusignSdk.loginWithEmail(
                  email: 'myamolane@outlook.com',
                  password: 'password',
                  host: 'https://demo.docusign.net/restapi',
                  integratorKey: '768d67d9-dd18-4973-979c-376b23799fea');
            },
          ),
          RaisedButton(
            child: Text('cache'),
            onPressed: () async {
              await DocusignSdk.cacheTemplateWithId(templateId);
            },
          ),
          RaisedButton(
            child: Text('remove cache'),
            onPressed: () async {
              await DocusignSdk.removeCachedTemplateWithId(templateId);
            },
          ),
          RaisedButton(
            child: Text('remove cache by id'),
            onPressed: () async {
              await DocusignSdk.removeCachedEnvelopeWithId(
                  "9FED9521-0ECF-48C7-9863-923A3981E412");
              print('removed');
            },
          ),
          RaisedButton(
            child: Text('sign'),
            onPressed: () async {
              RecipientDefault recip = RecipientDefault(
                recipientRoleName: 'Visitor',
                recipientEmail: 'myamolane@outlook.com',
                recipientName: 'myamo lane',
                inPersonSignerName: '测试人',
                recipientType: RecipientType.recipientTypeInPersonSigner,
              );

              dynamic r = await DocusignSdk.renderWithTemplateId(templateId,
                  signingMode: DocuSignSigningMode.offline,
                  envelopeDefaults:
                      EnvelopeDefaults(recipientDefaults: [recip]));
              print('singed');
              print(r);
            },
          ),
          RaisedButton(
            child: Text('cachedEnvelopeIds'),
            onPressed: () async {
              await DocusignSdk.cachedEnvelopeIds();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: buildApp(context),
    );
  }
}
