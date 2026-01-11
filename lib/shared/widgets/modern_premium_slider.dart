import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A modern, premium carousel slider widget with auto-play and manual navigation.
///
/// Features:
/// - Auto-play with configurable interval
/// - Seamless infinite loop
/// - Manual navigation (prev/next)
/// - Tap callback for individual items
/// - Smooth animations
/// - Pause/resume functionality
/// - Cached network images for better performance
class ModernPremiumSlider extends StatefulWidget {
  /// List of image URLs to display in the carousel
  final List<String> bannerImages;

  /// Height of the carousel
  final double height;

  /// Auto-play interval duration
  final Duration autoPlayInterval;

  /// Callback when an image is tapped
  final void Function(int index)? onImageTap;

  /// Duration for programmatic animations
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  /// Border radius for images
  final double borderRadius;

  /// Horizontal padding for items
  final double itemPadding;

  /// Whether to show navigation controls
  final bool showControls;

  /// Whether to show play/pause button
  final bool showPlayPauseButton;

  /// Whether to start with auto-play enabled
  final bool autoPlayEnabled;

  const ModernPremiumSlider({
    super.key,
    required this.bannerImages,
    required this.height,
    this.autoPlayInterval = const Duration(seconds: 8),
    this.onImageTap,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.animationCurve = Curves.easeInOut,
    this.borderRadius = 12.0,
    this.itemPadding = 6.0,
    this.showControls = true,
    this.showPlayPauseButton = true,
    this.autoPlayEnabled = true,
  }) : assert(bannerImages.length > 0, 'bannerImages cannot be empty');

  @override
  State<ModernPremiumSlider> createState() => _ModernPremiumSliderState();
}

class _ModernPremiumSliderState extends State<ModernPremiumSlider> {
  late final CarouselController _controller;
  late int _current;
  late final int _actualCount;
  late final int _totalItems;
  late bool _isAutoPlaying;
  bool _isAnimating = false;
  bool _isProgrammaticScroll = false;
  Timer? _autoPlayTimer;
  Timer? _scrollEndTimer;

  @override
  void initState() {
    print('🟨 Slider from init ${widget.bannerImages.length}');

    super.initState();
    _actualCount = widget.bannerImages.isNotEmpty
        ? widget.bannerImages.length
        : 1;
    _totalItems = _actualCount * 1000;
    _current = _actualCount * 500;
    _isAutoPlaying = widget.autoPlayEnabled;
    _controller = CarouselController(initialItem: _current);

    // Listen to scroll position changes
    _controller.addListener(_onCarouselScroll);

    if (_isAutoPlaying) {
      _scheduleNextSlide();
    }
  }

  @override
  void didUpdateWidget(ModernPremiumSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the banner images changed
    if (oldWidget.bannerImages.length != widget.bannerImages.length ||
        !_listEquals(oldWidget.bannerImages, widget.bannerImages)) {
      print('🟦 Slider images updated: ${widget.bannerImages.length}');

      // Recalculate counts
      _actualCount = widget.bannerImages.isNotEmpty
          ? widget.bannerImages.length
          : 1;
      _totalItems = _actualCount * 1000;

      // Reset to a safe middle position
      _current = _actualCount * 500;

      // Jump to the new position immediately (no animation needed)
      if (_controller.hasClients) {
        _controller.jumpTo(_current.toDouble());
      }

      // Restart auto-play if it was enabled
      if (_isAutoPlaying) {
        _scheduleNextSlide();
      }
    }
  }

