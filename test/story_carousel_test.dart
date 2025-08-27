import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_carousel/story_carousel.dart';

/// Wraps a widget in a minimal app shell with fixed size so we can tap
/// on left/right areas reliably in tests.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, height: 640, child: child)),
    ),
  );
}

void main() {
  testWidgets('renders title and first item', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Demo',
          items: const [
            Center(child: Text('A')),
            Center(child: Text('B')),
          ],
          autoPlay: false,
        ),
      ),
    );

    expect(find.text('Demo'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
  });

  testWidgets('autoplay advances to next item after duration', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Auto',
          items: const [
            Center(child: Text('One')),
            Center(child: Text('Two')),
          ],
          autoPlay: true,
          durationPerItem: const Duration(milliseconds: 250),
        ),
      ),
    );

    // Initially on first item
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsNothing);

    // Advance time beyond duration; allow a little buffer for timer tick
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Two'), findsOneWidget);
  });

  testWidgets('controller next/prev/goTo works', (tester) async {
    final controller = StoryCarouselController();

    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Control',
          items: const [
            Center(child: Text('X')),
            Center(child: Text('Y')),
            Center(child: Text('Z')),
          ],
          autoPlay: false,
          controller: controller,
        ),
      ),
    );

    // goTo second
    controller.goTo(1);
    await tester.pumpAndSettle();
    expect(find.text('Y'), findsOneWidget);

    // next -> Z
    controller.next();
    await tester.pumpAndSettle();
    expect(find.text('Z'), findsOneWidget);

    // prev -> Y
    controller.prev();
    await tester.pumpAndSettle();
    expect(find.text('Y'), findsOneWidget);
  });

  testWidgets('pause/resume via controller affects autoplay', (tester) async {
    final controller = StoryCarouselController();

    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Pause',
          items: const [
            Center(child: Text('First')),
            Center(child: Text('Second')),
          ],
          autoPlay: true,
          durationPerItem: const Duration(milliseconds: 300),
          controller: controller,
        ),
      ),
    );

    // Pause immediately; time passes but item should NOT change
    controller.pause();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('First'), findsOneWidget);

    // Resume; after enough time it should advance
    controller.resume();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('loop restarts at index 0 after last when calling next()', (
    tester,
  ) async {
    final controller = StoryCarouselController();

    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Loop',
          items: const [
            Center(child: Text('I0')),
            Center(child: Text('I1')),
          ],
          autoPlay: false,
          loop: true,
          controller: controller,
        ),
      ),
    );

    controller.goTo(1); // last
    await tester.pumpAndSettle();
    expect(find.text('I1'), findsOneWidget);

    controller.next(); // should wrap to 0
    await tester.pumpAndSettle();
    expect(find.text('I0'), findsOneWidget);
  });

  testWidgets('per-item durations are respected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Durations',
          items: const [
            Center(child: Text('Short')),
            Center(child: Text('Long')),
          ],
          autoPlay: true,
          durations: const [
            Duration(milliseconds: 120), // first
            Duration(milliseconds: 500), // second
          ],
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 380));
    await tester.pumpAndSettle();

    expect(find.text('Long'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Long'), findsOneWidget);
  });

  testWidgets('onIndexChanged is called with correct indices', (tester) async {
    final changes = <int>[];

    final controller = StoryCarouselController();
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Callback',
          items: const [
            Center(child: Text('C0')),
            Center(child: Text('C1')),
          ],
          autoPlay: false,
          controller: controller,
          onIndexChanged: changes.add,
        ),
      ),
    );

    controller.goTo(1);
    await tester.pumpAndSettle();
    controller.prev();
    await tester.pumpAndSettle();

    expect(changes, [1, 0]);
  });

  testWidgets('tap right/left advances and goes back', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Gestures',
          items: const [
            Center(child: Text('Left')),
            Center(child: Text('Right')),
          ],
          autoPlay: false,
        ),
      ),
    );

    // Calculate a point on the right third to trigger "next"
    final box = tester.renderObject<RenderBox>(find.byType(StoryCarousel));
    final size = box.size;
    final offsetInGlobal = box.localToGlobal(Offset.zero);
    final rightTap =
        offsetInGlobal + Offset(size.width * 0.9, size.height * 0.5);
    final leftTap =
        offsetInGlobal + Offset(size.width * 0.1, size.height * 0.5);

    // Tap right -> go next
    await tester.tapAt(rightTap);
    await tester.pumpAndSettle();
    expect(find.text('Right'), findsOneWidget);

    // Tap left -> go previous
    await tester.tapAt(leftTap);
    await tester.pumpAndSettle();
    expect(find.text('Left'), findsOneWidget);
  });

  testWidgets(
    'shows close button when onClose is provided and triggers callback',
    (tester) async {
      var closed = false;

      await tester.pumpWidget(
        _wrap(
          StoryCarousel(
            title: 'With close',
            items: const [Center(child: Text('Item'))],
            autoPlay: false,
            onClose: () {
              closed = true;
            },
          ),
        ),
      );

      final closeFinder = find.byIcon(Icons.close);
      expect(closeFinder, findsOneWidget);

      await tester.tap(closeFinder);
      await tester.pumpAndSettle();
      expect(closed, isTrue);
    },
  );

  testWidgets('does not show close button when onClose is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const StoryCarousel(
          title: 'No close',
          items: [Center(child: Text('Only'))],
          autoPlay: false,
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('pageAnimationDuration=0 uses jumpToPage()', (tester) async {
    final controller = StoryCarouselController();
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Jump',
          items: const [
            Center(child: Text('J0')),
            Center(child: Text('J1')),
          ],
          autoPlay: false,
          controller: controller,
          pageAnimationDuration: Duration.zero,
        ),
      ),
    );

    controller.next();
    await tester.pumpAndSettle();
    expect(find.text('J1'), findsOneWidget);
  });
}
