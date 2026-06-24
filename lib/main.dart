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
  bool isJumping = false;

double jumpVelocity = 0;
double gravity = 1800;

double groundY = 0;
  late RectangleComponent ground1;
  late RectangleComponent ground2;

  double gameSpeed = 300;
  List<RectangleComponent> obstacles = [];
  List<CircleComponent> coins = [];

double coinSpawnTimer = 0;

double spawnTimer = 0;
double spawnInterval = 1.5;
double minObstacleGap = 250;
bool gameOver = false;

late TextComponent gameOverText;
late TextComponent highScoreText;
late TextComponent coinText;
double score = 0;
int coinsCollected = 0;
double highScore = 0;

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

  groundY = size.y * 0.75;

player.position = Vector2(
  lanePositions[currentLane],
  groundY,
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
  position: Vector2(20, 20),
  textRenderer: TextPaint(
    style: const TextStyle(
      fontSize: 24,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
);
scoreText.priority = 100;
add(scoreText);


coinText = TextComponent(
  text: "Coins: 0",
  position: Vector2(size.x - 140, 20),
  textRenderer: TextPaint(
    style: const TextStyle(
      fontSize: 20,
      color: Colors.yellow,
      fontWeight: FontWeight.bold,
    ),
  ),
);
coinText.priority = 100;
add(coinText);


highScoreText = TextComponent(
  text: "High: 0",
  position: Vector2(20, 50),
  textRenderer: TextPaint(
    style: const TextStyle(
      fontSize: 20,
      color: Colors.yellow,
      fontWeight: FontWeight.bold,
    ),
  ),
);
highScoreText.priority = 100;
add(highScoreText);

  print("Rift Rush V2 Started");
}
@override
void onPanUpdate(DragUpdateInfo info) {
  if (!canSwipe) return;

  if (info.delta.global.x > 10){
    moveRight();
    canSwipe = false;
  } 
  else if (info.delta.global.x < -10) {
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

void jump() {
  if (isJumping) return;

  isJumping = true;
  jumpVelocity = -900;
}

void restartGame() {
  gameOver = false;
  gameOverText.removeFromParent();
  score = 0;
  coinsCollected = 0;
  gameSpeed = 300;
spawnInterval = 1.5;
  spawnTimer = 0;

  for (final obstacle in obstacles) {
    obstacle.removeFromParent();
  }

  obstacles.clear();
  for (final coin in coins) {
  coin.removeFromParent();
}

coins.clear();

coinSpawnTimer = 0;

  currentLane = 1;
  isJumping = false;
jumpVelocity = 0;
player.position.y = groundY;

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
  int pattern = DateTime.now().millisecondsSinceEpoch % 3;

  List<int> lanesToBlock = [];

  if (pattern == 0) {
    lanesToBlock = [1];
  } else if (pattern == 1) {
    lanesToBlock = [0, 2];
  } else {
    lanesToBlock = [0, 1];
  }

  for (int laneIndex in lanesToBlock) {
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
}

void spawnCoin() {
  int laneIndex = DateTime.now().millisecondsSinceEpoch % 3;

  final coin = CircleComponent(
    radius: 25,
    paint: Paint()..color = Colors.yellow,
  );

  coin.anchor = Anchor.center;

coin.position = Vector2(
  lanePositions[laneIndex],
  0,
);

  add(coin);
  coins.add(coin);
}

@override
void update(double dt) {
  super.update(dt);
  if (gameOver) return;

  score += dt * 10;
  gameSpeed += dt * 2;
  minObstacleGap = 250 + (gameSpeed * 0.2);

if (gameSpeed > 800) {
  gameSpeed = 800;
}

scoreText.text = "Score: ${score.toInt()}";
coinText.text = "Coins: $coinsCollected";
if (score > highScore) {
  highScore = score;
}

highScoreText.text = "High: ${highScore.toInt()}";

  player.position.x += (targetX - player.position.x) * 14 * dt;

//   if (isJumping) {
//   jumpVelocity += gravity * dt;

//   player.position.y += jumpVelocity * dt;

//   if (player.position.y >= groundY) {
//     player.position.y = groundY;

//     isJumping = false;
//     jumpVelocity = 0;
//   }
// }

  spawnTimer += dt;
  coinSpawnTimer += dt;

if (coinSpawnTimer > 2.5) {
  spawnCoin();
  coinSpawnTimer = 0;
}
if (spawnTimer > spawnInterval &&
    (obstacles.isEmpty ||
        obstacles.last.position.y > minObstacleGap)) {
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

for (final coin in coins) {
  coin.position.y += gameSpeed * dt;
}

obstacles.removeWhere((obstacle) {
  if (obstacle.position.y > size.y) {
    obstacle.removeFromParent();
    return true;
  }
  return false;
});
coins.removeWhere((coin) {
  if (coin.position.y > size.y) {
    coin.removeFromParent();
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
coins.removeWhere((coin) {
  if (player.toRect().overlaps(coin.toRect())) {
    coinsCollected++;

    coin.removeFromParent();
    return true;
  }
  return false;
});

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