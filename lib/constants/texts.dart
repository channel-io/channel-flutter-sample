/// App text constants
class AppTexts {
  // App
  static const appTitle = 'ChannelTalk Sample';
  static const checkStatus = 'Check Status';
  static const debugMode = 'Debug Mode';
  static const light = 'Light';
  static const dark = 'Dark';
  static const system = 'System';

  // Boot Test
  static const bootTest = 'Boot Test';
  static const booted = 'Booted';
  static const notBooted = 'Not Booted';
  static const currentBootStatus = 'Current Boot Status';
  static const bootRequest = 'Boot Request';
  static const bootResponse = 'Boot Response';
  static const pluginKeyConfig = 'Plugin Key Configuration';
  static const memberId = 'Member ID';
  static const memberIdHint = 'Enter member ID for member boot';
  static const profileInformation = 'Profile Information';
  static const channelButtonOptions = 'Channel Button Options';
  static const bubbleOptions = 'Bubble Options';
  static const icon = 'Icon:';
  static const position = 'Position:';
  static const optional = 'Optional';
  static const chatAndWorkflow = 'Chat & Workflow';
  static const chatIdOptional = 'Chat ID (Optional)';
  static const workflowIdOptional = 'Workflow ID (Optional)';
  static const anonymousBoot = 'Anonymous Boot';
  static const memberBoot = 'Member Boot';
  static const sleep = 'Sleep';
  static const shutdown = 'Shutdown';
  static const hidePopup = 'Hide Popup';
  static const openChat = 'Open Chat';
  static const workflow = 'Workflow';
  static const showChannelButton = 'Show Channel Button';
  static const hideChannelButton = 'Hide Channel Button';
  static const showMessenger = 'Show Messenger';
  static const hideMessenger = 'Hide Messenger';

  // Profile Test
  static const profileTest = 'Profile Test';
  static const firstName = 'First Name';
  static const lastName = 'Last Name';
  static const email = 'Email';
  static const mobileNumber = 'Mobile Number';
  static const enterFirstName = 'Enter first name';
  static const enterLastName = 'Enter last name';
  static const enterEmail = 'Enter email address';
  static const enterMobileNumber = 'Enter mobile number';
  static const requiredFields = 'Required Fields';
  static const optionalFields = 'Optional Fields';
  static const updateUserInfo = 'Update User Info';
  static const tagManagement = 'Tag Management';

  // Event Test
  static const eventTest = 'Event Test';
  static const eventList = 'Event List';
  static const lastEventLabel = 'Last Event:';
  static const noEventsYet = 'No events yet';
  static const totalEventsLabel = 'Total Events:';
  static const viewEventList = 'View Event List';
  static const track = 'Track';
  static const otherPageButton = 'OtherPage';
  static const sendClickEvent = 'Send Click Event';
  static const eventName = 'Event Name:';
  static const testButtonClickedEvent = 'test_button_clicked';

  // FCM Test
  static const fcmTest = 'FCM Test';
  static const fcmStatus = 'FCM Status';
  static const initialization = 'Initialization';
  static const completed = 'Completed';
  static const incomplete = 'Incomplete';
  static const fcmTokens = 'FCM/APNs Tokens';
  static const pushPermissions = 'Push Permissions';
  static const notificationPermissionStatus = 'Notification Permission Status:';
  static const fullPermissionActivated = '✅ Full Permission Activated';
  static const silentNotificationWarning =
      'Currently only silent notifications are allowed. Press the button above if you need sound/vibration.';
  static const pushNotificationsAndFCM = 'Push Notifications & FCM';
  static const printTokens = '📱 Print FCM/APNs Tokens';
  static const requestFullPermission = '🔊 Request Full Permission';
  static const requestNotificationPermission =
      '🔔 Request Notification Permission';
  static const none = 'None';

