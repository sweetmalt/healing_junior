package top.healingai.healing_junior

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import android.os.Build


class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL = "top.healingAI.brainlink/receiver"
    private  var receiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                @SuppressLint("UnspecifiedRegisterReceiverFlag")
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    receiver?.let {
                        unregisterReceiver(it)
                    }
                    receiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            val bci = intent.getStringExtra("bci_data")
                            if (bci != null) events.success("bci_$bci")
                            val hrv = intent.getStringExtra("hrv_data")
                            if (hrv != null) events.success("hrv_$hrv")
                        }
                    }
                    val filter = IntentFilter("top.healingAI.brainlink_hm.BCI_DATA")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        // Android 13+ 使用带安全标志的版本
                        registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
                    } else {
                        // 低版本使用原始方法，添加lint忽略注解
                        registerReceiver(receiver, filter)
                    }
                }

                override fun onCancel(args: Any?) {
                    receiver?.let {
                        unregisterReceiver(it)
                        receiver = null
                    }
                }
            }
        )
    }
    override fun onDestroy() {
        receiver?.let {
            unregisterReceiver(it)
            receiver = null
        }
        super.onDestroy()
    }
}