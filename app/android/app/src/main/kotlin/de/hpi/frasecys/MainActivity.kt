package de.hpi.pharme

import io.flutter.embedding.android.FlutterActivity
import com.jakewharton.threetenabp.AndroidThreeTen
import care.data4life.sdk.Data4LifeClient
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import care.data4life.sdk.listener.ResultListener
import care.data4life.sdk.lang.D4LException
import care.data4life.fhir.r4.model.Attachment
import care.data4life.fhir.r4.model.CodeSystemDocumentReferenceStatus
import care.data4life.fhir.r4.model.DocumentReference
import android.util.Base64
import java.io.File
import java.security.MessageDigest
import care.data4life.sdk.call.Fhir4Record
import java.util.Calendar
import care.data4life.fhir.r4.util.FhirDateTimeConverter

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
                    "upload" -> {
                        val path: String = call.argument("path")!!
                        val title: String = call.argument("title")!!
                        val docRef = makeDocumentReference(path, title)

                        Data4LifeClient.getInstance().fhir4.create(
                            resource = docRef,
                            annotations = listOf("pharme"),
                            callback = object :
                                care.data4life.sdk.call.Callback<Fhir4Record<DocumentReference>> {
                                override fun onSuccess(_result: Fhir4Record<DocumentReference>) {
                                    result.success(true)
                                }

                                override fun onError(exception: D4LException) {
                                    result.success(false)
                                }
                            }
                        )
                    }
                    "toast" -> {
                        val msg: String = call.argument("msg")!!

                        android.widget.Toast.makeText(this, msg, android.widget.Toast.LENGTH_SHORT).show()
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

fun makeDocumentReference(path: String, title: String): DocumentReference {
    val bytes = File(path).readBytes()
    return DocumentReference(
        CodeSystemDocumentReferenceStatus.CURRENT,
        listOf(
            DocumentReference.DocumentReferenceContent(
                Attachment().apply {
                    contentType = "application/pdf"
                    data = Base64.encodeToString(
                        bytes,
                        Base64.NO_WRAP,
                    )
                    size = bytes.size
                    hash = with(MessageDigest.getInstance("SHA-1")) {
                        Base64.encodeToString(digest(bytes), Base64.NO_WRAP)
                    }
                },
            ),
        ),
    ).apply {
        description = title
        date = FhirDateTimeConverter.toFhirInstant(Calendar.getInstance().time)
    }
}