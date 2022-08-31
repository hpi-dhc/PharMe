package de.hpi.pharme

import io.flutter.embedding.android.FlutterActivity
import com.jakewharton.threetenabp.AndroidThreeTen
import care.data4life.sdk.Data4LifeClient
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import care.data4life.sdk.listener.ResultListener
import care.data4life.sdk.lang.D4LException

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
                    "isLoggedIn" -> Data4LifeClient.getInstance().isUserLoggedIn(
                        object : ResultListener<Boolean> {
                            override fun onSuccess(t: Boolean) = result.success(t)

                            override fun onError(exception: D4LException) =
                                result.error(
                                    "D4LException",
                                    "Failed to check login status",
                                    exception
                                )
                        }
                    )
                    "login" -> {
                        val intent = Data4LifeClient.getInstance().getLoginIntent(
                            this@MainActivity,
                            setOf(
                                "perm:r",
                                "rec:r",
                                "rec:w",
                                "attachment:r",
                                "attachment:w",
                                "user:r",
                                "user:w",
                                "user:q",
                            )
                        )

                        this@MainActivity.startActivityForResult(intent, Data4LifeClient.D4L_AUTH)

                        result.success(0)
                    }
                    "logout" -> {
                        Data4LifeClient.getInstance().logout(
                            object : care.data4life.sdk.listener.Callback {
                                override fun onSuccess() = result.success(0)

                                override fun onError(exception: D4LException) =
                                    result.error(
                                        "D4LException",
                                        "Failed to logout",
                                        exception
                                    )
                            }
                        )

                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: android.content.Intent?,
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == Data4LifeClient.D4L_AUTH) {
            if (resultCode == android.app.Activity.RESULT_OK) {
                android.util.Log.i("PHARME", "login successful")
            }
        }
    }
}
