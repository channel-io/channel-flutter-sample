import 'dart:convert';
import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../../managers/channel_io_manager.dart';

class EventListPage extends StatefulWidget {
  final List<Map<String, dynamic>> eventList;
  final ChannelIOManager channelIO;

  const EventListPage({
    super.key,
    required this.eventList,
    required this.channelIO,
  });

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  void initState() {
    super.initState();
    _setCurrentPage(
      'EventListPage',
    ); // Keep as 'EventListPage' for consistency with ChannelIO setPage
  }

  @override
  void dispose() {
    _setCurrentPage('MyHomePage');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.eventList),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: widget.eventList.isEmpty
          ? Center(
              child: Text(
                AppTexts.noEventsRecorded,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.eventList.length,
              itemBuilder: (context, index) {
                final event =
                    widget.eventList[widget.eventList.length -
                        1 -
                        index]; // Display in chronological order
                final timestamp = event['timestamp'] as DateTime;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event name and timestamp
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event['eventName'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Event parameters
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            const JsonEncoder.withIndent(
                              '  ',
                            ).convert(event['params']),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
