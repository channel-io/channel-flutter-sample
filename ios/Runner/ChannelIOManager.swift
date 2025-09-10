import Foundation
import Flutter
import ChannelIOFront

/**
 * ChannelIOManager is a manager class that handles all features of the ChannelIO iOS SDK.
 * It implements CHTChannelPluginDelegate to receive SDK events and deliver them to Flutter.
 */
class ChannelIOManager: NSObject, CHTChannelPluginDelegate {
    
    private let methodChannel: FlutterMethodChannel
    
    /**
     * Initialize ChannelIOManager
     * - Parameters:
     *   - methodChannel: MethodChannel for communication with Flutter
     */
    init(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
        super.init()
        
        // Register ChannelPluginDelegate
        ChannelIO.delegate = self
    }
    
    /**
     * Handle methods called from Flutter.
     */
    func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "boot":
            handleBoot(call: call, result: result)
        case "sleep":
            handleSleep(result: result)
        case "shutdown":
            handleShutdown(result: result)
        case "showChannelButton":
            handleShowChannelButton(result: result)
        case "hideChannelButton":
            handleHideChannelButton(result: result)
        case "showMessenger":
            handleShowMessenger(result: result)
        case "hideMessenger":
            handleHideMessenger(result: result)
        case "openChat":
            handleOpenChat(call: call, result: result)
        case "openWorkflow":
            handleOpenWorkflow(call: call, result: result)
        case "track":
            handleTrack(call: call, result: result)
        case "updateUser":
            handleUpdateUser(call: call, result: result)
        case "addTags":
            handleAddTags(call: call, result: result)
        case "removeTags":
            handleRemoveTags(call: call, result: result)
        case "setPage":
            handleSetPage(call: call, result: result)
        case "resetPage":
            handleResetPage(result: result)
        case "hidePopup":
            handleHidePopup(result: result)
        case "initPushToken":
            handleInitPushToken(call: call, result: result)
        case "isChannelPushNotification":
            handleIsChannelPushNotification(call: call, result: result)
        case "receivePushNotification":
            handleReceivePushNotification(call: call, result: result)
        case "hasStoredPushNotification":
            handleHasStoredPushNotification(result: result)
        case "openStoredPushNotification":
            handleOpenStoredPushNotification(result: result)
        case "isBooted":
            handleIsBooted(result: result)
        case "setDebugMode":
            handleSetDebugMode(call: call, result: result)
        case "setAppearance":
            handleSetAppearance(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // =============================================================================
    // CHTChannelPluginDelegate Implementation - Receive ChannelIO SDK Events
    // =============================================================================
    
    /**
     * Called when the channel button is clicked.
     */
    @objc func onChannelButtonClicked() {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onChannelButtonClicked", arguments: nil)
        }
    }
    
