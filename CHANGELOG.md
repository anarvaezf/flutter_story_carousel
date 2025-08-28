## 0.1.1
- Fix: pubspec `screenshots` duplicates (light/dark).
- Docs: add dartdoc to public API.
- Chore: format code (`dart format .`) and enable `public_member_api_docs`.

## 0.1.0

- Initial release of `story_carousel`.
- Features:
  - Display a list of widgets as “stories”.
  - Auto-play with configurable durations.
  - Tap left/right to navigate, long-press to pause.
  - Optional controller for imperative control (next, prev, goTo, pause, resume).
  - Progress bar per story.
  - Close button (`onClose`) and `onIndexChanged` callback.
- Includes a runnable example app in `/example`.
