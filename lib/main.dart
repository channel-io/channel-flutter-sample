import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'managers/channel_io_manager.dart';
import 'managers/fcm_manager.dart';
import 'firebase_options.dart';
import 'constants/texts.dart';

// Views imports
import 'views/test_sections/boot_test_section.dart';
import 'views/test_sections/profile_test_section.dart';
import 'views/test_sections/event_test_section.dart';
import 'views/test_sections/fcm_test_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize FCM
    await FCMManager().initialize();

    // FCM initialization completed
  } catch (e) {
    // FCM initialization failed
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ChannelIOManager channelIO = ChannelIOManager();
  final FCMManager fcmManager = FCMManager();
  bool _isBooted = false;
  String _status = '';
  String _lastEvent = '';
  Map<String, dynamic>? _lastBootResult;

  // PluginKey management
  String _currentPluginKey = 'CHANNEL_IO_PLUGIN_KEY'; // Default value

  // Event list management
  List<Map<String, dynamic>> _eventList = [];

  @override
  void initState() {
    super.initState();
    // Initialize default texts that will be replaced when localization is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _status = AppTexts.notBooted;
        _lastEvent = AppTexts.noEventsYet;
      });
    });
    _checkBootStatus();
    _setupChannelIOListeners();
    _setCurrentPage('MyHomePage');
  }

  /// Set current page
  Future<void> _setCurrentPage(String pageName) async {
    try {
      await channelIO.setPage(page: pageName);
    } catch (e) {
      // Page setting error occurred
    }
  }

  /// Add event to list
  void _addEvent(String eventName, Map<String, dynamic> params) {
    if (_isBooted) {
      setState(() {
        _eventList.add({
          'eventName': eventName,
          'params': params,
          'timestamp': DateTime.now(),
        });
        _lastEvent = eventName;
      });
    }
  }

  /// Setup ChannelIO event listeners
  void _setupChannelIOListeners() {
    // Channel button click event
    channelIO.setOnChannelButtonClicked(() {
      _addEvent('Channel Button Click', {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text(AppTexts.channelButtonClicked)),
        );
      }
    });

    // Badge count change event
    channelIO.setOnBadgeChanged((unread, alert) {
      _addEvent('Badge Count Changed', {'unread': unread, 'alert': alert});
    });

    // Chat created event
    channelIO.setOnChatCreated((chatId) {
      _addEvent('Chat Created', {'chatId': chatId});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('New chat created: $chatId')));
      }
    });

    // Popup data received event
    channelIO.setOnPopupDataReceived((popupData) {
      _addEvent('Popup Data Received', popupData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Popup: ${popupData['message'] ?? 'No message'}'),
          ),
        );
      }
    });

    // Push notification click event
    channelIO.setOnPushNotificationClicked((chatId) {
      _addEvent('Push Notification Click', {'chatId': chatId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Push notification clicked: $chatId')),
        );
      }
    });

    // URL click event
    channelIO.setOnUrlClicked((url) {
      _addEvent('URL Click', {'url': url});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('URL clicked: $url')));
      }
    });

    // Messenger show event
    channelIO.setOnShowMessenger(() {
      _addEvent('Messenger Shown', {});
    });

    // Messenger hide event
    channelIO.setOnHideMessenger(() {
      _addEvent('Messenger Hidden', {});
    });

    // User follow-up change event
    channelIO.setOnFollowUpChanged((user) {
      _addEvent('Follow-up Changed', user);
    });
  }

  /// Check ChannelIO boot status
  Future<void> _checkBootStatus() async {
    final isBooted = await channelIO.isBooted();
    setState(() {
      _isBooted = isBooted;

      // Basic boot status
      String baseStatus = isBooted
          ? 'ChannelIO Booted'
          : 'ChannelIO Not Booted';

      // Show detailed information if last boot result exists
      if (_lastBootResult != null) {
        final success = _lastBootResult!['success'] == true;
        final status = _lastBootResult!['status'];
        final user = _lastBootResult!['user'];
        final error = _lastBootResult!['error'];

        String statusInfo = '\nLast Boot: $status';

        if (success && user != null) {
          // Success case - display user info as JSON
          final userJson = JsonEncoder.withIndent('  ').convert(user);
          statusInfo += ' ✅\n👤 User Data:\n$userJson';
        } else {
          // Failure case - display error info
          statusInfo += ' ❌';
          if (error != null) {
            statusInfo += '\n❗ Error: $error';
          }
        }

        _status = baseStatus + statusInfo;
      } else {
        _status = baseStatus;
      }
    });
  }

  /// Update boot result
  void _updateBootResult(Map<String, dynamic> bootResult) {
    setState(() {
      _lastBootResult = bootResult;
    });
    _checkBootStatus(); // Update status
  }

  /// Toggle debug mode
  Future<void> _toggleDebugMode() async {
    await channelIO.setDebugMode(true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text(AppTexts.debugModeActivated)),
      );
    }
  }

  /// Change appearance mode
  Future<void> _changeAppearance(String appearance) async {
    await channelIO.setAppearance(appearance);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dark mode changed to $appearance!')),
      );
    }
  }

  @override
  void dispose() {
    // Clear ChannelIO event callbacks
    channelIO.clearAllCallbacks();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(AppTexts.appTitle),
        actions: [
          IconButton(
            onPressed: _checkBootStatus,
            icon: const Icon(Icons.refresh),
            tooltip: AppTexts.checkStatus,
          ),
          IconButton(
            onPressed: _toggleDebugMode,
            icon: const Icon(Icons.bug_report),
            tooltip: AppTexts.debugMode,
          ),
          PopupMenuButton<String>(
            onSelected: _changeAppearance,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'light',
                child: Row(
                  children: [
                    const Icon(Icons.light_mode, size: 20),
                    const SizedBox(width: 8),
                    const Text(AppTexts.light),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'dark',
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode, size: 20),
                    const SizedBox(width: 8),
                    const Text(AppTexts.dark),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'system',
                child: Row(
                  children: [
                    const Icon(Icons.brightness_6, size: 20),
                    const SizedBox(width: 8),
                    const Text(AppTexts.system),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Boot Test Section
            BootTestSection(
              isBooted: _isBooted,
              status: _status,
              currentPluginKey: _currentPluginKey,
              onBootStatusChanged: _checkBootStatus,
              onBootResult: _updateBootResult,
            ),

            // Profile Test Section
            ProfileTestSection(
              isBooted: _isBooted,
              userData: _lastBootResult?['user'] != null
                  ? Map<String, dynamic>.from(_lastBootResult!['user'] as Map)
                  : null,
            ),

            // Event Test Section
            EventTestSection(
              isBooted: _isBooted,
              lastEvent: _lastEvent,
              eventList: _eventList,
              channelIO: channelIO,
            ),

            // FCM Test Section
            const FCMTestSection(),

            // Bottom padding
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
