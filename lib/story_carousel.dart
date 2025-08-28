/// Instagram-like stories carousel for Flutter.
///
/// Displays a sequence of "stories" (any [Widget]) with auto-advance,
/// tap navigation (left/right), long-press to pause/resume, and a
/// segmented progress bar on top. This file defines the [StoryCarousel]
/// widget used by package consumers.
///
/// Example:
/// ```dart
/// final controller = StoryCarouselController();
///
/// StoryCarousel(
///   title: 'Demo',
///   items: [Text('One'), Text('Two')],
///   controller: controller,
///   autoPlay: true,
/// );
/// ```
library;

export 'src/story_carousel.dart';
export 'src/story_carousel_controller.dart';
