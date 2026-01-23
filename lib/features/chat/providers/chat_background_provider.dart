// lib/features/chat/providers/chat_background_provider.dart
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';

enum ChatBackgroundType { color, gradient, pattern, custom }

class ChatBackgroundProvider with ChangeNotifier {
  ChatBackgroundType _backgroundType = ChatBackgroundType.color;
  int _selectedColorIndex = 0;
  int _selectedGradientIndex = 0;
  int _selectedPatternIndex = 0;
  String? _customImagePath;
  bool _isLoading = false;

  // Getters
  ChatBackgroundType get backgroundType => _backgroundType;
  int get selectedColorIndex => _selectedColorIndex;
  int get selectedGradientIndex => _selectedGradientIndex;
  int get selectedPatternIndex => _selectedPatternIndex;
  String? get customImagePath => _customImagePath;
  bool get isLoading => _isLoading;

  // WhatsApp-inspired color palette - More variety and beautiful colors
  static const List<Color> colors = [
    // WhatsApp Default & Light Theme
    Color(0xFFECE5DD), // WhatsApp chat background
    Color(0xFFDCF8C6), // WhatsApp sent message
    Color(0xFFE2F7CB), // Light green
    Color(0xFFF0F4C3), // Lime
    // Soft Teals & Greens
    Color(0xFFB2DFDB),
    Color(0xFF80CBC4),
    Color(0xFF4DB6AC),
    Color(0xFF26A69A),
    // Beautiful Blues
    Color(0xFFB3E5FC),
    Color(0xFF81D4FA),
    Color(0xFF4FC3F7),
    Color(0xFF29B6F6),
    // Warm Sunset Tones
    Color(0xFFFFE0B2),
    Color(0xFFFFCC80),
    Color(0xFFFFB74D),
    Color(0xFFFFA726),
    // Soft Pinks & Roses
    Color(0xFFF8BBD0),
    Color(0xFFF48FB1),
    Color(0xFFEC407A),
    Color(0xFFE91E63),
    // Purples & Lavenders
    Color(0xFFE1BEE7),
    Color(0xFFCE93D8),
    Color(0xFFBA68C8),
    Color(0xFFAB47BC),
    // Grays & Neutrals
    Color(0xFFF5F5F5),
    Color(0xFFEEEEEE),
    Color(0xFFE0E0E0),
    Color(0xFFBDBDBD),
    // Deep/Dark Options
    Color(0xFF0D1418), // WhatsApp dark mode
    Color(0xFF1F2C34), // WhatsApp dark secondary
    Color(0xFF075E54), // WhatsApp teal
    Color(0xFF128C7E), // WhatsApp light teal
  ];

  // Modern gradient backgrounds - More options
  static const List<List<Color>> gradients = [
    // WhatsApp Teal
    [Color(0xFF075E54), Color(0xFF128C7E)],
    // WhatsApp Green
    [Color(0xFF25D366), Color(0xFF128C7E)],
    // Sunset
    [Color(0xFFFF512F), Color(0xFFDD2476)],
    // Ocean Blue
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    // Purple Love
    [Color(0xFFDA22FF), Color(0xFF9733EE)],
    // Peachy
    [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    // Mint Fresh
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    // Calm
    [Color(0xFFEECDA3), Color(0xFFEF629F)],
    // Twilight
    [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    // Rose Gold
    [Color(0xFFF4C4F3), Color(0xFFFC67FA)],
    // Forest
    [Color(0xFF134E5E), Color(0xFF71B280)],
    // Royal
    [Color(0xFF141E30), Color(0xFF243B55)],
    // Cotton Candy
    [Color(0xFFD299C2), Color(0xFFFEF9D7)],
    // Mango
    [Color(0xFFFFE259), Color(0xFFFFA751)],
    // Deep Sea
    [Color(0xFF1CB5E0), Color(0xFF000851)],
    // Autumn
    [Color(0xFFDAD299), Color(0xFFB0DAB9)],
  ];

  // Pattern asset image paths
  static const List<String> patternAssets = [
    // First three original
    'assets/images/pattern_one.jpg',
    'assets/images/pattern_two.jpg',
    'assets/images/pattern_three.jpg',

    // New items (4–8) using same naming convention
    'assets/images/pattern_four.jpg',
    'assets/images/pattern_five.jpg',
    'assets/images/pattern_six.jpg',
    'assets/images/pattern_seven.jpg',
    'assets/images/pattern_eight.jpg',
    'assets/images/pattern_nine.jpg',
    'assets/images/pattern_ten.jpg',
    'assets/images/pattern_eleven.jpg',
  ];

  // Pattern display names for labels
  static const List<String> patternNames = [
    'Doodle',
    'Bubbles',
    'Hearts',
    'Stars',
    'Circles',
    'Diamonds',
    'Hexagons',
    'Triangles',
    'Squiggles',
    'Confetti',
    'Leaves',
    'Music',
  ];

  ChatBackgroundProvider() {
    // Set default to pattern_ten (index 9 in the patternAssets list)
    _backgroundType = ChatBackgroundType.pattern;
    _selectedPatternIndex = 9; // pattern_ten.jpg
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to pattern type (index 2) if not set
      final typeIndex =
          prefs.getInt('chat_bg_type') ?? ChatBackgroundType.pattern.index;
      _backgroundType = ChatBackgroundType.values[typeIndex];
      _selectedColorIndex = prefs.getInt('chat_bg_color_index') ?? 0;
      _selectedGradientIndex = prefs.getInt('chat_bg_gradient_index') ?? 0;
      // Default to pattern_ten (index 9) if not set
      _selectedPatternIndex = prefs.getInt('chat_bg_pattern_index') ?? 9;
      _customImagePath = prefs.getString('chat_bg_custom_image');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat background preferences: $e');
    }
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('chat_bg_type', _backgroundType.index);
      await prefs.setInt('chat_bg_color_index', _selectedColorIndex);
      await prefs.setInt('chat_bg_gradient_index', _selectedGradientIndex);
      await prefs.setInt('chat_bg_pattern_index', _selectedPatternIndex);
      if (_customImagePath != null) {
        await prefs.setString('chat_bg_custom_image', _customImagePath!);
      } else {
        await prefs.remove('chat_bg_custom_image');
      }
    } catch (e) {
      debugPrint('Error saving chat background preferences: $e');
    }
  }

