package de.hpi.pharme

import io.flutter.embedding.android.FlutterActivity
import com.jakewharton.threetenabp.AndroidThreeTen
import care.data4life.sdk.Data4LifeClient
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        AndroidThreeTen.init(this.applicationContext)
        Data4LifeClient.init(applicationContext)
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "chdp")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isLoggedIn" -> result.success(true)
                    else -> result.notImplemented()
                }
            }
    }
}
