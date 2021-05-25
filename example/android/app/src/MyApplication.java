package com.noda.docusign.docusign_sdk_example;
import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}