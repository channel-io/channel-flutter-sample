import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../../managers/channel_io_manager.dart';
import '../common/common_button.dart';

class OtherPage extends StatefulWidget {
  final ChannelIOManager channelIO;

  const OtherPage({super.key, required this.channelIO});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  @override
  void initState() {
    super.initState();
    _setCurrentPage(
      'OtherPage',
    ); // Keep as 'OtherPage' for consistency with ChannelIO setPage
  }

  @override
  void dispose() {
    _setCurrentPage('MyHomePage'); // Keep as 'MyHomePage' for consistency
    super.dispose();
  }

  /// Set current page
  Future<void> _setCurrentPage(String pageName) async {
    try {
      await widget.channelIO.setPage(page: pageName);
    } catch (e) {
      // Page setting error occurred
    }
  }

  /// Execute Send Click Event
  Future<void> _sendClickEvent() async {
    try {
      await widget.channelIO.track(
        eventName: 'CLICK_TRACK_BUTTON',
        eventProperty: {
          'source': 'other_page',
          'action': 'button_click',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text(AppTexts.clickTrackEventSent)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text(AppTexts.failedToSendTrackEvent)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.otherPage),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pages, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                AppTexts.otherPage,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                AppTexts.otherPageDescription,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              CommonButton.primary(
                onPressed: _sendClickEvent,
                icon: Icons.send,
                label: AppTexts.sendClickEvent,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
