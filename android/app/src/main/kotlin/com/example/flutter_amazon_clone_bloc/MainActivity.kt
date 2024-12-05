package com.example.flutter_amazon_clone_bloc

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.sdk.Environment
import vn.zalopay.sdk.ZaloPayError
import vn.zalopay.sdk.ZaloPaySDK
import vn.zalopay.sdk.listeners.PayOrderListener

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ZaloPaySDK.init(2554, Environment.SANDBOX); // Merchant AppID
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("newIntent", intent.toString())
        ZaloPaySDK.getInstance().onResult(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channelPayOrder = "flutter.native/channelPayOrder"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelPayOrder)
            .setMethodCallHandler { call, result ->
                if (call.method == "payOrder"){
                    val tagSuccess = "[OnPaymentSucceeded]"
                    val tagError = "[onPaymentError]"
                    val tagCanel = "[onPaymentCancel]"
                    val token = call.argument<String>("zptoken")
                        ZaloPaySDK.getInstance().payOrder(this@MainActivity, token !!, "demozpdk://app",object: PayOrderListener {
                            override fun onPaymentCanceled(zpTransToken: String?, appTransID: String?) {
                                Log.d(tagCanel, String.format("[TransactionId]: %s, [appTransID]: %s", zpTransToken, appTransID))
                                result.success(mapOf(
                                    "errorCode" to 4, 
                                    "zpTranstoken" to zpTransToken,
                                    "appTransId" to appTransID,
                                  ))
                            }

                            override fun onPaymentError(zaloPayErrorCode: ZaloPayError?, zpTransToken: String?, appTransID: String?) {
                                Log.d(tagError, String.format("[zaloPayErrorCode]: %s, [zpTransToken]: %s, [appTransID]: %s", zaloPayErrorCode.toString(), zpTransToken, appTransID))
                                result.success(mapOf(
                                    "errorCode" to -1,
                                    "zpTranstoken" to zpTransToken,
                                    "appTransId" to appTransID,
                                  ))
                            }

                            override fun onPaymentSucceeded(transactionId: String, transToken: String, appTransID: String?) {
                                Log.d(tagSuccess, String.format("[TransactionId]: %s, [TransToken]: %s, [appTransID]: %s", transactionId, transToken, appTransID))
                                result.success(mapOf(
                                    "errorCode" to 1, 
                                    "zpTranstoken" to transToken,
                                    "transactionId" to transactionId,
                                    "appTransId" to appTransID,
                                  ))
                            }
                        })
                } else {
                    Log.d("[METHOD CALLER] ", "Method Not Implemented")
                    result.success(mapOf(
                        "errorCode" to -1
                      ))
                }
            }
    }
}
