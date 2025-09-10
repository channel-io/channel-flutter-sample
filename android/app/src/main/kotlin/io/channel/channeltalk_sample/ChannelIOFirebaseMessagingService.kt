package io.channel.channeltalk_sample

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.zoyi.channel.plugin.android.ChannelIO
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/**
 * ChannelIO Integrated Firebase Messaging Service
 * 
 * Inherits FlutterFirebaseMessagingService to maintain all Flutter FCM functionality while
 * additionally performing native handling for ChannelIO messages.
 * 
 * How it works:
 * 1. First receive all FCM messages
 * 2. From message data
 * 3. If it's a ChannelIO message, handle directly with native ChannelIO SDK
 * 4. Also forward all messages (including ChannelIO) to Flutter to maintain existing Flutter FCM behavior
 *
 */
class ChannelIOFirebaseMessagingService : FlutterFirebaseMessagingService() {

    companion object {
        private const val TAG = "ChannelIOFCMService"
    }

    /**
     * Handle FCM message reception
     * 
     * Override onMessageReceived from Flutter FCM service to
     * perform additional processing for ChannelIO messages.
     * 
     * @param remoteMessage Message received from Firebase
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        try {
            // Step 1: Identify ChannelIO message
            val isChannelMessage = ChannelIO.isChannelPushNotification(remoteMessage.data)

            if (isChannelMessage) {
                // Step 2: Native processing through ChannelIO SDK
                // This processing works normally even in the background
                ChannelIO.receivePushNotification(this, remoteMessage.data)
            } else {
                super.onMessageReceived(remoteMessage)
            }
        } catch (e: Exception) {
            super.onMessageReceived(remoteMessage)
        }
    }

    /**
     * Handle FCM token refresh
     * 
     * Called when a new FCM token is generated or refreshed.
     * Register the new token with ChannelIO and also forward to Flutter.
     * 
     * @param token New FCM token
     */
    override fun onNewToken(token: String) {
        try {
            // Register new token with ChannelIO
            ChannelIO.initPushToken(token)
        } catch (e: Exception) {
            Log.e(TAG, "❌ ChannelIO token registration failed: ${e.message}", e)
        }

        super.onNewToken(token)
    }
}
