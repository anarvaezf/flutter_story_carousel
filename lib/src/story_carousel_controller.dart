import 'package:flutter/foundation.dart';

class StoryCarouselController {
  StoryCarouselController();

  final ValueNotifier<int> index = ValueNotifier<int>(0);
  final ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);

  VoidCallback? _next;
  VoidCallback? _prev;
  void Function(int)? _goTo;
  void Function(bool)? _setPaused;

  void next() => _next?.call();
  void prev() => _prev?.call();
  void goTo(int i) => _goTo?.call(i);
  void pause() => _setPaused?.call(true);
  void resume() => _setPaused?.call(false);

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

  void dispose() {
    index.dispose();
    isPaused.dispose();
  }
}
