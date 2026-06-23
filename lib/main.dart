import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: RiftRushGame(),
    ),
  );
}

class RiftRushGame extends FlameGame with PanDetector, TapCallbacks {
  late RectangleComponent player;
  
  int currentLane = 1;

  late List<double> lanePositions;

  late double targetX;

  bool canSwipe = true;
  late RectangleComponent ground1;
  late RectangleComponent ground2;

  double gameSpeed = 300;
  List<RectangleComponent> obstacles = [];

double spawnTimer = 0;
double spawnInterval = 1.5;
bool gameOver = false;

late TextComponent gameOverText;
double score = 0;

late TextComponent scoreText;
  @override
  Color backgroundColor() => Colors.black;

  
  @override
Future<void> onLoad() async {
  player = RectangleComponent(
    size: Vector2(80, 80),
    paint: Paint()..color = Colors.blue,
    anchor: Anchor.center,
  );

  lanePositions = [
  size.x * 0.25,
  size.x * 0.50,
  size.x * 0.75,
];

  player.position = Vector2(
  lanePositions[currentLane],
  size.y * 0.75,
);

targetX = lanePositions[currentLane];

  ground1 = RectangleComponent(
  size: Vector2(size.x, size.y),
  position: Vector2(0, 0),
  paint: Paint()..color = Colors.grey.shade900,
);

ground2 = RectangleComponent(
  size: Vector2(size.x, size.y),
  position: Vector2(0, -size.y),
  paint: Paint()..color = Colors.grey.shade800,
);

  add(ground1);
  add(ground2);
  add(player);

  gameOverText = TextComponent(
  text: "GAME OVER",
  anchor: Anchor.center,
  position: Vector2(size.x / 2, size.y / 2),
  textRenderer: TextPaint(
    style: const TextStyle(
      fontSize: 48,
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ),
  ),
);

scoreText = TextComponent(
  text: "Score: 0",
  position: Vector2(20, 40),
  textRenderer: TextPaint(
    style: const TextStyle(
      fontSize: 32,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
);

add(scoreText);

  print("Rift Rush V2 Started");
}
@override
void onPanUpdate(DragUpdateInfo info) {
  if (!canSwipe) return;

  if (info.delta.global.x > 10) {
    moveRight();
    canSwipe = false;
  } else if (info.delta.global.x < -10) {
    moveLeft();
    canSwipe = false;
  }
}

@override
void onPanEnd(DragEndInfo info) {
  canSwipe = true;
}

void moveLeft() {
  if (currentLane > 0) {
    currentLane--;
    targetX = lanePositions[currentLane];
  }
}

void moveRight() {
  if (currentLane < 2) {
    currentLane++;
    targetX = lanePositions[currentLane];
  }
}
void restartGame() {
  gameOver = false;
  gameOverText.removeFromParent();
  score = 0;
  gameSpeed = 300;
spawnInterval = 1.5;
  spawnTimer = 0;

  for (final obstacle in obstacles) {
    obstacle.removeFromParent();
  }

  obstacles.clear();

  currentLane = 1;

  player.position.x = lanePositions[currentLane];

  targetX = lanePositions[currentLane];
}


@override
void onTapDown(TapDownEvent event) {
  if (gameOver) {
    restartGame();
  }
}

void spawnObstacle() {
  int laneIndex = DateTime.now().millisecondsSinceEpoch % 3;

  final obstacle = RectangleComponent(
    size: Vector2(80, 80),
    anchor: Anchor.center,
    paint: Paint()..color = Colors.red,
  );

  obstacle.position = Vector2(
    lanePositions[laneIndex],
    0,
  );

  add(obstacle);
  obstacles.add(obstacle);
}

@override
void update(double dt) {
  super.update(dt);
  if (gameOver) return;

  score += dt * 10;
  gameSpeed += dt * 2;

if (gameSpeed > 800) {
  gameSpeed = 800;
}

scoreText.text = "Score: ${score.toInt()}";

  player.position.x += (targetX - player.position.x) * 14 * dt;

  spawnTimer += dt;

if (spawnTimer > spawnInterval) {
  spawnObstacle();

  spawnInterval = 1.5 - (score / 200);

  if (spawnInterval < 0.6) {
    spawnInterval = 0.6;
  }

  spawnTimer = 0;
}
for (final obstacle in obstacles) {
  obstacle.position.y += gameSpeed * dt;
}

obstacles.removeWhere((obstacle) {
  if (obstacle.position.y > size.y) {
    obstacle.removeFromParent();
    return true;
  }
  return false;
});
  
  for (final obstacle in obstacles) {
  if (player.toRect().overlaps(obstacle.toRect())) {
    gameOver = true;

    add(gameOverText);

    break;
  }
}
  ground1.y += gameSpeed * dt;
  ground2.y += gameSpeed * dt;

  if (ground1.y >= size.y) {
    ground1.y = ground2.y - size.y;
  }

  if (ground2.y >= size.y) {
    ground2.y = ground1.y - size.y;
  }
}
}