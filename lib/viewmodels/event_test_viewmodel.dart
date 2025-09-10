import 'package:flutter/material.dart';
import '../managers/channel_io_manager.dart';

/// ViewModel for Event Test section
class EventTestViewModel extends ChangeNotifier {
  final ChannelIOManager _channelIO = ChannelIOManager();

  /// Track event
  Future<bool> trackEvent({
    required String eventName,
    required BuildContext context,
  }) async {
    try {
      await _channelIO.track(
        eventName: eventName.isNotEmpty ? eventName : 'test_button_clicked',
        eventProperty: {
          'source': 'flutter_test',
          'section': 'event_test',
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Theme.of(context).platform.name,
          'action': 'button_press',
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Open chat
  Future<bool> openChat({String? chatId}) async {
    try {
      await _channelIO.openChat(
        chatId: chatId?.isNotEmpty == true ? chatId : null,
        message: 'Hello from Flutter Test App!', // Keep as hardcoded for now
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Open workflow
  Future<bool> openWorkflow({String? workflowId}) async {
    try {
      await _channelIO.openWorkflow(
        workflowId: workflowId?.isNotEmpty == true ? workflowId : null,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Return default event name
  String getDefaultEventName() => 'test_button_clicked';

  /// Return default workflow ID
  String getDefaultWorkflowId() => 'sample_workflow';
}
