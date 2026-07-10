import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

/// A ScrollBehavior that disables overscroll indicators and enforces
/// clamping physics to avoid stretchy/bouncy overscroll effects.
class NoOverscrollBehavior extends ScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // Return child directly to remove glow/stretch indicators.
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
