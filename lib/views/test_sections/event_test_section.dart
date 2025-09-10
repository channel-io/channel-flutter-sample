import 'package:flutter/material.dart';
import '../../managers/channel_io_manager.dart';
import '../../constants/texts.dart';
import '../../viewmodels/event_test_viewmodel.dart';
import '../common/common_card.dart';
import '../common/common_button.dart';
import '../common/boot_required_mixin.dart';
import '../common/snackbar_helper.dart';
import '../pages/event_list_page.dart';
import '../pages/other_page.dart';

class EventTestSection extends StatefulWidget {
  final bool isBooted;
  final String lastEvent;
  final List<Map<String, dynamic>> eventList;
  final ChannelIOManager channelIO;

  const EventTestSection({
    super.key,
    required this.isBooted,
    required this.lastEvent,
    required this.eventList,
    required this.channelIO,
  });

  @override
  State<EventTestSection> createState() => _EventTestSectionState();
}

class _EventTestSectionState extends State<EventTestSection>
    with BootRequiredMixin {
  late final EventTestViewModel _viewModel;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = EventTestViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EventTestSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update expansion state when Boot status changes
    if (oldWidget.isBooted != widget.isBooted && !widget.isBooted) {
      // If Boot is released, expansion state is also released
      setState(() {
        _isExpanded = false;
      });
    }
  }

  Future<void> _trackEvent() async {
    final success = await _viewModel.trackEvent(
      eventName: 'test_button_clicked',
      context: context,
    );

    if (!mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(context, AppTexts.clickTrackEventSent);
    } else {
      SnackBarHelper.showError(context, AppTexts.failedToSendTrackEvent);
    }
  }

  /// Navigate to event list page
  void _navigateToEventList() {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventListPage(
          eventList: widget.eventList,
          channelIO: widget.channelIO,
        ),
      ),
    );
  }

  /// Navigate to other page
  void _navigateToOtherPage() {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtherPage(channelIO: widget.channelIO),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.analytics, color: getStatusColor(widget.isBooted)),
      title: Text(
        AppTexts.eventTest,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(getStatusSubtitle(widget.isBooted)),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        if (expanded && !widget.isBooted) {
          // Display warning message and prevent expansion when not booted
          SnackBarHelper.showWarning(
            context,
            'Boot ChannelIO first to access Event Test features',
          );
        } else {
          // Allow expansion only in booted state
          setState(() {
            _isExpanded = expanded;
          });
        }
      },
      children: widget.isBooted
          ? [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Event List
                    CommonCard(
                      title: AppTexts.eventList,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.lastEventLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.lastEvent.isEmpty
                                    ? AppTexts.noEventsYet
                                    : widget.lastEvent,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${AppTexts.totalEventsLabel} ${widget.eventList.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        CommonButton.info(
                          label: AppTexts.viewEventList,
                          icon: Icons.list,
                          onPressed: _navigateToEventList,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Track
                    CommonCard(
                      title: AppTexts.track,
                      children: [
                        CommonButton.primary(
                          label: AppTexts.otherPageButton,
                          icon: Icons.navigate_next,
                          onPressed: _navigateToOtherPage,
                        ),
                        const SizedBox(height: 8),
                        CommonButton.info(
                          label: AppTexts.sendClickEvent,
                          icon: Icons.send,
                          onPressed: _trackEvent,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            '${AppTexts.eventName} ${AppTexts.testButtonClickedEvent}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          : [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Boot ChannelIO first to access Event Test features',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
