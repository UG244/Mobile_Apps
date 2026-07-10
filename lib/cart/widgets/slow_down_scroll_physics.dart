import 'package:flutter/widgets.dart';

/// Custom physics to slow down user drag and fling velocities.
class SlowDownScrollPhysics extends ClampingScrollPhysics {
  final double velocityFactor; // multiplies fling velocity (0..1)
  final double dragFactor; // multiplies user drag offset (0..1)

  const SlowDownScrollPhysics({
    this.velocityFactor = 0.6,
    this.dragFactor = 0.7,
    super.parent,
  });

  @override
  SlowDownScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowDownScrollPhysics(
      velocityFactor: velocityFactor,
      dragFactor: dragFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Reduce how much content moves for a given user drag, making drag feel slower
    return offset * dragFactor;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Reduce the initial fling velocity so inertia scroll is slower
    final reduced = velocity * velocityFactor;
    return super.createBallisticSimulation(position, reduced);
  }

  // No need to override dragDevices here; leave default behavior.
}
