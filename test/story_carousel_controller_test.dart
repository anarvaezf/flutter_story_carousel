import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_carousel/story_carousel.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, height: 640, child: child)),
    ),
  );
}

void main() {
  testWidgets('controller binds to carousel and exposes index updates', (
    tester,
  ) async {
    final controller = StoryCarouselController();
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Bind',
          items: const [
            Center(child: Text('P0')),
            Center(child: Text('P1')),
            Center(child: Text('P2')),
          ],
          autoPlay: false,
          controller: controller,
        ),
      ),
    );

    // Initial index from bind
    expect(controller.index.value, 0);
    expect(find.text('P0'), findsOneWidget);

    // goTo should move the page and notify index
    controller.goTo(2);
    await tester.pumpAndSettle();
    expect(controller.index.value, 2);
    expect(find.text('P2'), findsOneWidget);
  });

  testWidgets('controller next/prev delegates to internal navigation', (
    tester,
  ) async {
    final controller = StoryCarouselController();
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Nav',
          items: const [
            Center(child: Text('A')),
            Center(child: Text('B')),
            Center(child: Text('C')),
          ],
          autoPlay: false,
          controller: controller,
        ),
      ),
    );

    // next -> B
    controller.next();
    await tester.pumpAndSettle();
    expect(controller.index.value, 1);
    expect(find.text('B'), findsOneWidget);

    // next -> C
    controller.next();
    await tester.pumpAndSettle();
    expect(controller.index.value, 2);
    expect(find.text('C'), findsOneWidget);

    // prev -> B
    controller.prev();
    await tester.pumpAndSettle();
    expect(controller.index.value, 1);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('pause/resume toggles isPaused and halts autoplay', (
    tester,
  ) async {
    final controller = StoryCarouselController();
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Auto',
          items: const [
            Center(child: Text('First')),
            Center(child: Text('Second')),
          ],
          autoPlay: true,
          durationPerItem: const Duration(milliseconds: 250),
          controller: controller,
        ),
      ),
    );

    // Immediately pause: time passes but should remain on first
    controller.pause();
    expect(controller.isPaused.value, isTrue);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First'), findsOneWidget);

    // Resume: after duration it should advance
    controller.resume();
    expect(controller.isPaused.value, isFalse);

    await tester.pump(const Duration(milliseconds: 280));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
    expect(controller.index.value, 1);
  });

  testWidgets('controller.dispose() disposes notifiers (no throw)', (
    tester,
  ) async {
    final controller = StoryCarouselController();
    await tester.pumpWidget(
      _wrap(
        StoryCarousel(
          title: 'Dispose',
          items: const [Center(child: Text('Only'))],
          autoPlay: false,
          controller: controller,
        ),
      ),
    );

    // Dispose should not throw; after dispose, notifiers are closed
    // We can still read the last values but adding listeners should throw,
    // so we just call dispose to ensure no exception is thrown here.
    controller.dispose();
  });
}
