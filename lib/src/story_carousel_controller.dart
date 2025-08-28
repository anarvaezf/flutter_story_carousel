import 'package:flutter/foundation.dart';

/// Controller to drive a [StoryCarousel] imperatively.
///
/// Exposes methods to move to next/previous items, jump to an index,
/// pause/resume auto-play, and listen to state changes via [index] and [isPaused].
class StoryCarouselController {
  /// Creates a new [StoryCarouselController].
  ///
  /// Typically passed to a [StoryCarousel] via its [controller] parameter.
  StoryCarouselController();

  /// Current index of the visible story.
  ///
  /// Listen to this to react to page changes driven by gestures or code.
  final ValueNotifier<int> index = ValueNotifier<int>(0);

  /// Whether the carousel is currently paused.
  ///
  /// Listen to this to reflect play/pause state in your UI.
  final ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);

  VoidCallback? _next;
  VoidCallback? _prev;
  void Function(int)? _goTo;
  void Function(bool)? _setPaused;

  /// Advances to the next story if possible.
  void next() => _next?.call();

  /// Goes back to the previous story if possible.
  void prev() => _prev?.call();

  /// Jumps to the given [i] (zero-based index).
  void goTo(int i) => _goTo?.call(i);

  /// Pauses auto-play (if enabled).
  void pause() => _setPaused?.call(true);

  /// Resumes auto-play (if paused).
  void resume() => _setPaused?.call(false);

  /// Internal: binds the carousel's internal callbacks to this controller.
  ///
  /// Called by [StoryCarousel] to wire up functionality.
  void bindControls({
    required VoidCallback next,
    required VoidCallback prev,
    required void Function(int) goTo,
    required void Function(bool) setPaused,
    required int initialIndex,
  }) {
    _next = next;
    _prev = prev;
    _goTo = goTo;
    _setPaused = setPaused;
    index.value = initialIndex;
    isPaused.value = false;
  }

  /// Disposes the controller and its [ValueNotifier]s.
  ///
  /// Call this when you own the controller and it is no longer needed.
  void dispose() {
    index.dispose();
    isPaused.dispose();
  }
}
