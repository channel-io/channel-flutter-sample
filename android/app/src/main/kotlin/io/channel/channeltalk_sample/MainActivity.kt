package io.channel.channeltalk_sample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * MainActivity serves as a bridge between Flutter and native Android platform.
 * It manages all ChannelIO SDK features through ChannelIOManager.
 */
class MainActivity : FlutterActivity(), MethodCallHandler {
    
    /**
     * MethodChannel for communication with Flutter
     * Channel name: 'channel_io_manager'
     */
    private val CHANNEL = "channel_io_manager"
    private lateinit var channel: MethodChannel
    private lateinit var channelIOManager: ChannelIOManager
    
    /**
     * Configure MethodChannel when setting up Flutter engine.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize MethodChannel and set handler
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        
        // Initialize ChannelIOManager
        channelIOManager = ChannelIOManager(this, channel)
    }
    
    /**
     * Delegate methods called from Flutter to ChannelIOManager.
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        channelIOManager.handleMethodCall(call, result)
    }
    
    /**
     * Release resources when Activity ends
     */
    override fun onDestroy() {
        if (::channelIOManager.isInitialized) {
            channelIOManager.dispose()
        }
        super.onDestroy()
    }
}
