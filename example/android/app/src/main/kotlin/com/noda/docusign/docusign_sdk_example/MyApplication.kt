package com.noda.docusign.docusign_sdk_example;
import io.flutter.app.FlutterApplication;
import android.content.Context;
import androidx.multidex.MultiDex;
import com.docusign.androidsdk.DocuSign;
import com.docusign.androidsdk.util.DSMode;
    

class MyApplication : FlutterApplication() {
     override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)

        DocuSign.init(
            this, // the Application Context
            "38e8f245-4e5a-4c6c-8813-b12f8262370b", // recommend not hard-coding this
            DSMode.DEBUG // this controls the logging (logcat) behavior
        );
    }
 }