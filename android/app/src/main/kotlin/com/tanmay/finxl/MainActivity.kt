package com.tanmay.finxl

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val smsMethodChannel = "finxl/sms_detection"
    private val smsEventChannel = "finxl/sms_detection/events"
    private val smsPermissionRequestCode = 4217

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var smsEventSink: EventChannel.EventSink? = null
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsMethodChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasSmsPermission" -> result.success(hasSmsPermission())
                    "requestSmsPermission" -> requestSmsPermission(result)
                    "startListening" -> {
                        startSmsReceiver()
                        result.success(null)
                    }
                    "stopListening" -> {
                        stopSmsReceiver()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, smsEventChannel)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        smsEventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        smsEventSink = null
                    }
                },
            )
    }

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (hasSmsPermission()) {
            result.success(true)
            return
        }
        pendingPermissionResult?.success(false)
        pendingPermissionResult = result
        requestPermissions(arrayOf(Manifest.permission.RECEIVE_SMS), smsPermissionRequestCode)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == smsPermissionRequestCode) {
            val granted = grantResults.isNotEmpty() &&
                grantResults.first() == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun hasSmsPermission(): Boolean {
        return checkSelfPermission(Manifest.permission.RECEIVE_SMS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun startSmsReceiver() {
        if (!hasSmsPermission() || smsReceiver != null) return

        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (messages.isNullOrEmpty()) return
                val body = messages.joinToString(separator = "") { it.messageBody.orEmpty() }
                val sender = messages.firstOrNull()?.displayOriginatingAddress
                smsEventSink?.success(
                    mapOf(
                        "body" to body,
                        "sender" to sender,
                        "timestamp" to System.currentTimeMillis(),
                    ),
                )
            }
        }

        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(smsReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(smsReceiver, filter)
        }
    }

    private fun stopSmsReceiver() {
        smsReceiver?.let { unregisterReceiver(it) }
        smsReceiver = null
    }

    override fun onDestroy() {
        stopSmsReceiver()
        super.onDestroy()
    }
}
