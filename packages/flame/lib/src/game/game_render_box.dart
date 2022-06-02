import 'package:flame/src/game/game.dart';
import 'package:flame/src/game/game_loop.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

class RenderGameWidget extends LeafRenderObjectWidget {
  final Game game;

  const RenderGameWidget({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return GameRenderBox(game, context);
  }

  @override
  void updateRenderObject(BuildContext context, GameRenderBox renderObject) {
    renderObject
      ..game = game
      ..buildContext = context;
  }
}

class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  GameRenderBox(this._game, this.buildContext);

  GameLoop? gameLoop;

  BuildContext buildContext;

  Game _game;

  Game get game => _game;

  set game(Game value) {
    // Identities are equal, no need to update.
    if (_game == value) {
      return;
    }

    if (attached) {
      detachGame();
    }

    _game = value;

    if (attached) {
      attachGame(owner!);
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    attachGame(owner);
  }

  void attachGame(PipelineOwner owner) {
    game.attach(owner, this);

    final gameLoop = this.gameLoop = GameLoop(gameLoopCallback);

    if (!game.paused) {
      gameLoop.start();
    }

    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    detachGame();
  }

  void detachGame() {
    game.detach();
    gameLoop?.dispose();
    gameLoop = null;
    _unbindLifecycleListener();
  }

  void gameLoopCallback(double dt) {
    assert(attached);
    if (!attached) {
      return;
    }
    game.update(dt);
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    game.render(context.canvas);
    context.canvas.restore();
  }

  void _bindLifecycleListener() {
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  void _unbindLifecycleListener() {
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
///
/// See more: https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.0.0
T? _ambiguate<T>(T? value) => value;