  void selectColor(int index) {
    _backgroundType = ChatBackgroundType.color;
    _selectedColorIndex = index;
    notifyListeners();
    _saveToPreferences();
  }

  void selectGradient(int index) {
    _backgroundType = ChatBackgroundType.gradient;
    _selectedGradientIndex = index;
    notifyListeners();
    _saveToPreferences();
  }

  void selectPattern(int index) {
    _backgroundType = ChatBackgroundType.pattern;
    _selectedPatternIndex = index;
    notifyListeners();
    _saveToPreferences();
  }

  void setCustomImage(String path) {
    _backgroundType = ChatBackgroundType.custom;
    _customImagePath = path;
    notifyListeners();
    _saveToPreferences();
  }

  void clearCustomImage() {
    _customImagePath = null;
    _backgroundType = ChatBackgroundType.color;
    notifyListeners();
    _saveToPreferences();
  }

  // Get current background color
  Color get currentColor => colors[_selectedColorIndex];

  // Get current gradient colors
  List<Color> get currentGradient => gradients[_selectedGradientIndex];

  // Get current pattern asset
  String get currentPatternAsset => patternAssets[_selectedPatternIndex];
  String get currentPatternName => patternNames[_selectedPatternIndex];

  /// Pick image from camera or gallery
  Future<void> pickCustomImage(BuildContext context) async {
    try {
      final source = await _showImageSourceBottomSheet(context);
      if (source == null) return;

      final hasPermission = await _requestPermission(source, context);
      if (!hasPermission) return;

      _isLoading = true;
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Compress image
      final compressedPath = await _compressImage(pickedFile.path);

      if (compressedPath != null) {
        setCustomImage(compressedPath);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error picking image: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceBottomSheet(BuildContext context) async {
    final t = AppLocalizations.of(context);

    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(t?.translate('take_photo') ?? 'Take Photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: Text(t?.translate('choose_from_gallery') ?? 'Choose from Gallery'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPermission(
    ImageSource source,
    BuildContext context,
  ) async {
    Permission permission;
    String permissionName;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
      permissionName = 'Camera';
    } else {
      if (Platform.isIOS) {
        permission = Permission.photos;
        permissionName = 'Photos';
      } else {
        final isAndroid13OrHigher = await _isAndroid13OrHigher();
        if (isAndroid13OrHigher) {
          permission = Permission.photos;
          permissionName = 'Photos';
        } else {
          permission = Permission.storage;
          permissionName = 'Storage';
        }
      }
    }

    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied && context.mounted) {
        _showPermissionDeniedDialog(context, permissionName);
      }
      return false;
    }

    if (status.isPermanentlyDenied && context.mounted) {
      _showPermissionDeniedDialog(context, permissionName);
    }

    return false;
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  void _showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName permission is required to select images. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<String?> _compressImage(String path) async {
    try {
      final dir = Directory.systemTemp;
      final targetPath =
          '${dir.absolute.path}/chat_bg_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: 85,
        minWidth: 1080,
        minHeight: 1920,
      );

      return result?.path;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Build the background widget for chat screen
  Widget buildBackground({required Widget child}) {
    switch (_backgroundType) {
      case ChatBackgroundType.color:
        return Container(color: currentColor, child: child);

      case ChatBackgroundType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: currentGradient,
            ),
          ),
          child: child,
        );

      case ChatBackgroundType.pattern:
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(currentPatternAsset),
              fit: BoxFit.cover,
              repeat: ImageRepeat.noRepeat,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.05), // Subtle overlay for readability
                BlendMode.darken,
              ),
            ),
          ),
          child: child,
        );

      case ChatBackgroundType.custom:
        if (_customImagePath != null && File(_customImagePath!).existsSync()) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(_customImagePath!)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
              ),
            ),
            child: child,
          );
        }
        return Container(color: colors[0], child: child);
    }
  }
}
