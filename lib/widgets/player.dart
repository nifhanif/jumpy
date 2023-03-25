import 'dart:math';
import 'dart:ui' as ui show Gradient, lerpDouble;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jumpy/helper/enums.dart';
import 'package:jumpy/helper/game_controller.dart';
import 'package:jumpy/widgets/responsive/responsive.dart';

class Player extends PositionComponent with CollisionCallbacks, HasGameRef {
  Player(this.parallax)
      : body = Path()
          ..moveTo(10, 0)
          ..cubicTo(17, 0, 28, 20, 10, 20)
          ..cubicTo(-8, 20, 3, 0, 10, 0)
          ..close(),
        eyes = Path()
          ..addOval(const Rect.fromLTWH(12.5, 9, 4, 6))
          ..addOval(const Rect.fromLTWH(6.5, 9, 4, 6)),
        pupils = Path()
          ..addOval(const Rect.fromLTWH(14, 11, 2, 2))
          ..addOval(const Rect.fromLTWH(8, 11, 2, 2)),
        mobil = Path()
        // Menggambar bodi mobil
         ..moveTo(0, 40 * 0.8)
          ..lineTo(60 * 0.2, 40 * 0.8)
          ..lineTo(60 * 0.2, 40 * 0.6)
          ..lineTo(60 * 0.35, 40 * 0.6)
          ..lineTo(60 * 0.35, 40 * 0.45)
          ..lineTo(60 * 0.2, 40 * 0.45)
          ..lineTo(60 * 0.2, 40 * 0.25)
          ..lineTo(60 * 0.35, 40 * 0.25)
          ..lineTo(60 * 0.35, 40 * 0.1)
          ..lineTo(60 * 0.6, 40 * 0.1)
          ..lineTo(60 * 0.6, 40 * 0.25)
          ..lineTo(60 * 0.8, 40 * 0.25)
          ..lineTo(60 * 0.8, 40 * 0.1)
          ..lineTo(60, 40 * 0.1)
          ..lineTo(60, 40 * 0.25)
          ..lineTo(60 * 0.8, 40 * 0.25)
          ..lineTo(60 * 0.8, 40 * 0.45)
          ..lineTo(60, 40 * 0.45)
          ..lineTo(60, 40 * 0.8)
          ..lineTo(60 * 0.7, 40 * 0.8)
          ..lineTo(60 * 0.7, 40 * 0.7)
          ..lineTo(60 * 0.55, 40 * 0.7)
          ..lineTo(60 * 0.55, 40 * 0.5)
          ..lineTo(60 * 0.7, 40 * 0.5)
          ..lineTo(60 * 0.7, 40 * 0.4)
          ..lineTo(60 * 0.55, 40 * 0.4)
          ..lineTo(60 * 0.55, 40 * 0.25)
          ..lineTo(60 * 0.7, 40 * 0.25)
          ..lineTo(60 * 0.7, 40 * 0.15)
          ..lineTo(60 * 0.6, 40 * 0.15)
          ..lineTo(60 * 0.6, 40 * 0.25)
          ..lineTo(60 * 0.45, 40 * 0.25)
          ..lineTo(60 * 0.45, 40 * 0.4)
          ..lineTo(60 * 0.6, 40 * 0.4)
          ..lineTo(60 * 0.6, 40 * 0.5)
          ..lineTo(60 * 0.45, 40 * 0.5)
          ..lineTo(60 * 0.45, 40 * 0.7)
          ..lineTo(60 * 0.6, 40 * 0.7)
          ..lineTo(60 * 0.6, 40 * 0.8)

          // Menggambar jendela depan
          ..moveTo(60 * 0.25, 40 * 0.3)
          ..lineTo(60 * 0.35, 40 * 0.3)
          ..lineTo(60 * 0.35, 40 * 0.4)
          ..lineTo(60 * 0.25, 40 * 0.4)
          ..close()
// Menggambar jendela belakang
          ..moveTo(60 * 0.65, 40 * 0.3)
          ..lineTo(60 * 0.75, 40 * 0.3)
          ..lineTo(60 * 0.75, 40 * 0.4)
          ..lineTo(60 * 0.65, 40 * 0.4)
          ..close()

// Menggambar lampu depan
          ..moveTo(60 * 0.35, 40 * 0.55)
          ..lineTo(60 * 0.38, 40 * 0.55)
          ..lineTo(60 * 0.38, 40 * 0.5)
          ..lineTo(60 * 0.35, 40 * 0.5)
          ..close()

// Menggambar lampu belakang
          ..moveTo(60 * 0.62, 40 * 0.55)
          ..lineTo(60 * 0.65, 40 * 0.55)
          ..lineTo(60 * 0.65, 40 * 0.5)
          ..lineTo(60 * 0.62, 40 * 0.5)
          ..close(),
        mobilRoda = Path()
          // Menggambar roda
          ..addOval(Rect.fromCircle(
              center: Offset(30 * 0.2, 20 * 0.8), radius: 20 * 0.2))
          ..addOval(Rect.fromCircle(
              center: Offset(30 * 0.8, 20 * 0.8), radius: 20 * 0.2)),
        velocity = Vector2.zero(),
        super(size: Vector2(20, 20), anchor: Anchor.bottomCenter);

