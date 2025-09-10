import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../../viewmodels/profile_test_viewmodel.dart';
import '../common/common_card.dart';
import '../common/common_button.dart';
import '../common/boot_required_mixin.dart';
import '../common/snackbar_helper.dart';
import '../common/tag_chip.dart';
import '../widgets/profile_input_form.dart';

class ProfileTestSection extends StatefulWidget {
  final bool isBooted;
  final Map<String, dynamic>? userData;

  const ProfileTestSection({super.key, required this.isBooted, this.userData});

  @override
  State<ProfileTestSection> createState() => _ProfileTestSectionState();
}

class _ProfileTestSectionState extends State<ProfileTestSection>
    with BootRequiredMixin {
  late final ProfileTestViewModel _viewModel;
  bool _isExpanded = false;

  // Profile Input Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileTestViewModel();
    _viewModel.addListener(_onViewModelChanged);

    // Load user data based on Boot state (profile + tags)
    _loadUserData();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(ProfileTestSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update profile form when userData changes
    if (oldWidget.userData != widget.userData) {
      _loadUserData();
    }

    // Update expansion state when Boot status changes
    if (oldWidget.isBooted != widget.isBooted && !widget.isBooted) {
      // If Boot is released, expansion state is also released
      setState(() {
        _isExpanded = false;
      });
    }
  }

  void _loadUserData() {
    if (widget.isBooted && widget.userData != null) {
      // If booted and user data exists, fill with that data
      final userData = widget.userData!;

      // Parse profile information
      final name = userData['name']?.toString() ?? '';
      final nameParts = name.trim().split(' ');

      if (nameParts.length >= 2) {
        _firstNameController.text = nameParts[0];
        _lastNameController.text = nameParts.sublist(1).join(' ');
      } else if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts[0];
        _lastNameController.text = '';
      } else {
        _firstNameController.text = userData['firstName']?.toString() ?? '';
        _lastNameController.text = userData['lastName']?.toString() ?? '';
      }

      _emailController.text = userData['email']?.toString() ?? '';
      _mobileNumberController.text = userData['mobileNumber']?.toString() ?? '';

      // Parse tag information
      final userTags = userData['tags'];
      if (userTags != null) {
        List<String> tags = [];
        if (userTags is List) {
          tags = userTags.map((tag) => tag.toString()).toList();
        } else if (userTags is String) {
          // If it's a comma-separated string
          tags = userTags
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
        _viewModel.setTags(tags);
      } else {
        _viewModel.clearAllTags();
      }
    } else {
      // If not booted or no user data, empty state
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _mobileNumberController.clear();
      _viewModel.clearAllTags();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  ProfileInputForm get _profileForm => ProfileInputForm(
    firstNameController: _firstNameController,
    lastNameController: _lastNameController,
    emailController: _emailController,
    mobileNumberController: _mobileNumberController,
    isEnabled: widget.isBooted, // Modification possible only when booted
  );

  Future<void> _updateUserInfo() async {
    if (!mounted) return;
    await executeIfBooted(context, widget.isBooted, () async {
      if (!_profileForm.isRequiredFieldsValid()) {
        if (!mounted) return;
        SnackBarHelper.showError(context, AppTexts.requiredFieldsMessage);
        return;
      }

      final profileData = _profileForm.getProfileData();
      final success = await _viewModel.updateUserInfoWithData(profileData);

      if (!mounted) return;
      if (success) {
        SnackBarHelper.showSuccess(context, AppTexts.userInfoUpdated);
      } else {
        SnackBarHelper.showError(context, AppTexts.userInfoUpdateFailed);
      }
    });
  }

  // ===== Tag-related methods =====

  /// Add random tag
  Future<void> _addRandomTag() async {
    final newTag = _viewModel.addRandomTag();

    // Try adding to ChannelIO first if booted
    if (widget.isBooted && mounted) {
      final success = await _viewModel.addSingleTagToChannelIO(newTag);
      if (!mounted) return;

      if (success) {
        SnackBarHelper.showSuccess(context, '${AppTexts.tagAdded} $newTag');
      } else {
        // ChannelIO addition failed - rollback from local
        _viewModel.removeTag(newTag);
        SnackBarHelper.showError(context, '${AppTexts.failedToAddTag} $newTag');
      }
    } else {
      // Add locally only when not booted
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          '${AppTexts.tagAddedLocally} $newTag',
        );
      }
    }
  }

  /// Generate 10 random tags
  Future<void> _add10RandomTags() async {
    if (!mounted) return;
    await executeIfBooted(context, widget.isBooted, () async {
      final newTags = _viewModel.add10RandomTags();
      final success = await _viewModel.addTagsToChannelIO(newTags);

      if (!mounted) return;
      if (success) {
        SnackBarHelper.showSuccess(
          context,
          '${newTags.length} ${AppTexts.multipleTagsAdded}',
        );
      } else {
        // Remove locally created tags on ChannelIO addition failure (rollback)
        for (final tag in newTags) {
          _viewModel.removeTag(tag);
        }
        SnackBarHelper.showError(
          context,
          'Failed to add ${newTags.length} tags. All changes rolled back.',
        );
      }
    });
  }

  /// Remove all tags
  Future<void> _clearAllTags() async {
    final tagsToRemove = List<String>.from(_viewModel.currentTags);

    if (tagsToRemove.isEmpty) {
      if (mounted) {
        SnackBarHelper.showWarning(context, AppTexts.noTagsToClear);
      }
      return;
    }

    // If booted, try to remove from ChannelIO first
    if (widget.isBooted && mounted) {
      final success = await _viewModel.removeTagsFromChannelIO(tagsToRemove);
      if (!mounted) return;

      if (success) {
        _viewModel.clearAllTags();
        SnackBarHelper.showSuccess(
          context,
          '${tagsToRemove.length} ${AppTexts.multipleTagsCleared}',
        );
      } else {
        SnackBarHelper.showError(
          context,
          'Failed to clear ${tagsToRemove.length} tags from ChannelIO',
        );
      }
    } else {
      // Clear locally only when not booted
      _viewModel.clearAllTags();
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          '${tagsToRemove.length} tags cleared locally',
        );
      }
    }
  }

  /// Remove individual tag
  Future<void> _removeTag(String tag) async {
    // If booted, try to remove from ChannelIO first
    if (widget.isBooted && mounted) {
      final success = await _viewModel.removeSingleTagFromChannelIO(tag);
      if (!mounted) return;

      if (success) {
        _viewModel.removeTag(tag);
        SnackBarHelper.showSuccess(context, '${AppTexts.tagRemoved} $tag');
      } else {
        SnackBarHelper.showError(context, '${AppTexts.failedToRemoveTag} $tag');
      }
    } else {
      // Remove locally only when not booted
      _viewModel.removeTag(tag);
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          '${AppTexts.tagRemovedLocally} $tag',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.person, color: getStatusColor(widget.isBooted)),
      title: Text(
        AppTexts.profileTest,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(getStatusSubtitle(widget.isBooted)),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        if (expanded && !widget.isBooted) {
          // Show warning message and prevent expansion when not booted
          SnackBarHelper.showWarning(
            context,
            AppTexts.bootFirstToAccessProfileTest,
          );
        } else {
          // Allow expansion only when booted
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
                    // Profile Information Input
                    CommonCard(
                      title: AppTexts.profileInformation,
                      subtitle: widget.isBooted
                          ? AppTexts.currentUserProfileDescription
                          : AppTexts.profileLoadAfterBootDescription,
                      children: [
                        _profileForm,
                        const SizedBox(height: 16),
                        CommonButton.primary(
                          label: AppTexts.updateUserInfo,
                          icon: Icons.person_outline,
                          onPressed: _updateUserInfo,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tag Management Section
                    CommonCard(
                      title: AppTexts.tagManagement,
                      subtitle: widget.isBooted
                          ? AppTexts.currentUserTagsDescription
                          : AppTexts.tagsLoadAfterBootDescription,
                      children: [
                        // Tag Chips Display
                        TagChipList(
                          tags: _viewModel.currentTags,
                          onTagDeleted: _removeTag,
                          onAddTag: _addRandomTag,
                          isDeleteEnabled: true,
                          isAddEnabled: true,
                          spacing: 8.0,
                          runSpacing: 8.0,
                        ),

                        const SizedBox(height: 16),

                        // Tag Generation Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton.info(
                                label: AppTexts.generate10Tags,
                                icon: Icons.auto_awesome,
                                onPressed: widget.isBooted
                                    ? _add10RandomTags
                                    : null,
                                isFullWidth: false,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CommonButton.warning(
                                label: AppTexts.clearAll,
                                icon: Icons.clear_all,
                                onPressed: _viewModel.isEmpty
                                    ? null
                                    : _clearAllTags,
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
            ]
          : [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Boot ChannelIO first to access Profile Test features',
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
