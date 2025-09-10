import 'dart:convert';
import 'package:flutter/material.dart';
import '../../managers/channel_io_manager.dart';
import '../../constants/texts.dart';
import '../../viewmodels/boot_test_viewmodel.dart';
import '../widgets/profile_input_form.dart';
import '../common/boot_required_mixin.dart';
import '../common/common_button.dart';
import '../common/common_card.dart';
import '../common/snackbar_helper.dart';
import '../common/dropdown_helper.dart';
import '../common/common_input_field.dart';

class BootTestSection extends StatefulWidget {
  final bool isBooted;
  final String status;
  final String currentPluginKey;
  final VoidCallback onBootStatusChanged;
  final Function(Map<String, dynamic>) onBootResult;

  const BootTestSection({
    super.key,
    required this.isBooted,
    required this.status,
    required this.currentPluginKey,
    required this.onBootStatusChanged,
    required this.onBootResult,
  });

  @override
  State<BootTestSection> createState() => _BootTestSectionState();
}

class _BootTestSectionState extends State<BootTestSection>
    with BootRequiredMixin {
  late final BootTestViewModel _viewModel;

  // Temporarily added for backward compatibility (to be removed later)
  ChannelIOManager get channelIO => ChannelIOManager();

  // Dropdown options
  static const List<String> _channelButtonIcons = [
    'channel',
    'chatBubbleFilled',
    'chatProgressFilled',
    'chatQuestionFilled',
    'chatLightningFilled',
    'chatBubbleAltFilled',
    'smsFilled',
    'commentFilled',
    'sendForwardFilled',
    'helpFilled',
    'chatProgress',
    'chatQuestion',
    'chatBubbleAlt',
    'sms',
    'comment',
    'sendForward',
    'communication',
    'headset',
  ];

  static const List<String> _positionOptions = ['left', 'right'];

  static const List<String> _bubblePositions = ['top', 'bottom'];

  // Profile input controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  // Member ID controller
  final TextEditingController _memberIdController = TextEditingController();

  // Channel Button Option controllers
  final TextEditingController _channelButtonXMarginController =
      TextEditingController();
  final TextEditingController _channelButtonYMarginController =
      TextEditingController();
  String _selectedChannelButtonIcon = 'channel';
  String _selectedChannelButtonPosition = 'right';

  // Bubble Option controllers
  final TextEditingController _bubbleYMarginController =
      TextEditingController();

  // Chat & Workflow controllers
  final TextEditingController _chatIdController = TextEditingController();
  final TextEditingController _workflowIdController = TextEditingController();
  String _selectedBubblePosition = 'top';

  // Boot Request/Response status variables
  Map<String, dynamic>? _lastBootRequest;
  Map<String, dynamic>? _lastBootResponse;

  @override
  void initState() {
    super.initState();
    _viewModel = BootTestViewModel();

    // Set default values
    _firstNameController.text = AppTexts.testUser;
    _lastNameController.text = 'CHT';
    _emailController.text = '';
    _mobileNumberController.text = '';
    _memberIdController.text = 'fluttertestuser';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _memberIdController.dispose();
    _channelButtonXMarginController.dispose();
    _channelButtonYMarginController.dispose();
    _bubbleYMarginController.dispose();
    _chatIdController.dispose();
    _workflowIdController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  ProfileInputForm get _profileForm => ProfileInputForm(
    firstNameController: _firstNameController,
    lastNameController: _lastNameController,
    emailController: _emailController,
    mobileNumberController: _mobileNumberController,
    isEnabled: !widget.isBooted,
  );

  Future<void> _anonymousBoot() async {
    if (!_profileForm.isRequiredFieldsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ First name and last name are required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final profileData = _profileForm.getProfileData();
      final channelButtonOption = _getChannelButtonOption();
      final bubbleOption = _getBubbleOption();

      // Save Boot Request
      final bootRequest = {
        'pluginKey': widget.currentPluginKey,
        'memberId': null, // No memberId in anonymous boot
        'language': 'ko',
        'profile': profileData,
        'channelButtonOption': channelButtonOption,
        'bubbleOption': bubbleOption,
      };

      setState(() {
        _lastBootRequest = bootRequest;
      });

      final bootResult = await channelIO.boot(
        pluginKey: widget.currentPluginKey,
        profile: profileData,
        channelButtonOption: channelButtonOption,
        bubbleOption: bubbleOption,
      );

      // Save Boot Response
      setState(() {
        _lastBootResponse = bootResult;
      });

      // Deliver Boot result to parent widget
      widget.onBootResult(bootResult);

      final success = bootResult['success'] == true;
      if (success) {
        if (mounted) {
          // User information logging
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Anonymous boot successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          final status = bootResult['status'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ChannelIO boot failed ($status)'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ChannelIO boot failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    widget.onBootStatusChanged();
  }

  Future<void> _memberBoot() async {
    if (!_profileForm.isRequiredFieldsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ First name and last name are required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final memberIdInput = _memberIdController.text.trim();
    if (memberIdInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter member ID for member boot'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final profileData = _profileForm.getProfileData();
      final channelButtonOption = _getChannelButtonOption();
      final bubbleOption = _getBubbleOption();

      // Save Boot Request
      final bootRequest = {
        'pluginKey': widget.currentPluginKey,
        'memberId': memberIdInput,
        'language': 'ko',
        'profile': profileData,
        'channelButtonOption': channelButtonOption,
        'bubbleOption': bubbleOption,
      };

      setState(() {
        _lastBootRequest = bootRequest;
      });

      final bootResult = await channelIO.boot(
        pluginKey: widget.currentPluginKey,
        memberId: memberIdInput,
        profile: profileData,
        channelButtonOption: channelButtonOption,
        bubbleOption: bubbleOption,
      );

      // Save Boot Response
      setState(() {
        _lastBootResponse = bootResult;
      });

      // Deliver Boot result to parent widget
      widget.onBootResult(bootResult);

      final success = bootResult['success'] == true;
      if (success) {
        if (mounted) {
          // User information logging
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Member boot successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          final status = bootResult['status'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ChannelIO boot failed ($status)'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ChannelIO boot failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    widget.onBootStatusChanged();
  }

  Future<void> _sleepChannelIO() async {
    try {
      await channelIO.sleep();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('😴 ChannelIO went to sleep')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sleep failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    widget.onBootStatusChanged();
  }

  Future<void> _shutdownChannelIO() async {
    try {
      await channelIO.shutdown();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('🔴 ChannelIO shut down')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shutdown failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    widget.onBootStatusChanged();
  }

  // Helper method - Create Channel Button Option
  Map<String, dynamic>? _getChannelButtonOption() {
    final xMargin = _channelButtonXMarginController.text.trim();
    final yMargin = _channelButtonYMarginController.text.trim();

    final option = <String, dynamic>{
      'icon': _selectedChannelButtonIcon,
      'position': _selectedChannelButtonPosition,
    };

    if (xMargin.isNotEmpty) {
      final xMarginInt = int.tryParse(xMargin);
      if (xMarginInt != null) {
        option['xMargin'] = xMarginInt;
      }
    }

    if (yMargin.isNotEmpty) {
      final yMarginInt = int.tryParse(yMargin);
      if (yMarginInt != null) {
        option['yMargin'] = yMarginInt;
      }
    }

    return option;
  }

  // Helper method - Create Bubble Option
  Map<String, dynamic>? _getBubbleOption() {
    final yMargin = _bubbleYMarginController.text.trim();

    final option = <String, dynamic>{'position': _selectedBubblePosition};

    if (yMargin.isNotEmpty) {
      final yMarginInt = int.tryParse(yMargin);
      if (yMarginInt != null) {
        option['yMargin'] = yMarginInt;
      }
    }

    return option;
  }

  // UI Controls methods
  Future<void> _showMessenger() async {
    if (!widget.isBooted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Please boot ChannelIO first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await channelIO.showMessenger();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Show messenger failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _hideMessenger() async {
    if (!widget.isBooted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Please boot ChannelIO first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await channelIO.hideMessenger();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hide messenger failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showChannelButton() async {
    try {
      await channelIO.showChannelButton();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Show channel button failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _hideChannelButton() async {
    try {
      await channelIO.hideChannelButton();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hide channel button failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _hidePopup() async {
    try {
      await channelIO.hidePopup();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Popup hidden!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hide popup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open chat
  Future<void> _openChat() async {
    if (!widget.isBooted) {
      SnackBarHelper.showWarning(context, 'Boot ChannelIO first to open chat');
      return;
    }

    try {
      await channelIO.openChat(
        chatId: _chatIdController.text.isNotEmpty
            ? _chatIdController.text
            : null,
        message: 'Hello from Flutter Test App!',
      );
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Chat opened successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Failed to open chat');
      }
    }
  }

  /// Open workflow
  Future<void> _openWorkflow() async {
    if (!widget.isBooted) {
      SnackBarHelper.showWarning(
        context,
        'Boot ChannelIO first to open workflow',
      );
      return;
    }

    try {
      await channelIO.openWorkflow(
        workflowId: _workflowIdController.text.isNotEmpty
            ? _workflowIdController.text
            : null,
      );
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Workflow opened successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Failed to open workflow');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        Icons.rocket_launch,
        color: widget.isBooted ? Colors.green : Colors.orange,
      ),
      title: Text(
        'Boot Test',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(widget.isBooted ? 'Booted' : 'Not Booted'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Boot Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Boot Status',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            widget.isBooted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: widget.isBooted ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Boot ${widget.isBooted ? 'success' : 'waiting'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      if (_lastBootResponse != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${AppTexts.statusUnknown} ${_lastBootResponse!['status'] ?? AppTexts.unknown}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Boot Request
              if (_lastBootRequest != null)
                Card(
                  child: ExpansionTile(
                    title: Text(
                      AppTexts.bootRequest,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Icon(Icons.upload, color: Colors.blue),
                    initiallyExpanded: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SelectableText(
                            JsonEncoder.withIndent(
                              '  ',
                            ).convert(_lastBootRequest!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_lastBootRequest != null) const SizedBox(height: 16),

              // Boot Response
              if (_lastBootResponse != null)
                Card(
                  child: ExpansionTile(
                    title: Text(
                      AppTexts.bootResponse,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Icon(
                      Icons.download,
                      color: _lastBootResponse!['success'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                    initiallyExpanded: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SelectableText(
                            JsonEncoder.withIndent(
                              '  ',
                            ).convert(_lastBootResponse!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_lastBootResponse != null) const SizedBox(height: 16),

              // Plugin Key (Read-only)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.pluginKeyConfig,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade50,
                        ),
                        child: SelectableText(
                          widget.currentPluginKey,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Member ID Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.memberId,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CommonInputField(
                        controller: _memberIdController,
                        enabled: !widget.isBooted,
                        hintText: AppTexts.memberIdHint,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Profile Information
              Card(
                child: ExpansionTile(
                  title: Text(
                    AppTexts.profileInformation,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(
                    Icons.person_outline,
                    color: widget.isBooted ? Colors.grey : Colors.blue,
                  ),
                  initiallyExpanded: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _profileForm,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Channel Button Options
              Card(
                child: ExpansionTile(
                  title: Text(
                    AppTexts.channelButtonOptions,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(
                    Icons.radio_button_checked,
                    color: widget.isBooted ? Colors.grey : Colors.cyan,
                  ),
                  initiallyExpanded: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon Dropdown
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  AppTexts.icon,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedChannelButtonIcon,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    menuMaxHeight: 300,
                                    items: DropdownHelper.buildStringItems(
                                      _channelButtonIcons,
                                    ),
                                    onChanged: widget.isBooted
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedChannelButtonIcon =
                                                  value!;
                                            });
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Position Dropdown
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Position:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedChannelButtonPosition,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    menuMaxHeight: 150,
                                    items: DropdownHelper.buildStringItems(
                                      _positionOptions,
                                    ),
                                    onChanged: widget.isBooted
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedChannelButtonPosition =
                                                  value!;
                                            });
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Margins
                          Row(
                            children: [
                              Expanded(
                                child: CommonInputField(
                                  controller: _channelButtonXMarginController,
                                  enabled: !widget.isBooted,
                                  keyboardType: TextInputType.number,
                                  labelText: 'X Margin',
                                  hintText: AppTexts.optional,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CommonInputField(
                                  controller: _channelButtonYMarginController,
                                  enabled: !widget.isBooted,
                                  keyboardType: TextInputType.number,
                                  labelText: 'Y Margin',
                                  hintText: AppTexts.optional,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bubble Options
              Card(
                child: ExpansionTile(
                  title: Text(
                    AppTexts.bubbleOptions,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    color: widget.isBooted ? Colors.grey : Colors.orange,
                  ),
                  initiallyExpanded: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Position Dropdown
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Position:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedBubblePosition,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    menuMaxHeight: 150,
                                    items: DropdownHelper.buildStringItems(
                                      _bubblePositions,
                                    ),
                                    onChanged: widget.isBooted
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedBubblePosition = value!;
                                            });
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Y Margin
                          CommonInputField(
                            controller: _bubbleYMarginController,
                            enabled: !widget.isBooted,
                            keyboardType: TextInputType.number,
                            labelText: 'Y Margin',
                            hintText: AppTexts.optional,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Boot Buttons
              Row(
                children: [
                  Expanded(
                    child: CommonButton.primary(
                      onPressed: widget.isBooted ? null : _anonymousBoot,
                      icon: Icons.person_outline,
                      label: AppTexts.anonymousBoot,
                      isFullWidth: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CommonButton.success(
                      onPressed: widget.isBooted ? null : _memberBoot,
                      icon: Icons.person,
                      label: AppTexts.memberBoot,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Sleep & Shutdown Buttons
              Row(
                children: [
                  Expanded(
                    child: CommonButton.accent(
                      onPressed: widget.isBooted ? _sleepChannelIO : null,
                      icon: Icons.bedtime,
                      label: AppTexts.sleep,
                      isFullWidth: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CommonButton.danger(
                      onPressed: widget.isBooted ? _shutdownChannelIO : null,
                      icon: Icons.power_off,
                      label: AppTexts.shutdown,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // UI Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UI Controls',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Messenger Controls (requires boot)
                      Row(
                        children: [
                          Expanded(
                            child: CommonButton.info(
                              onPressed: widget.isBooted
                                  ? _showMessenger
                                  : null,
                              icon: Icons.visibility,
                              label: AppTexts.showMessenger,
                              isFullWidth: false,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CommonButton.secondary(
                              onPressed: widget.isBooted
                                  ? _hideMessenger
                                  : null,
                              icon: Icons.visibility_off,
                              label: AppTexts.hideMessenger,
                              isFullWidth: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Channel Button Controls (no boot required)
                      Row(
                        children: [
                          Expanded(
                            child: CommonButton.primary(
                              onPressed: _showChannelButton,
                              icon: Icons.radio_button_checked,
                              label: AppTexts.showChannelButton,
                              isFullWidth: false,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CommonButton.secondary(
                              onPressed: _hideChannelButton,
                              icon: Icons.radio_button_off,
                              label: AppTexts.hideChannelButton,
                              isFullWidth: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Popup Control
                      CommonButton.warning(
                        onPressed: _hidePopup,
                        icon: Icons.close_fullscreen,
                        label: AppTexts.hidePopup,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Chat & Workflow
              CommonCard(
                title: AppTexts.chatAndWorkflow,
                children: [
                  CommonInputField(
                    controller: _chatIdController,
                    labelText: AppTexts.chatIdOptional,
                  ),
                  const SizedBox(height: 8),
                  CommonInputField(
                    controller: _workflowIdController,
                    labelText: AppTexts.workflowIdOptional,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton.success(
                          label: AppTexts.openChat,
                          icon: Icons.chat,
                          onPressed: _openChat,
                          isFullWidth: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonButton.accent(
                          label: AppTexts.workflow,
                          icon: Icons.auto_awesome,
                          onPressed: _openWorkflow,
                          isFullWidth: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