  // Messages
  static const nameRequired = '⚠️ First name and last name are required';
  static const anonymousBootSuccess = '✅ Anonymous boot successful!';
  static const memberBootSuccess = '✅ Member boot successful!';
  static const bootFailed = '❌ ChannelIO boot failed';
  static const sleepSuccessfully = '😴 ChannelIO went to sleep';
  static const shutdownSuccessfully = '🔴 ChannelIO shut down';
  static const bootFirst = '⚠️ Please boot ChannelIO first';
  static const popupHidden = 'Popup hidden!';
  static const chatOpenedSuccessfully = 'Chat opened successfully';
  static const failedToOpenChat = 'Failed to open chat';
  static const workflowOpenedSuccessfully = 'Workflow opened successfully';
  static const failedToOpenWorkflow = 'Failed to open workflow';
  static const bootFirstToOpenChat = 'Boot ChannelIO first to open chat';
  static const bootFirstToOpenWorkflow =
      'Boot ChannelIO first to open workflow';
  static const testMessage = 'Hello from Flutter Test App!';
  static const clickTrackEventSent = 'Click track event sent!';
  static const failedToSendTrackEvent = 'Failed to send track event';
  static const userInfoUpdated = '👤 User information updated!';
  static const userInfoUpdateFailed = 'User info update failed';
  static const requiredFieldsMessage =
      'Required fields (First Name, Last Name) must be filled';
  static const tagAdded = 'Tag added:';
  static const failedToAddTag = 'Failed to add tag:';
  static const tagRemoved = 'Tag removed:';
  static const failedToRemoveTag = 'Failed to remove tag:';
  static const multipleTagsAdded = 'tags added successfully!';
  static const multipleTagsCleared = 'tags cleared';
  static const failedToAddMultipleTags =
      'Failed to add {count} tags. All changes rolled back.';
  static const failedToClearTags =
      'Failed to clear {count} tags from ChannelIO';
  static const generate10Tags = 'Generate 10 Tags';
  static const clearAll = 'Clear All';
  static const tokenInfoPrinted =
      '📱 Token information has been printed to console';
  static const permissionUpdated = 'Permission updated';
  static const fullPermissionGranted =
      '✅ Full notification permission granted!';
  static const silentNotificationGranted =
      '⚠️ Only silent notifications granted. Enable sound/vibration in settings.';
  static const notificationPermissionDenied =
      '❌ Notification permission denied. Please allow in settings.';
  static const unknownPermissionStatus =
      '❓ Unable to determine notification permission status.';
  static const permissionRequestFailed = 'Permission request failed:';

  // Status
  static const statusWaiting = 'waiting';
  static const statusSuccess = 'success';
  static const unknown = 'Unknown';
  static const statusUnknown = 'Status:';

  // Pages
  static const otherPage = 'Other Page';
  static const otherPageDescription =
      'This is another page for testing page navigation and event tracking.';
  static const noEventsRecorded =
      'No events recorded yet.\nBoot ChannelIO and interact to see events.';

  // Default values
  static const testUser = 'TestUser';

  // Common actions
  static const debugModeActivated = 'Debug mode activated!';
  static const channelButtonClicked = 'Channel button clicked!';

  // Error messages
  static const sleepFailed = 'Sleep failed:';
  static const shutdownFailed = 'Shutdown failed:';
  static const showMessengerFailed = 'Show messenger failed:';
  static const hideMessengerFailed = 'Hide messenger failed:';
  static const hidePopupFailed = 'Hide popup failed:';
  static const showChannelButtonFailed = 'Show channel button failed:';
  static const hideChannelButtonFailed = 'Hide channel button failed:';
  static const unknownError = 'Unknown error';

  // Boot first messages
  static const bootFirstToAccessProfileTest =
      'Boot ChannelIO first to access Profile Test features';
  static const bootFirstToAccessEventTest =
      'Boot ChannelIO first to access Event Test features';

  // Tags
  static const currentUserTagsDescription =
      'Current user tags from ChannelIO. You can modify and update them.';
  static const tagsLoadAfterBootDescription =
      'Tags will be loaded after ChannelIO boot. You can add test tags locally.';
  static const currentUserProfileDescription =
      'Current user profile from ChannelIO. You can modify and update it.';
  static const profileLoadAfterBootDescription =
      'Profile will be loaded after ChannelIO boot. Please boot first.';
  static const noTagsToClear = 'No tags to clear';
  static const tagAddedLocally = 'Tag added locally:';
  static const tagRemovedLocally = 'Tag removed locally:';
}
