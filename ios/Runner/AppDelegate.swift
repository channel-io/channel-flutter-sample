import Flutter
import UIKit
import UserNotifications
// Import ChannelIOFront framework.
import ChannelIOFront

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  /**
   * MethodChannel for communication with Flutter
   * Channel name: 'channel_io_manager'
   */
  private let CHANNEL = "channel_io_manager"
  private var channelIOManager: ChannelIOManager?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
    
    // Initialize ChannelIOManager
    self.channelIOManager = ChannelIOManager(methodChannel: channel)
    
    // Set MethodChannel handler - delegate all calls to ChannelIOManager
    channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      self?.channelIOManager?.handleMethodCall(call: call, result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize ChannelIO iOS SDK
    ChannelIO.initialize(application)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  /**
   * Token registration success
   */
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    ChannelIO.initPushToken(deviceToken: deviceToken)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  /**
   * Handle push notification click
   *
   * Check if it's a ChannelIO message:
   * - If ChannelIO message, handle directly in native
   * - If general message, delegate to Flutter FCM
   */
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    if ChannelIO.isChannelPushNotification(userInfo) {
      ChannelIO.receivePushNotification(userInfo)
      ChannelIO.storePushNotification(userInfo)
    }
     
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
  
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if ChannelIO.isChannelPushNotification(userInfo) {
      ChannelIO.receivePushNotification(userInfo)
    }
    
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
  /**
   * Release resources when application terminates
   */
  override func applicationWillTerminate(_ application: UIApplication) {
    self.channelIOManager = nil
    super.applicationWillTerminate(application)
  }
}