  // Helper method to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _scrollEndTimer?.cancel();
    _controller.removeListener(_onCarouselScroll);
    super.dispose();
  }

  void _onCarouselScroll() {
    // Ignore scroll events during programmatic animations
    if (_isProgrammaticScroll || !_controller.hasClients) return;

    // Cancel existing timer
    _scrollEndTimer?.cancel();

    // Wait for scroll to settle before updating position
    _scrollEndTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted || !_controller.hasClients || _isProgrammaticScroll) return;

      final position = _controller.position;

      // Check if the scroll has actually settled
      if (!position.isScrollingNotifier.value) {
        final offset = _controller.offset;

        // Calculate based on the weighted layout (5:1 ratio)
        // The main item takes up 5/6 of the viewport
        final viewportWidth = position.viewportDimension;
        final itemWidth = viewportWidth * (5.0 / 6.0);

        if (itemWidth > 0) {
          final newIndex = (offset / itemWidth).round();

          if (newIndex != _current) {
            print('User scrolled from $_current to $newIndex');
            _current = newIndex;

            // Reset auto-play timer when user manually scrolls
            if (_isAutoPlaying) {
              _scheduleNextSlide();
            }
          }
        }
      }
    });
  }

  void _scheduleNextSlide() {
    _autoPlayTimer?.cancel();
    if (!_isAutoPlaying || !mounted) return;

    _autoPlayTimer = Timer(widget.autoPlayInterval, () {
      if (mounted && _isAutoPlaying) {
        _goToNext(isAuto: true);
      }
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
      if (_isAutoPlaying) {
        _scheduleNextSlide();
      } else {
        _autoPlayTimer?.cancel();
      }
    });
  }

  Future<void> _goToNext({bool isAuto = false}) async {
    if (_isAnimating || !mounted) return;

    setState(() {
      _isAnimating = true;
      _isProgrammaticScroll = true;
    });

    if (!isAuto) {
      _isAutoPlaying = false;
      _autoPlayTimer?.cancel();
    }

    _current = _current + 1;
    print('Auto/Manual next to: $_current');

    await _controller.animateToItem(
      _current,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );

    // Reset to middle when approaching the end
    if (_current >= _totalItems - _actualCount * 10) {
      _current = _actualCount * 500 + (_current % _actualCount);
      _controller.jumpTo(_current.toDouble());
    }

    if (mounted) {
      // Add a small delay before allowing scroll detection
      await Future.delayed(const Duration(milliseconds: 150));

      setState(() {
        _isAnimating = false;
        _isProgrammaticScroll = false;
      });
      if (isAuto) _scheduleNextSlide();
    }
  }

  Future<void> _goToPrev() async {
    if (_isAnimating || !mounted) return;

    setState(() {
      _isAnimating = true;
      _isProgrammaticScroll = true;
    });

    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();

    _current = _current - 1;
    print('Manual prev to: $_current');

    await _controller.animateToItem(
      _current,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );

    // Reset to middle when approaching the start
    if (_current <= _actualCount * 10) {
      _current = _actualCount * 500 + (_current % _actualCount);
      _controller.jumpTo(_current.toDouble());
    }

    if (mounted) {
      // Add a small delay before allowing scroll detection
      await Future.delayed(const Duration(milliseconds: 150));

      setState(() {
        _isAnimating = false;
        _isProgrammaticScroll = false;
      });
    }
  }

  void _handleImageTap(int virtualIndex) {
    if (widget.onImageTap != null && widget.bannerImages.isNotEmpty) {
      final actualIndex = virtualIndex % widget.bannerImages.length;
      widget.onImageTap!(actualIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: CarouselView.weighted(
            itemSnapping: true,
            controller: _controller,
            flexWeights: const <int>[5, 1],
            children: List<Widget>.generate(_totalItems, (int index) {
              final imageIndex = index % _actualCount;
              final imageUrl = widget.bannerImages[imageIndex];

              return GestureDetector(
                onTap: () => _handleImageTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheHeight: 600, // Optimize memory usage
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (widget.showControls || widget.showPlayPauseButton)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.showControls) ...[
                  ElevatedButton.icon(
                    onPressed: _isAnimating ? null : _goToPrev,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Prev'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (widget.showPlayPauseButton)
                  IconButton(
                    onPressed: _toggleAutoPlay,
                    icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow),
                    tooltip: _isAutoPlaying ? 'Pause' : 'Play',
                  ),
                if (widget.showControls) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isAnimating ? null : () => _goToNext(),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
