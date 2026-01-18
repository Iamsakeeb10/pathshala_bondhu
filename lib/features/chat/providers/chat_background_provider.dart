import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/utils/app_colors.dart';

enum BackgroundType { color, gradient, pattern, image }

class ChatBackgroundProvider extends ChangeNotifier {
  // Keys for SharedPreferences
  static const String _backgroundTypeKey = 'chat_background_type';
  static const String _colorIndexKey = 'chat_color_index';
  static const String _gradientIndexKey = 'chat_gradient_index';
  static const String _patternIndexKey = 'chat_pattern_index';
  static const String _customImagePathKey = 'chat_custom_image_path';

  // State
  BackgroundType _backgroundType = BackgroundType.color;
  int _colorIndex = 0;
  int _gradientIndex = 0;
  int _patternIndex = 0;
  String? _customImagePath;
  bool _isLoading = false;

  // Getters
  BackgroundType get backgroundType => _backgroundType;
  int get colorIndex => _colorIndex;
  int get gradientIndex => _gradientIndex;
  int get patternIndex => _patternIndex;
  String? get customImagePath => _customImagePath;
  bool get isLoading => _isLoading;

  // Predefined colors - Using PathShala Bondhu's theme palette
  static const List<Color> backgroundColors = [
    Color(0xFFEEF2F7), // Light grey-blue (default)
    AppColors.primary, // Primary yellow
    Color(0xFFE8F5E9), // Light green
    Color(0xFFE3F2FD), // Light blue
    Color(0xFFFCE4EC), // Light pink
    Color(0xFFFFF3E0), // Light orange
    Color(0xFFF3E5F5), // Light purple
    Color(0xFFE0F2F1), // Light teal
    Color(0xFFFFFDE7), // Light yellow
    Color(0xFFE8EAF6), // Light indigo
    AppColors.grey100,
    AppColors.grey200,
  ];

  // Predefined gradients - Using PathShala Bondhu's palette
  static const List<List<Color>> backgroundGradients = [
    [Color(0xFFF5F7FA), Color(0xFFEEF1F5)], // Subtle grey
    [AppColors.primaryLight, AppColors.primary], // Primary gradient
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)], // Green gradient
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Blue gradient
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)], // Pink gradient
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)], // Orange gradient
    [AppColors.accent, AppColors.primary], // Accent to primary
    [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Teal gradient
    [AppColors.grey100, AppColors.grey300], // Grey gradient
    [Color(0xFFE8EAF6), Color(0xFFC5CAE9)], // Indigo gradient
  ];

  // Predefined patterns (emoji-based)
  static const List<String> patternEmoji = [
    '📚', // Books
    '✏️', // Pencil
    '🎓', // Graduation
    '🏫', // School
    '📝', // Notes
    '🌟', // Star
    '💡', // Idea
    '🎨', // Art
  ];

  ChatBackgroundProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final typeIndex = prefs.getInt(_backgroundTypeKey) ?? 0;
      _backgroundType = BackgroundType.values[typeIndex.clamp(0, BackgroundType.values.length - 1)];

      _colorIndex = prefs.getInt(_colorIndexKey) ?? 0;
      _gradientIndex = prefs.getInt(_gradientIndexKey) ?? 0;
      _patternIndex = prefs.getInt(_patternIndexKey) ?? 0;
      _customImagePath = prefs.getString(_customImagePathKey);

      // Validate indices
      _colorIndex = _colorIndex.clamp(0, backgroundColors.length - 1);
      _gradientIndex = _gradientIndex.clamp(0, backgroundGradients.length - 1);
      _patternIndex = _patternIndex.clamp(0, patternEmoji.length - 1);

      // Validate custom image exists
      if (_customImagePath != null) {
        final file = File(_customImagePath!);
        if (!await file.exists()) {
          _customImagePath = null;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat background prefs: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_backgroundTypeKey, _backgroundType.index);
      await prefs.setInt(_colorIndexKey, _colorIndex);
      await prefs.setInt(_gradientIndexKey, _gradientIndex);
      await prefs.setInt(_patternIndexKey, _patternIndex);
      if (_customImagePath != null) {
        await prefs.setString(_customImagePathKey, _customImagePath!);
      } else {
        await prefs.remove(_customImagePathKey);
      }
    } catch (e) {
      debugPrint('Error saving chat background prefs: $e');
    }
  }

  // Set background color
  void setColor(int index) {
    if (index < 0 || index >= backgroundColors.length) return;
    _backgroundType = BackgroundType.color;
    _colorIndex = index;
    notifyListeners();
    _savePreferences();
  }

  // Set background gradient
  void setGradient(int index) {
    if (index < 0 || index >= backgroundGradients.length) return;
    _backgroundType = BackgroundType.gradient;
    _gradientIndex = index;
    notifyListeners();
    _savePreferences();
  }

  // Set background pattern
  void setPattern(int index) {
    if (index < 0 || index >= patternEmoji.length) return;
    _backgroundType = BackgroundType.pattern;
    _patternIndex = index;
    notifyListeners();
    _savePreferences();
  }

  // Pick and set custom image
  Future<void> pickCustomImage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Compress the image
      final bytes = await pickedFile.readAsBytes();
      final compressed = await _compressImage(bytes);

      // Save to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'chat_bg_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File('${appDir.path}/$fileName');
      await savedFile.writeAsBytes(compressed);

      // Delete old custom image if exists
      if (_customImagePath != null) {
        try {
          final oldFile = File(_customImagePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (_) {}
      }

      _customImagePath = savedFile.path;
      _backgroundType = BackgroundType.image;
      _isLoading = false;
      notifyListeners();
      _savePreferences();
    } catch (e) {
      debugPrint('Error picking custom image: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 1080,
        minHeight: 1920,
        quality: 80,
      );
      return result;
    } catch (e) {
      debugPrint('Compression failed, using original: $e');
      return bytes;
    }
  }

  // Clear custom image
  Future<void> clearCustomImage() async {
    if (_customImagePath != null) {
      try {
        final file = File(_customImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      _customImagePath = null;
    }

    // Fall back to default color
    _backgroundType = BackgroundType.color;
    _colorIndex = 0;
    notifyListeners();
    _savePreferences();
  }

  // Get current background decoration
  BoxDecoration getBackgroundDecoration() {
    switch (_backgroundType) {
      case BackgroundType.color:
        return BoxDecoration(color: backgroundColors[_colorIndex]);

      case BackgroundType.gradient:
        final colors = backgroundGradients[_gradientIndex];
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        );

      case BackgroundType.pattern:
        return BoxDecoration(color: AppColors.grey100);

      case BackgroundType.image:
        if (_customImagePath != null) {
          return BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(_customImagePath!)),
              fit: BoxFit.cover,
            ),
          );
        }
        return BoxDecoration(color: backgroundColors[0]);
    }
  }

  // Get pattern emoji for overlay
  String? getPatternEmoji() {
    if (_backgroundType == BackgroundType.pattern) {
      return patternEmoji[_patternIndex];
    }
    return null;
  }

  // Reset to default
  void resetToDefault() {
    clearCustomImage();
    _backgroundType = BackgroundType.color;
    _colorIndex = 0;
    notifyListeners();
    _savePreferences();
  }
}
