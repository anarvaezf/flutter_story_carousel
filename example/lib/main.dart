import 'package:flutter/material.dart';
import 'package:story_carousel/story_carousel.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'story_carousel demo',
      theme: ThemeData.light(useMaterial3: true),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final controller = StoryCarouselController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Image.asset('assets/image1.jpeg', fit: BoxFit.cover),
      const Center(
        child: Text(
          'Free text\n(tap right = next, left = previous,\n long-press = pause)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      Image.asset('assets/image2.jpeg', fit: BoxFit.cover),
      Image.asset('assets/image3.jpeg', fit: BoxFit.cover),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('StoryCarousel demo')),
      body: SafeArea(
        child: StoryCarousel(
          title: 'Demo Stories',
          items: items,
          controller: controller,
          autoPlay: true,
          loop: true,
          durationPerItem: const Duration(seconds: 4),
          onClose: () => Navigator.of(context).maybePop(),
          onIndexChanged: (i) => debugPrint('Index: $i'),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton.tonal(
              onPressed: controller.prev,
              child: const Text('Prev'),
            ),
            FilledButton(
              onPressed: controller.pause,
              child: const Text('Pause'),
            ),
            FilledButton(
              onPressed: controller.resume,
              child: const Text('Resume'),
            ),
            FilledButton.tonal(
              onPressed: controller.next,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
