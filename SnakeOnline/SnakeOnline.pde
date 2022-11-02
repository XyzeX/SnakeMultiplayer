import processing.net.*;
Server server;
Client player2 = null;

Game game;

ArrayList<Fruit> fruits;
int state = 0;

final int[] DIM = {25, 25};
final int fruitAmount = 5;

Snake snake1;
Snake snake2;

void setup() {
  fullScreen();
  server = new Server(this, 8080);

  game = new Game(width / 2 - height / 2, 0, height, height, DIM);
  generateLevel();

  background(69);
  textAlign(CENTER);
  textSize(64);
  text("Waiting for another player", width / 2, height / 2);
}

void draw() {
  if (state == 2) {
    // Game over
    
    background(0);
    game.show();
    game.draw(snake1.body, #009900, #00FF00);
    game.draw(snake2.body, #000099, #0000FF);
    for (Fruit fruit : fruits) {
      game.draw(fruit.pos, #FF0000);
    }

    text("Game Over", width / 2, height / 2);
  } else if (state == 1) {
    // Game running
    
    if (frameCount % 10 == 0) {
      snake1.move();

      final PVector head = snake1.getHead();
      for (int i = 0; i < fruits.size(); i++) {
        if (fruits.get(i).pos.get(0).x == head.x && fruits.get(i).pos.get(0).y == head.y) {
          snake1.newTail += 1;
          fruits.remove(i);
          generateFood(1);
          break;
        }
      }

      int hits = 0;
      for (PVector body : snake1.body) {
        if (body.x == head.x && body.y == head.y) {
          hits++;
        }
      }

      for (PVector body : snake2.body) {
        if (body.x == head.x && body.y == head.y) {
          hits++;
        }
      }

      if (hits > 1) {
        // GAME OVER
        state = 2;
      }
      
      updatePlayer2(fruits, snake1.body, 0);
      
      background(0);
      game.show();
      game.draw(snake1.body, #009900, #00FF00);
      game.draw(snake2.body, #000099, #0000FF);
      for (Fruit fruit : fruits) {
        game.draw(fruit.pos, #FF0000);
      }
      
      
    }

    if (server.available() != null) {
      final byte[] bytes = player2.readBytes();
      
      ArrayList<PVector> newBody = new ArrayList<PVector>();
      for (int i = 0; i < bytes.length; i += 2) {
        final PVector newPos = new PVector(int(bytes[i]), int(bytes[i + 1]));
        newBody.add(newPos);
      }
      snake2.body = newBody;
          
      final PVector head = snake2.getHead();
      for (int i = 0; i < fruits.size(); i++) {
        if (fruits.get(i).pos.get(0).x == head.x && fruits.get(i).pos.get(0).y == head.y) {
          fruits.remove(i);
          snake2.newTail++;
          generateFood(1);
          break;
        }
      }

      int hits = 0;
      for (PVector body : snake2.body) {
        if (body.x == head.x && body.y == head.y) {
          hits++;
        }
      }

      for (PVector body : snake1.body) {
        if (body.x == head.x && body.y == head.y) {
          hits++;
        }
      }
      
      if (hits > 1) {
        // GAME OVER
        state = 2;
        updatePlayer2(fruits, snake1.body, 1);
        
      }
    }
  
  } else {
    // Waiting for player

    player2 = server.available();
    if (player2 != null) {
      state = 1;
    }
  }
}

void keyPressed() {
  if (key == 'w' || key == 'W' || keyCode == UP) {
    snake1.setDirection(0, -1);
  } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
    snake1.setDirection(-1, 0);
  } else if (key == 's' || key == 'S' || keyCode == DOWN) {
    snake1.setDirection(0, 1);
  } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    snake1.setDirection(1, 0);
  } else if (key == ' ') {
    generateLevel();
    state = 1;
    updatePlayer2(fruits, snake1.body, 1);
  }
}

void generateFood(int amount) {
  for (int i = 0; i < amount; i++) {

    while (true) {
      boolean badPos = false;
      float x = round(random(0, DIM[0] - 1));
      float y = round(random(0, DIM[1] - 1));

      for (Fruit fruit : fruits) {
        if (fruit.pos.get(0).x == x && fruit.pos.get(0).y == y) {
          badPos = true;
          break;
        }
      }

      for (PVector pos : snake1.body) {
        if (pos.x == x && pos.y == y) {
          badPos = true;
          break;
        }
      }

      for (PVector pos : snake2.body) {
        if (pos.x == x && pos.y == y) {
          badPos = true;
          break;
        }
      }

      if (!badPos) {
        fruits.add(new Fruit(x, y));
        break;
      }
    }
  }
}

void updatePlayer2(ArrayList<Fruit> fruits, ArrayList<PVector> body, int reset) {
  final int reserved = 3; // First reserved byte:  STATE       = {0, 1, 2}
                          // Second reserved byte: Tail length = {-, +}
                          // Third reserved byte:  Game reset  = {0, 1}
  final int len = body.size() * 2 + fruits.size() * 2 + reserved;
  byte[] bytes = new byte[len];
  
  bytes[0] = byte(state);
  bytes[1] = byte(snake2.newTail);
  bytes[2] = byte(reset);
  snake2.newTail = 0;
  
  for (int i = 0; i < fruitAmount; i++) {
    final PVector pos = fruits.get(i).pos.get(0);
    bytes[reserved + 2 * i] = byte(pos.x);
    bytes[reserved + 2 * i + 1] = byte(pos.y);
  }
  
  for (int i = 0; i < body.size(); i++) {
    final PVector pos = body.get(i);
    bytes[reserved + 2 * i + fruitAmount * 2] = byte(pos.x);
    bytes[reserved + 2 * i + 1 + fruitAmount * 2] = byte(pos.y);
  }
  player2.write(bytes);
}

void generateLevel() {
  fruits = new ArrayList<Fruit>();
  snake1 = new Snake(5, 12, DIM);
  snake2 = new Snake(19, 12, DIM);
  snake2.newTail = 0;
  
  generateFood(fruitAmount);
}
