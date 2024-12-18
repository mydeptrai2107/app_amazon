package com.example.flutter_amazon_clone_bloc

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.sdk.Environment
import vn.zalopay.sdk.ZaloPayError
import vn.zalopay.sdk.ZaloPaySDK
import vn.zalopay.sdk.listeners.PayOrderListener

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ZaloPay SDK Initialization
        ZaloPaySDK.init(2554, Environment.SANDBOX) // Replace with your ZaloPay AppID
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Handle ZaloPay result
        ZaloPaySDK.getInstance().onResult(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channelPayOrder = "flutter.native/channelPayOrder"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelPayOrder)
            .setMethodCallHandler { call, result ->
                if (call.method == "payOrder") {
                    handlePayOrder(call.argument<String>("zptoken"), result)
                } else {
                    Log.d("[METHOD CALLER]", "Method Not Implemented")
                    result.success(mapOf("errorCode" to -1))
                }
            }
    }

    private fun handlePayOrder(token: String?, result: MethodChannel.Result) {
        if (token.isNullOrEmpty()) {
            result.error("INVALID_TOKEN", "Token is null or empty", null)
            return
        }

        ZaloPaySDK.getInstance().payOrder(
            this,
            token,
            "demozpdk://app",
            object : PayOrderListener {
                override fun onPaymentCanceled(zpTransToken: String?, appTransID: String?) {
                    result.success(
                        mapOf(
                            "errorCode" to 4,
                            "zpTranstoken" to zpTransToken,
                            "appTransId" to appTransID
                        )
                    )
                }

                override fun onPaymentError(
                    zaloPayErrorCode: ZaloPayError?,
                    zpTransToken: String?,
                    appTransID: String?
                ) {
                    result.success(
                        mapOf(
                            "errorCode" to -1,
                            "zpTranstoken" to zpTransToken,
                            "appTransId" to appTransID
                        )
                    )
                }

                override fun onPaymentSucceeded(
                    transactionId: String,
                    transToken: String,
                    appTransID: String?
                ) {
                    result.success(
                        mapOf(
                            "errorCode" to 1,
                            "zpTranstoken" to transToken,
                            "transactionId" to transactionId,
                            "appTransId" to appTransID
                        )
                    )
                }
            }
        )
    }
}
