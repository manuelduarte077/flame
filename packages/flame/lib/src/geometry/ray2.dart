import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

/// A Ray is a ray in the 2d plane.
class Ray2 {
  Ray2(this.origin, Vector2 direction) {
    this.direction = direction;
  }

  Vector2 origin;
  late Vector2 _direction;
  Vector2 get direction => _direction;
  set direction(Vector2 direction) {
    _direction = direction;
    _directionInvX = 1 / direction.x;
    _directionInvY = 1 / direction.y;
  }

  // These are the inverse of the direction (the normal), they are used to avoid
  // a division in [intersectsWithAabb2], since the a ray will usually be tried
  // against many bounding boxes it's good to pre-calculate it, which is done
  // in the direction setter.
  late double _directionInvX;
  late double _directionInvY;

  // Uses the branchless Ray/Bounding box intersection method by Tavian.
  // https://tavianator.com/2011/ray_box.html
  bool intersectsWithAabb2(Aabb2 box) {
    final tx1 = (box.min.x - origin.x) * _directionInvX;
    final tx2 = (box.max.x - origin.x) * _directionInvX;

    var tMin = min(tx1, tx2);
    var tMax = max(tx1, tx2);

    final ty1 = (box.min.y - origin.y) * _directionInvY;
    final ty2 = (box.max.y - origin.y) * _directionInvY;

    tMin = max(tMin, min(ty1, ty2));
    tMax = min(tMax, max(ty1, ty2));

    return tMax >= tMin;
  }
}
