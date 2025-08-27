import 'dart:async';
import 'package:flutter/material.dart';
import 'package:story_carousel/src/story_carousel_controller.dart';

class StoryCarousel extends StatefulWidget {
  const StoryCarousel({
    super.key,
    required this.title,
    required this.items,
    this.controller,
    this.onIndexChanged,
    this.onClose,
    this.autoPlay = true,
    this.loop = false,
    this.durationPerItem = const Duration(seconds: 5),
    this.durations,
    this.progressBarHeight = 3.0,
    this.pageAnimationDuration = const Duration(milliseconds: 220),
  });

  final String title;
  final List<Widget> items;
  final StoryCarouselController? controller;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onClose;

  final bool autoPlay;
  final bool loop;
  final Duration durationPerItem;
  final List<Duration>? durations;
  final double progressBarHeight;
  final Duration pageAnimationDuration;

  @override
  State<StoryCarousel> createState() => _StoryCarouselState();
}

class _StoryCarouselState extends State<StoryCarousel> {
  late final PageController _pageController;
  late final StoryCarouselController _controller;

  int _index = 0;
  double _progress = 0; // 0..1
  Timer? _tick;

  Duration get _currentDuration {
    if (widget.durations != null &&
        widget.durations!.length == widget.items.length) {
      return widget.durations![_index];
    }
    return widget.durationPerItem;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = widget.controller ?? StoryCarouselController();
    _controller.bindControls(
      next: _next,
      prev: _prev,
      goTo: _goTo,
      setPaused: _setPaused,
      initialIndex: _index,
    );
    _startOrResetTimer();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pageController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _setPaused(bool value) {
    _controller.isPaused.value = value;
  }

  void _startOrResetTimer() {
    _tick?.cancel();
    _progress = 0;
    if (!widget.autoPlay || widget.items.isEmpty) return;

    final totalMs = _currentDuration.inMilliseconds;
    const step = 50;
    int elapsed = 0;

    _tick = Timer.periodic(const Duration(milliseconds: step), (t) {
      if (!mounted) return t.cancel();
      if (_controller.isPaused.value) return;
      elapsed += step;
      setState(() => _progress = (elapsed / totalMs).clamp(0.0, 1.0));
      if (elapsed >= totalMs) {
        t.cancel();
        _next();
      }
    });
  }

  void _next() {
    if (_index >= widget.items.length - 1) {
      if (widget.loop && widget.items.isNotEmpty) {
        _goTo(0);
      }
      return;
    }
    _goTo(_index + 1);
  }

  void _prev() {
    if (_index == 0) return;
    _goTo(_index - 1);
  }

  void _goTo(int i) {
    setState(() {
      _index = i;
      _controller.index.value = i;
      _progress = 0;
    });
    widget.onIndexChanged?.call(i);
    if (widget.pageAnimationDuration == Duration.zero) {
      _pageController.jumpToPage(i);
    } else {
      _pageController.animateToPage(
        i,
        duration: widget.pageAnimationDuration,
        curve: Curves.easeOut,
      );
    }
    _startOrResetTimer();
  }

  Widget _buildTimedProgressBar() {
    return Row(
      children: List.generate(widget.items.length, (i) {
        final isPast = i < _index;
        final isCurrent = i == _index;
        final widthFactor = isPast
            ? 1.0
            : isCurrent
            ? _progress
            : 0.0;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: i == widget.items.length - 1 ? 0 : 4,
            ),
            height: widget.progressBarHeight,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(widget.progressBarHeight),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.progressBarHeight),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Row(
      children: [
        if (widget.onClose != null)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        Expanded(
          child: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) => widget.items[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildPageView(),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) {
                      final dx = d.localPosition.dx;
                      if (dx < w * 0.33) {
                        _prev();
                      } else {
                        _next();
                      }
                    },
                    onLongPressStart: (_) => setState(() => _setPaused(true)),
                    onLongPressEnd: (_) => setState(() => _setPaused(false)),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimedProgressBar(),
                  const SizedBox(height: 8),
                  _buildHeaderBar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
