package io.channel.channeltalk_sample

import android.app.Activity
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodChannel

// ChannelIO Android SDK
import com.zoyi.channel.plugin.android.ChannelIO
import com.zoyi.channel.plugin.android.open.callback.UserUpdateCallback
import com.zoyi.channel.plugin.android.open.config.BootConfig
import com.zoyi.channel.plugin.android.open.enumerate.BootStatus
import com.zoyi.channel.plugin.android.open.enumerate.ChannelButtonPosition
import com.zoyi.channel.plugin.android.open.listener.ChannelPluginListener
import com.zoyi.channel.plugin.android.open.model.*
import com.zoyi.channel.plugin.android.open.option.ChannelButtonOption
import com.zoyi.channel.plugin.android.open.option.Language
import io.channel.plugin.android.enumerate.BubblePosition
import io.channel.plugin.android.open.enumerate.ChannelButtonIcon
import io.channel.plugin.android.open.model.Appearance
import io.channel.plugin.android.open.option.BubbleOption

/**
 * ChannelIOManager is a manager class that handles all features of the ChannelIO SDK.
 * It implements ChannelPluginListener to receive SDK events and deliver them to Flutter.
 */
class ChannelIOManager(
    private val activity: Activity,
    private val methodChannel: MethodChannel
) : ChannelPluginListener {
    
    companion object {
        private const val TAG = "ChannelIOManager"
    }
    
    init {
        // Register ChannelPluginListener
        ChannelIO.setListener(this)
    }
    
    /**
     * Handle methods called from Flutter.
     */
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "boot" -> handleBoot(call, result)
            "sleep" -> handleSleep(result)
            "shutdown" -> handleShutdown(result)
            "showChannelButton" -> handleShowChannelButton(result)
            "hideChannelButton" -> handleHideChannelButton(result)
            "showMessenger" -> handleShowMessenger(result)
            "hideMessenger" -> handleHideMessenger(result)
            "openChat" -> handleOpenChat(call, result)
            "openWorkflow" -> handleOpenWorkflow(call, result)
            "track" -> handleTrack(call, result)
            "updateUser" -> handleUpdateUser(call, result)
            "addTags" -> handleAddTags(call, result)
            "removeTags" -> handleRemoveTags(call, result)
            "setPage" -> handleSetPage(call, result)
            "resetPage" -> handleResetPage(result)
            "hidePopup" -> handleHidePopup(result)
            "initPushToken" -> handleInitPushToken(call, result)
            "isChannelPushNotification" -> handleIsChannelPushNotification(call, result)
            "receivePushNotification" -> handleReceivePushNotification(call, result)
            "hasStoredPushNotification" -> handleHasStoredPushNotification(result)
            "openStoredPushNotification" -> handleOpenStoredPushNotification(result)
            "isBooted" -> handleIsBooted(result)
            "setDebugMode" -> handleSetDebugMode(call, result)
            "setAppearance" -> handleSetAppearance(call, result)
            else -> result.notImplemented()
        }
    }
    
    // =============================================================================
    // ChannelPluginListener Implementation
    // =============================================================================
    override fun onBadgeChanged(count: Int) {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onBadgeChanged", mapOf(
                "unread" to count,
                "alert" to 0
            ))
        }
    }
    
    override fun onBadgeChanged(unread: Int, alert: Int) {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onBadgeChanged", mapOf(
                "unread" to unread,
                "alert" to alert
            ))
        }
    }

    override fun onChatCreated(chatId: String) {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onChatCreated", mapOf("chatId" to chatId))
        }
    }

    override fun onPopupDataReceived(event: PopupData) {
        Handler(Looper.getMainLooper()).post {
            val eventMap = mapOf(
                "chatId" to event.chatId,
                "avatarUrl" to event.avatarUrl,
                "name" to event.name,
                "message" to (event.message ?: ""),
                "timestamp" to event.timestamp
            )
            methodChannel.invokeMethod("onPopupDataReceived", eventMap)
        }
    }
    
    override fun onPushNotificationClicked(chatId: String): Boolean {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onPushNotificationClicked", mapOf("chatId" to chatId))
        }
        return true // Always return true to let ChannelIO handle it
    }
    
    /**
     * ChannelPluginListener method called when a URL is clicked.
     * 
     * Current implementation: Forward all URLs to Flutter and open in default browser
     * 
     * @param url The clicked URL string
     * @return Boolean
     *   - true: Internal handling by ChannelIO (opens in WebView within the app)
     *   - false: Opens in default browser
     * 
     * ⚠️ If different handling based on URL patterns is needed:
     * Modify this function to examine the url parameter and conditionally return true/false.
     * 
     * Example:
     * ```kotlin
     * override fun onUrlClicked(url: String): Boolean {
     *     Handler(Looper.getMainLooper()).post {
     *         methodChannel.invokeMethod("onUrlClicked", mapOf("url" to url))
     *     }
     *     
     *     return when {
     *         url.startsWith("https://your-internal-domain.com") -> true  // Open within app
     *         url.contains("external") -> false  // Open in external browser
     *         else -> false  // Default: external browser
     *     }
     * }
     * ```
     */
    override fun onUrlClicked(url: String): Boolean {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onUrlClicked", mapOf("url" to url))
        }
        return false
    }
    
    override fun onShowMessenger() {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onShowMessenger", null)
        }
    }
    
    override fun onHideMessenger() {
        Handler(Looper.getMainLooper()).post {
            methodChannel.invokeMethod("onHideMessenger", null)
        }
    }
    
    override fun onFollowUpChanged(data: MutableMap<String, String>) {
        Handler(Looper.getMainLooper()).post {
            val eventMap = data.toMap()
            methodChannel.invokeMethod("onFollowUpChanged", eventMap)
        }
    }
    
    // =============================================================================
    // ChannelIO SDK Feature Implementation
    // =============================================================================
    
    private fun handleBoot(call: MethodCall, result: Result) {
        try {
            val pluginKey = call.argument<String>("pluginKey") 
                ?: return result.error("MISSING_PARAMETER", "pluginKey is required", null)
                
            val bootConfig = BootConfig.create(pluginKey).apply {
                call.argument<String>("memberId")?.let {
                    setMemberId(it)
                }

                call.argument<String>("language")?.let { 
                    val lang = when(it) {
                        "ko" -> Language.KOREAN
                        "en" -> Language.ENGLISH
                        "ja" -> Language.JAPANESE
                        else -> Language.KOREAN
                    }
                    setLanguage(lang)
                }

                call.argument<String>("appearance")?.let {
                    val app = when(it) {
                        "light" -> Appearance.LIGHT
                        "dark" -> Appearance.DARK
                        else -> Appearance.SYSTEM
                    }
                    setAppearance(app)
                }
                
                // Set profile
                call.argument<Map<String, Any>>("profile")?.let { profileMap ->
                    val profile = Profile.create().apply {
                        profileMap.forEach { (key, value) ->
                            when (value) {
                                is String -> setProperty(key, value)
                                is Number -> setProperty(key, value)
                                is Boolean -> setProperty(key, value)
                            }
                        }
                    }
                    setProfile(profile)
                }
                
                // Set Channel Button Option
                call.argument<Map<String, Any>>("channelButtonOption")?.let { buttonOptionMap ->
                    // Set default values
                    val icon = buttonOptionMap["icon"]?.let { iconStr ->
                        when(iconStr as String) {
                            "channel" -> ChannelButtonIcon.Channel
                            "chatBubbleFilled" -> ChannelButtonIcon.ChatBubbleFilled
                            "chatProgressFilled" -> ChannelButtonIcon.ChatProgressFilled
                            "chatQuestionFilled" -> ChannelButtonIcon.ChatQuestionFilled
                            "chatLightningFilled" -> ChannelButtonIcon.ChatLightningFilled
                            "chatBubbleAltFilled" -> ChannelButtonIcon.ChatBubbleAltFilled
                            "smsFilled" -> ChannelButtonIcon.SmsFilled
                            "commentFilled" -> ChannelButtonIcon.CommentFilled
                            "sendForwardFilled" -> ChannelButtonIcon.SendForwardFilled
                            "helpFilled" -> ChannelButtonIcon.HelpFilled
                            "chatProgress" -> ChannelButtonIcon.ChatProgress
                            "chatQuestion" -> ChannelButtonIcon.ChatQuestion
                            "chatBubbleAlt" -> ChannelButtonIcon.ChatBubbleAlt
                            "sms" -> ChannelButtonIcon.Sms
                            "comment" -> ChannelButtonIcon.Comment
                            "sendForward" -> ChannelButtonIcon.SendForward
                            "communication" -> ChannelButtonIcon.Communication
                            "headset" -> ChannelButtonIcon.Headset
                            else -> ChannelButtonIcon.Channel
                        }
                    } ?: ChannelButtonIcon.Channel
                    
                    val position = buttonOptionMap["position"]?.let { posStr ->
                        when(posStr as String) {
                            "left" -> ChannelButtonPosition.LEFT
                            "right" -> ChannelButtonPosition.RIGHT
                            else -> ChannelButtonPosition.RIGHT
                        }
                    } ?: ChannelButtonPosition.RIGHT
                    
                    val xMargin = buttonOptionMap["xMargin"]?.let { margin ->
                        (margin as Number).toFloat()
                    } ?: 16.0f
                    
                    val yMargin = buttonOptionMap["yMargin"]?.let { margin ->
                        (margin as Number).toFloat()
                    } ?: 16.0f
                    
                    val channelButtonOption = ChannelButtonOption(icon, position, xMargin, yMargin)
                    setChannelButtonOption(channelButtonOption)
                }
                
                // Set Bubble Option
                call.argument<Map<String, Any>>("bubbleOption")?.let { bubbleOptionMap ->
                    val position = bubbleOptionMap["position"]?.let { posStr ->
                        when(posStr as String) {
                            "top" -> BubblePosition.TOP
                            "bottom" -> BubblePosition.BOTTOM
                            else -> BubblePosition.TOP
                        }
                    } ?: BubblePosition.TOP
                    
                    val yMargin = bubbleOptionMap["yMargin"]?.let { margin ->
                        (margin as Number).toFloat()
                    }
                    
                    val bubbleOption = BubbleOption(position, yMargin)
                    setBubbleOption(bubbleOption)
                }
            }
            
            ChannelIO.boot(bootConfig) { bootStatus, user ->
                Handler(Looper.getMainLooper()).post {
                    val bootResult = mutableMapOf<String, Any?>(
                        "success" to (bootStatus == BootStatus.SUCCESS),
                        "status" to bootStatus.name,
                    )
                    
                    // Add User information if available
                    user?.let { channelUser ->
                        val userMap = mutableMapOf<String, Any?>()
                        userMap["id"] = channelUser.id
                        userMap["memberId"] = channelUser.memberId
                        userMap["name"] = channelUser.name
                        userMap["avatarUrl"] = channelUser.avatarUrl
                        userMap["profile"] = channelUser.profile
                        userMap["alert"] = channelUser.alert
                        userMap["unread"] = channelUser.unread
                        userMap["language"] = channelUser.language?.toString()
                        userMap["tags"] = channelUser.tags
                        
                        bootResult["user"] = userMap
                    } ?: run {
                        bootResult["user"] = null
                    }
                    
                    result.success(bootResult)
                }
            }

        } catch (e: Exception) {
            result.error("BOOT_ERROR", e.message, null)
        }
    }
    
    private fun handleSleep(result: Result) {
        try {
            ChannelIO.sleep()
            result.success(null)
        } catch (e: Exception) {
            result.error("SLEEP_ERROR", e.message, null)
        }
    }
    
    private fun handleShutdown(result: Result) {
        try {
            ChannelIO.shutdown()
            result.success(null)
        } catch (e: Exception) {
            result.error("SHUTDOWN_ERROR", e.message, null)
        }
    }
    
    private fun handleShowChannelButton(result: Result) {
        try {
            ChannelIO.showChannelButton()
            result.success(null)
        } catch (e: Exception) {
            result.error("SHOW_CHANNEL_BUTTON_ERROR", e.message, null)
        }
    }
    
    private fun handleHideChannelButton(result: Result) {
        try {
            ChannelIO.hideChannelButton()
            result.success(null)
        } catch (e: Exception) {
            result.error("HIDE_CHANNEL_BUTTON_ERROR", e.message, null)
        }
    }
    
    private fun handleShowMessenger(result: Result) {
        try {
            ChannelIO.showMessenger(activity)
            result.success(null)
        } catch (e: Exception) {
            result.error("SHOW_MESSENGER_ERROR", e.message, null)
        }
    }
    
    private fun handleHideMessenger(result: Result) {
        try {
            ChannelIO.hideMessenger()
            result.success(null)
        } catch (e: Exception) {
            result.error("HIDE_MESSENGER_ERROR", e.message, null)
        }
    }
    
    private fun handleOpenChat(call: MethodCall, result: Result) {
        try {
            val chatId = call.argument<String>("chatId")
            val message = call.argument<String>("message")

            ChannelIO.openChat(activity, chatId, message)

            result.success(null)
        } catch (e: Exception) {
            result.error("OPEN_CHAT_ERROR", e.message, null)
        }
    }
    
    private fun handleOpenWorkflow(call: MethodCall, result: Result) {
        try {
            val workflowId = call.argument<String>("workflowId")
            ChannelIO.openWorkflow(activity, workflowId)
            result.success(null)
        } catch (e: Exception) {
            result.error("OPEN_WORKFLOW_ERROR", e.message, null)
        }
    }
    
    private fun handleTrack(call: MethodCall, result: Result) {
        try {
            val eventName = call.argument<String>("eventName") 
                ?: return result.error("MISSING_PARAMETER", "eventName is required", null)
            val eventProperty = call.argument<Map<String, Any>>("eventProperty")
            
            if (eventProperty != null) {
                ChannelIO.track(eventName, eventProperty)
            } else {
                ChannelIO.track(eventName)
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("TRACK_ERROR", e.message, null)
        }
    }
    
    private fun handleUpdateUser(call: MethodCall, result: Result) {
        try {
            val userData = UserData.Builder().apply {
                // Set profile
                call.argument<Map<String, Any>>("profile")?.let { profileMap ->
                    setProfileMap(profileMap)
                }
                
                // Set language
                call.argument<String>("language")?.let {
                    val lang = when(it) {
                        "ko" -> Language.KOREAN
                        "en" -> Language.ENGLISH
                        "ja" -> Language.JAPANESE
                        else -> Language.KOREAN
                    }
                    setLanguage(lang)
                }
                
                // Set tags
                call.argument<List<String>>("tags")?.let { tagList ->
                    setTags(tagList)
                }
                
                // Set subscription
                call.argument<Boolean>("unsubscribeTexting")?.let {
                    setUnsubscribeTexting(it)
                }
                
                call.argument<Boolean>("unsubscribeEmail")?.let {
                    setUnsubscribeEmail(it)
                }
            }.build()
            
            ChannelIO.updateUser(userData, object : UserUpdateCallback {
                override fun onComplete(exception: Exception?, user: User?) {
                    Handler(Looper.getMainLooper()).post {
                        if (exception == null) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                }
            })
            
        } catch (e: Exception) {
            result.error("UPDATE_USER_ERROR", e.message, null)
        }
    }
    
    private fun handleAddTags(call: MethodCall, result: Result) {
        try {
            val tags = call.argument<List<String>>("tags") 
                ?: return result.error("MISSING_PARAMETER", "tags is required", null)
                
            ChannelIO.addTags(tags, object : UserUpdateCallback {
                override fun onComplete(exception: Exception?, user: User?) {
                    Handler(Looper.getMainLooper()).post {
                        if (exception == null) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                }
            })
            
        } catch (e: Exception) {
            result.error("ADD_TAGS_ERROR", e.message, null)
        }
    }
    
    private fun handleRemoveTags(call: MethodCall, result: Result) {
        try {
            val tags = call.argument<List<String>>("tags") 
                ?: return result.error("MISSING_PARAMETER", "tags is required", null)
                
            ChannelIO.removeTags(tags, object : UserUpdateCallback {
                override fun onComplete(exception: Exception?, user: User?) {
                    Handler(Looper.getMainLooper()).post {
                        if (exception == null) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                }
            })
            
        } catch (e: Exception) {
            result.error("REMOVE_TAGS_ERROR", e.message, null)
        }
    }
    
    private fun handleSetPage(call: MethodCall, result: Result) {
        try {
            val page = call.argument<String>("page")
            val profile = call.argument<Map<String, Any>>("profile")
            
            ChannelIO.setPage(page, profile)
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_PAGE_ERROR", e.message, null)
        }
    }
    
    private fun handleResetPage(result: Result) {
        try {
            ChannelIO.resetPage()
            result.success(null)
        } catch (e: Exception) {
            result.error("RESET_PAGE_ERROR", e.message, null)
        }
    }
    
    private fun handleHidePopup(result: Result) {
        try {
            ChannelIO.hidePopup()
            result.success(null)
        } catch (e: Exception) {
            result.error("HIDE_POPUP_ERROR", e.message, null)
        }
    }
    
    private fun handleInitPushToken(call: MethodCall, result: Result) {
        try {
            val token = call.argument<String>("token") 
                ?: return result.error("MISSING_PARAMETER", "token is required", null)
            
            ChannelIO.initPushToken(token)
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_PUSH_TOKEN_ERROR", e.message, null)
        }
    }
    
    private fun handleIsChannelPushNotification(call: MethodCall, result: Result) {
        try {
            val payload = call.argument<Map<String, Any>>("payload") 
                ?: return result.error("MISSING_PARAMETER", "payload is required", null)
            
            val stringPayload = payload.mapValues { it.value.toString()}
            val isChannelPush = ChannelIO.isChannelPushNotification(stringPayload)
            result.success(isChannelPush)
        } catch (e: Exception) {
            result.error("IS_CHANNEL_PUSH_NOTIFICATION_ERROR", e.message, null)
        }
    }
    
    private fun handleReceivePushNotification(call: MethodCall, result: Result) {
        try {
            val payload = call.argument<Map<String, Any>>("payload") 
                ?: return result.error("MISSING_PARAMETER", "payload is required", null)
            
            val stringPayload = payload.mapValues { it.value.toString()}
            ChannelIO.receivePushNotification(activity, stringPayload)
            result.success(null)
        } catch (e: Exception) {
            result.error("RECEIVE_PUSH_NOTIFICATION_ERROR", e.message, null)
        }
    }
    
    private fun handleHasStoredPushNotification(result: Result) {
        try {
            val hasStored = ChannelIO.hasStoredPushNotification(activity)
            result.success(hasStored)
        } catch (e: Exception) {
            result.error("HAS_STORED_PUSH_NOTIFICATION_ERROR", e.message, null)
        }
    }
    
    private fun handleOpenStoredPushNotification(result: Result) {
        try {
            ChannelIO.openStoredPushNotification(activity)
            result.success(null)
        } catch (e: Exception) {
            result.error("OPEN_STORED_PUSH_NOTIFICATION_ERROR", e.message, null)
        }
    }
    
    private fun handleIsBooted(result: Result) {
        try {
            val isBooted = ChannelIO.isBooted()
            result.success(isBooted)
        } catch (e: Exception) {
            result.error("IS_BOOTED_ERROR", e.message, null)
        }
    }
    
    private fun handleSetDebugMode(call: MethodCall, result: Result) {
        try {
            val flag = call.argument<Boolean>("flag") 
                ?: return result.error("MISSING_PARAMETER", "flag is required", null)
            
            ChannelIO.setDebugMode(flag)
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_DEBUG_MODE_ERROR", e.message, null)
        }
    }
    
    private fun handleSetAppearance(call: MethodCall, result: Result) {
        try {
            val appearance = call.argument<String>("appearance") 
                ?: return result.error("MISSING_PARAMETER", "appearance is required", null)
            
            val appearanceEnum = when(appearance) {
                "light" -> Appearance.LIGHT
                "dark" -> Appearance.DARK
                else -> Appearance.SYSTEM
            }
            
            ChannelIO.setAppearance(appearanceEnum)
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_APPEARANCE_ERROR", e.message, null)
        }
    }
    
    fun dispose() {
        ChannelIO.setListener(null)
    }
}