import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class OverlappingTapCallbacksExample extends FlameGame {
  static const String description = '''
    In this example we show you that events can choose to continue propagating
    to underlying components. The middle green square continue to propagate the
    events, meanwhile the others do not.
  ''';

  @override
  Future<void> onLoad() async {
    add(TapCallbacksSquare(position: Vector2(100, 100)));
    add(
      TapCallbacksSquare(
        position: Vector2(150, 150),
        continuePropagation: true,
      ),
    );
    add(TapCallbacksSquare(position: Vector2(100, 200)));
  }
}

class TapCallbacksSquare extends RectangleComponent with TapCallbacks {
  TapCallbacksSquare({Vector2? position, this.continuePropagation = false})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
          paint: continuePropagation
              ? (Paint()..color = Colors.green.withValues(alpha: 0.9))
              : PaintExtension.random(withAlpha: 0.9, base: 100),
        );

  final bool continuePropagation;

  @override
  void onTapDown(TapDownEvent event) {
    event.continuePropagation = continuePropagation;
    angle += 1.0;
  }
}