  final Parallax parallax;
  final Path body;
  final Path mobil;
  final Path mobilRoda;
  final Path eyes;
  final Path pupils;
  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0xffffc67c);
  final Paint innerPaint = Paint()..color = const Color(0xff9c0051);
  final Paint eyesPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint pupilsPaint = Paint()..color = const Color(0xFF000000);
  final Paint mobilPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0;
  final Paint shadowPaint = Paint()
    ..shader = ui.Gradient.radial(
      Offset.zero,
      10,
      [const Color(0x88000000), const Color(0x00000000)],
    );

  final Vector2 velocity;
  final double runSpeed = 200.0;
  final double jumpSpeed = 400.0;
  final double gravity = 900.0;
  bool facingRight = true;
  // int nJumpsLeft = 2;

  //todo mobil

  //todo end mobil

  @override
  Future<void>? onLoad() {
    scale = Vector2(3, 3);
    height = -7.w;
    width = 20.w;
    // final hitboxPaint = BasicPalette.white.paint()
    //   ..style = PaintingStyle.stroke;
    add(PolygonHitbox.relative(
      [
        Vector2(0.0, -1.0),
        Vector2(-1.0, -0.1),
        Vector2(-0.2, 0.8),
        Vector2(0.2, 0.8),
        Vector2(1.0, -0.1),
      ],
      parentSize: Vector2(6.w, 6.w),
    )
        // ..paint = hitboxPaint
        // ..renderShape = true,
        );
    // add(RectangleHitbox());
    // return super.onLoad();
  }

  @override
  void update(double dt) {
    GameController gameController = GetIt.instance<GameController>();
    GameAction action = gameController.action;
    bool isJumping = gameController.isJumping;
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
    if (position.y > 0) {
      position.y = 0;
      velocity.y = 0;
      // nJumpsLeft = 2;
    }
    if (position.y < 0) {
      velocity.y += gravity * dt;
    }
    if (position.x < 0) {
      position.x = 0;
    }
    if (position.x > 1000) {
      position.x = 1000;
    }

    if (isJumping) {
      velocity.y = -jumpSpeed;

      position.y -= gravity * dt;

      gameController.isJumping = false;
    }

    // if (action.isMovingRight) {
    //   if (!facingRight) {
    //     anchor = Anchor.bottomCenter;
    //     facingRight = true;
    //     flipHorizontally();
    //   }
    //   // position.add(Vector2(0.7, 0) * runSpeed * dt);
    //   parallax.baseVelocity = Vector2(20, 0) * runSpeed * dt;
    // } else if (action.isMovingLeft) {
    //   if (facingRight) {
    //     anchor = Anchor.bottomLeft;
    //     facingRight = false;
    //     flipHorizontally();
    //   }
    //   // position.add(Vector2(-0.7, 0) * runSpeed * dt);
    //   parallax.baseVelocity = Vector2(-20, 0) * runSpeed * dt;
    // } else {
    //   parallax.baseVelocity = Vector2(0, 0) * runSpeed * dt;
    // }
    if (gameController.gameStatus.value == GameStatus.start) {
      parallax.baseVelocity = Vector2(20, 0) * runSpeed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    priority = 20;
    {
      final h = -position.y; // height above the ground
      canvas.save();
      canvas.translate(width / 7, (height + 12.w) + 1 + h * 1.05);
      canvas.scale(1 - h * 0.003, 0.3 - h * 0.001);
      canvas.drawCircle(Offset.zero, 10, shadowPaint);
      canvas.restore();
    }
    // canvas.drawPath(body, innerPaint);
    // canvas.drawPath(body, borderPaint);
    // canvas.drawPath(eyes, eyesPaint);
    // canvas.drawPath(pupils, pupilsPaint);
    canvas.drawPath(mobil, mobilPaint);
    canvas.drawPath(mobilRoda, borderPaint);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // velocity.negate();
    // flipVertically();
    // print('COLLISION');
  }
}
