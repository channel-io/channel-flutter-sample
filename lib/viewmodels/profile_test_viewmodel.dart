import 'dart:math';
import 'package:flutter/foundation.dart';
import '../managers/channel_io_manager.dart';

/// ViewModel for Profile Test section (including tag functionality)
class ProfileTestViewModel extends ChangeNotifier {
  final ChannelIOManager _channelIO = ChannelIOManager();
  final Random _random = Random();

  // Tag related state
  List<String> _currentTags = [];

  /// Update user information (user input data)
  Future<bool> updateUserInfoWithData(Map<String, dynamic> profileData) async {
    try {
      // Update profile data with additional metadata
      final updatedProfile = {
        ...profileData,
        'lastUpdated': DateTime.now().toIso8601String(),
        'source': 'profile_test_section',
      };

      final success = await _channelIO.updateUser(
        profile: updatedProfile,
        language: 'ko',
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  // ===== Tag-related methods =====

  /// Current tag list
  List<String> get currentTags => List.unmodifiable(_currentTags);

  /// Current tag count
  int get tagCount => _currentTags.length;

  /// Check if tags are empty
  bool get isEmpty => _currentTags.isEmpty;

  /// Generate new random tag
  String generateRandomTag() {
    final randomNumber = _random.nextInt(10000);
    return 'tagTest_$randomNumber';
  }

  /// Add single tag (prevent duplicates)
  void addTag(String tag) {
    if (tag.isNotEmpty && !_currentTags.contains(tag)) {
      _currentTags.add(tag);
      notifyListeners();
    }
  }

  /// Add random tag
  String addRandomTag() {
    final newTag = generateRandomTag();
    addTag(newTag);
    return newTag;
  }

  /// Generate 10 random tags
  List<String> add10RandomTags() {
    final newTags = <String>[];
    for (int i = 0; i < 10; i++) {
      final newTag = generateRandomTag();
      if (!_currentTags.contains(newTag)) {
        _currentTags.add(newTag);
        newTags.add(newTag);
      }
    }
    notifyListeners();
    return newTags;
  }

  /// Remove single tag
  void removeTag(String tag) {
    if (_currentTags.remove(tag)) {
      notifyListeners();
    }
  }

  /// Remove all tags
  void clearAllTags() {
    if (_currentTags.isNotEmpty) {
      _currentTags.clear();
      notifyListeners();
    }
  }

  /// Set tag list
  void setTags(List<String> tags) {
    _currentTags = List<String>.from(tags);
    notifyListeners();
  }

  /// Add tags to ChannelIO
  Future<bool> addTagsToChannelIO(List<String> tags) async {
    if (tags.isEmpty) return false;

    try {
      final success = await _channelIO.addTags(tags);
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Remove tags from ChannelIO
  Future<bool> removeTagsFromChannelIO(List<String> tags) async {
    if (tags.isEmpty) return false;

    try {
      final success = await _channelIO.removeTags(tags);
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Add specific tag to ChannelIO
  Future<bool> addSingleTagToChannelIO(String tag) async {
    return addTagsToChannelIO([tag]);
  }

  /// Remove specific tag from ChannelIO
  Future<bool> removeSingleTagFromChannelIO(String tag) async {
    return removeTagsFromChannelIO([tag]);
  }
}