    /**
     * Called when the badge count changes.
     */
    @objc func onBadgeChanged(unread: Int, alert: Int) {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onBadgeChanged", arguments: [
                "unread": Int(unread),
                "alert": Int(alert)
            ])
        }
    }
    
    /**
     * Called when a chat is created.
     */
    @objc func onChatCreated(chatId: String) {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onChatCreated", arguments: ["chatId": chatId])
        }
    }
    
    /**
     * Called when a popup is displayed.
     */
    @objc func onPopupDataReceived(event: CHTPopupData) {
        DispatchQueue.main.async {
            let eventData: [String: Any] = [
                "chatId": event.chatId,
                "avatarUrl": event.avatarUrl,
                "name": event.name,
                "message": event.message ?? ""
            ]
            self.methodChannel.invokeMethod("onPopupDataReceived", arguments: eventData)
        }
    }
    
    /**
     * Called when a push notification is clicked.
     */
    @objc func onPushNotificationClicked(chatId: String) {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onPushNotificationClicked", arguments: ["chatId": chatId])
        }
    }
    
    /**
     * CHTChannelPluginDelegate method called when a URL is clicked.
     * 
     * Current implementation: Forward all URLs to Flutter and open in default browser
     * 
     * @param url The clicked URL object
     * @return Bool
     *   - true: Internal handling by ChannelIO (opens in WebView within the app)
     *   - false: Opens in default browser
     * 
     * ⚠️ If different handling based on URL patterns is needed:
     * Modify this function to examine the url parameter and conditionally return true/false.
     * 
     * Example:
     * ```swift
     * @objc func onUrlClicked(url: URL) -> Bool {
     *     DispatchQueue.main.async {
     *         self.methodChannel.invokeMethod("onUrlClicked", arguments: ["url": url.absoluteString])
     *     }
     *     
     *     let urlString = url.absoluteString
     *     switch true {
     *     case urlString.hasPrefix("https://your-internal-domain.com"):
     *         return true  // Open within app
     *     case urlString.contains("external"):
     *         return false  // Open in external browser
     *     default:
     *         return false  // Default: external browser
     *     }
     * }
     * ```
     */
    @objc func onUrlClicked(url: URL) -> Bool {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onUrlClicked", arguments: ["url": url.absoluteString])
        }
        return false // Returns false to open in default browser
    }
    
    /**
     * Called when the messenger is displayed.
     */
    @objc func onShowMessenger() {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onShowMessenger", arguments: nil)
        }
    }
    
    /**
     * Called when the messenger is hidden.
     */
    @objc func onHideMessenger() {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onHideMessenger", arguments: nil)
        }
    }
    
    /**
     * Called when user follow-up actions change.
     */
    @objc func onFollowUpChanged(data: [String: Any]) {
        DispatchQueue.main.async {
            self.methodChannel.invokeMethod("onFollowUpChanged", arguments: data)
        }
    }
    
    // =============================================================================
    // ChannelIO SDK Feature Implementation
    // =============================================================================
    
    /**
     * ChannelIO SDK boot processing
     */
    private func handleBoot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let pluginKey = args["pluginKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "pluginKey is required", details: nil))
            return
        }
        
        // Configure BootConfig
        let bootConfig = CHTBootConfig(pluginKey: pluginKey)
        
        // Set memberId
        if let memberId = args["memberId"] as? String {
            bootConfig.memberId = memberId
        }
        
        // Set language
        if let language = args["language"] as? String {
            switch language {
            case "ko":
                bootConfig.language = .korean
            case "en":
                bootConfig.language = .english
            case "ja":
                bootConfig.language = .japanese
            default:
                bootConfig.language = .korean
            }
        }
        
        // Set theme
        if let appearance = args["appearance"] as? String {
            switch appearance {
            case "light":
                bootConfig.appearance = .light
            case "dark":
                bootConfig.appearance = .dark
            default:
                bootConfig.appearance = .system
            }
        }
      
        // Set default event tracking
        if let trackDefaultEvent = args["trackDefaultEvent"] as? Bool {
            bootConfig.trackDefaultEvent = trackDefaultEvent
        }
        
        // Set profile
        if let profileMap = args["profile"] as? [String: Any] {
            let name = profileMap["name"] as? String
            let avatarUrl = profileMap["avatarUrl"] as? String
            let mobileNumber = profileMap["mobileNumber"] as? String
            let email = profileMap["email"] as? String
            
            let profile = CHTProfile(name: name, avatarUrl: avatarUrl, mobileNumber: mobileNumber, email: email)
            
            // Set additional properties
            profileMap.forEach { (key, value) in
                if !["name", "avatarUrl", "mobileNumber", "email"].contains(key) {
                    profile.set(propertyKey: key, value: value as AnyObject?)
                }
            }
            
            bootConfig.profile = profile
        }
        
        // Set Channel Button Option
        if let channelButtonOptionMap = args["channelButtonOption"] as? [String: Any] {
            let icon: CHTChannelButtonIcon
            if let iconStr = channelButtonOptionMap["icon"] as? String {
                switch iconStr {
                case "channel":
                    icon = .channel
                case "chatBubbleFilled":
                    icon = .chatBubbleFilled
                case "chatProgressFilled":
                    icon = .chatProgressFilled
                case "chatQuestionFilled":
                    icon = .chatQuestionFilled
                case "chatLightningFilled":
                    icon = .chatLightningFilled
                case "chatBubbleAltFilled":
                    icon = .chatBubbleAltFilled
                case "smsFilled":
                    icon = .smsFilled
                case "commentFilled":
                    icon = .commentFilled
                case "sendForwardFilled":
                    icon = .sendForwardFilled
                case "helpFilled":
                    icon = .helpFilled
                case "chatProgress":
                    icon = .chatProgress
                case "chatQuestion":
                    icon = .chatQuestion
                case "chatBubbleAlt":
                    icon = .chatBubbleAlt
                case "sms":
                    icon = .sms
                case "comment":
                    icon = .comment
                case "sendForward":
                    icon = .sendForward
                case "communication":
                    icon = .communication
                case "headset":
                    icon = .headset
                default:
                    icon = .channel
                }
            } else {
                icon = .channel
            }
            
            let position: CHTChannelButtonPosition
            if let positionStr = channelButtonOptionMap["position"] as? String {
                switch positionStr {
                case "left":
                    position = .left
                case "right":
                    position = .right
                default:
                    position = .right
                }
            } else {
                position = .right
            }
            
            let xMargin = Float(channelButtonOptionMap["xMargin"] as? Int ?? 0)
            let yMargin = Float(channelButtonOptionMap["yMargin"] as? Int ?? 0)
            
            let channelButtonOption = CHTChannelButtonOption(
                icon: icon,
                position: position,
                xMargin: xMargin,
                yMargin: yMargin
            )
            
            bootConfig.channelButtonOption = channelButtonOption
        }
        
        // Set Bubble Option
        if let bubbleOptionMap = args["bubbleOption"] as? [String: Any] {
            let position: CHTBubblePosition
            if let positionStr = bubbleOptionMap["position"] as? String {
                switch positionStr {
                case "top":
                    position = .top
                case "bottom":
                    position = .bottom
                default:
                    position = .top
                }
            } else {
                position = .top
            }
            
            let yMargin = Float(bubbleOptionMap["yMargin"] as? Int ?? 0)
            
            let bubbleOption = CHTBubbleOption(position: position, yMargin: yMargin)
            
            bootConfig.bubbleOption = bubbleOption
        }
        
        // Perform ChannelIO boot
        ChannelIO.boot(with: bootConfig) { (status, user) in
            DispatchQueue.main.async {
                var bootResult: [String: Any?] = [
                    "success": status == .success,
                    "status": self.bootStatusToString(status)
                ]
                
                // Add User information if available
                if let channelUser = user {
                    var userMap: [String: Any?] = [:]
                    userMap["id"] = channelUser.id
                    userMap["memberId"] = channelUser.memberId
                    userMap["name"] = channelUser.name
                    userMap["avatarUrl"] = channelUser.avatarUrl
                    userMap["profile"] = channelUser.profile
                    userMap["alert"] = channelUser.alert
                    userMap["unread"] = channelUser.unread
                    userMap["language"] = channelUser.language
                    userMap["tags"] = channelUser.tags
                    
                    bootResult["user"] = userMap
                } else {
                    bootResult["user"] = nil
                }
                
                result(bootResult)
            }
        }
    }
    
    /**
     * Convert BootStatus to string
     */
    private func bootStatusToString(_ status: CHTBootStatus) -> String {
        switch status {
        case .success:
            return "SUCCESS"
        case .notInitialized:
            return "NOT_INITIALIZED"
        case .networkTimeout:
            return "NETWORK_TIMEOUT"
        case .notAvailableVersion:
            return "NOT_AVAILABLE_VERSION"
        case .serviceUnderConstruction:
            return "SERVICE_UNDER_CONSTRUCTION"
        case .requirePayment:
            return "REQUIRE_PAYMENT"
        case .accessDenied:
            return "ACCESS_DENIED"
        case .unknown:
            return "UNKNOWN"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    /**
     * Handle ChannelIO SDK sleep
     */
    private func handleSleep(result: @escaping FlutterResult) {
        ChannelIO.sleep()
        result(nil)
    }
    
    /**
     * Handle ChannelIO SDK shutdown
     */
    private func handleShutdown(result: @escaping FlutterResult) {
        ChannelIO.shutdown()
        result(nil)
    }
    
    /**
     * Show channel button
     */
    private func handleShowChannelButton(result: @escaping FlutterResult) {
        ChannelIO.showChannelButton()
        result(nil)
    }
    
    /**
     * Hide channel button
     */
    private func handleHideChannelButton(result: @escaping FlutterResult) {
        ChannelIO.hideChannelButton()
        result(nil)
    }
    
    /**
     * Show messenger
     */
    private func handleShowMessenger(result: @escaping FlutterResult) {
        ChannelIO.showMessenger()
        result(nil)
    }
    
    /**
     * Hide messenger
     */
    private func handleHideMessenger(result: @escaping FlutterResult) {
        ChannelIO.hideMessenger()
        result(nil)
    }
    
    /**
     * Open specific chat
     */
    private func handleOpenChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are required", details: nil))
            return
        }
        
        let chatId = args["chatId"] as? String
        let message = args["message"] as? String
        
        if let chatId = chatId {
            ChannelIO.openChat(with: chatId, message: message)
        } else {
            ChannelIO.openChat(with: nil, message: message)
        }
        result(nil)
    }
    
    /**
     * Open workflow
     */
    private func handleOpenWorkflow(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let workflowId = args["workflowId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "workflowId is required", details: nil))
            return
        }
        
        ChannelIO.openWorkflow(with: workflowId)
        result(nil)
    }
    
    /**
     * Track event
     */
    private func handleTrack(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let eventName = args["eventName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "eventName is required", details: nil))
            return
        }
        
        let eventProperties = args["properties"] as? [String: Any]
        
        if let properties = eventProperties {
            ChannelIO.track(eventName: eventName, eventProperty: properties)
        } else {
            ChannelIO.track(eventName: eventName, eventProperty: nil)
        }
        result(nil)
    }
    
    /**
     * Update user information
     */
    private func handleUpdateUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "User data is required", details: nil))
            return
        }
        
        var profile: [String: Any] = [:]
        
        // Set basic user information
        if let name = args["name"] as? String {
            profile["name"] = name
        }
        if let email = args["email"] as? String {
            profile["email"] = email
        }
        if let mobileNumber = args["mobileNumber"] as? String {
            profile["mobileNumber"] = mobileNumber
        }
        if let avatarUrl = args["avatarUrl"] as? String {
            profile["avatarUrl"] = avatarUrl
        }
        
        // Set language
        if let language = args["language"] as? String {
            profile["language"] = language
        }
        
        // Set tags
        if let tags = args["tags"] as? [String] {
            profile["tags"] = tags
        }
        
        // Set subscription
        if let unsubscribeTexting = args["unsubscribeTexting"] as? Bool {
            profile["unsubscribeTexting"] = unsubscribeTexting
        }
        if let unsubscribeEmail = args["unsubscribeEmail"] as? Bool {
            profile["unsubscribeEmail"] = unsubscribeEmail
        }
        
        // Add custom properties
        if let properties = args["properties"] as? [String: Any] {
            for (key, value) in properties {
                profile[key] = value
            }
        }
        
        // Perform user information update
        ChannelIO.updateUser(with: profile) { success, user in
            DispatchQueue.main.async {
                result(success)
            }
        }
    }
    
    /**
     * Add tags
     */
    private func handleAddTags(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let tags = args["tags"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "tags are required", details: nil))
            return
        }
        
        ChannelIO.addTags(tags) { error, user in
            DispatchQueue.main.async {
                if error == nil {
                    result(true)
                } else {
                    result(false)
                }
            }
        }
    }
    
    /**
     * Remove tags
     */
    private func handleRemoveTags(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let tags = args["tags"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "tags are required", details: nil))
            return
        }
        
        ChannelIO.removeTags(tags) { error, user in
            DispatchQueue.main.async {
                if error == nil {
                    result(true)
                } else {
                    result(false)
                }
            }
        }
    }
    
    /**
     * Set page
     */
    private func handleSetPage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let page = args["page"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "page is required", details: nil))
            return
        }
        
        let profile = args["profile"] as? [String: Any] ?? [:]
        ChannelIO.setPage(page, profile: profile)
        result(nil)
    }
    
    /**
     * Reset page setting
     */
    private func handleResetPage(result: @escaping FlutterResult) {
        ChannelIO.resetPage()
        result(nil)
    }
    
    /**
     * Hide popup
     */
    private func handleHidePopup(result: @escaping FlutterResult) {
        ChannelIO.hidePopup()
        result(nil)
    }
    
    /**
     * Initialize push token
     */
    private func handleInitPushToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let token = args["token"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "token is required", details: nil))
            return
        }
        
        ChannelIO.initPushToken(tokenString: token)
        result(nil)
    }
    
    /**
     * Check if it's a channel push notification
     */
    private func handleIsChannelPushNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let payload = args["payload"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "payload is required", details: nil))
            return
        }
        
        let isChannelPush = ChannelIO.isChannelPushNotification(payload)
        result(isChannelPush)
    }
    
    /**
     * Handle push notification reception
     */
    private func handleReceivePushNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let payload = args["payload"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "payload is required", details: nil))
            return
        }
        
        ChannelIO.receivePushNotification(payload)
        result(nil)
    }
    
    /**
     * Check stored push notification
     */
    private func handleHasStoredPushNotification(result: @escaping FlutterResult) {
        let hasStored = ChannelIO.hasStoredPushNotification
        result(hasStored)
    }
    
    /**
     * Open stored push notification
     */
    private func handleOpenStoredPushNotification(result: @escaping FlutterResult) {
        ChannelIO.openStoredPushNotification()
        result(nil)
    }
    
    /**
     * Check boot status
     */
    private func handleIsBooted(result: @escaping FlutterResult) {
        let isBooted = ChannelIO.isBooted
        result(isBooted)
    }
    
    /**
     * Set debug mode
     */
    private func handleSetDebugMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let flag = args["flag"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "flag is required", details: nil))
            return
        }
        
        ChannelIO.setDebugMode(with: flag)
        result(nil)
    }
    
    /**
     * Set theme
     */
    private func handleSetAppearance(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appearance = args["appearance"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "appearance is required", details: nil))
            return
        }
        
        let appearanceEnum: CHTAppearance
        switch appearance {
        case "light":
            appearanceEnum = .light
        case "dark":
            appearanceEnum = .dark
        default:
            appearanceEnum = .system
        }
        
        ChannelIO.setAppearance(appearanceEnum)
        result(nil)
    }
    
    /**
     * Release delegate when memory is released
     */
    func dispose() {
        ChannelIO.delegate = nil
    }
}
