import processing.net.*;
Client client;

Game game;

ArrayList<Fruit> fruits = new ArrayList<Fruit>();
int state = 1;

final int[] DIM = {25, 25};
final int fruitAmount = 2;

Snake snake1 = new Snake(5, 12, DIM);
Snake snake2 = new Snake(19, 12, DIM);

void setup() {
  fullScreen();
  client = new Client(this, "10.130.146.18", 8080);
  
  for (int i = 0; i < fruitAmount; i++) {
    fruits.add(new Fruit(0, -2));
  }
  
  game = new Game(width / 2 - height / 2, 0, height, height, DIM);
  
  textAlign(CENTER);
  textSize(64);
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
      snake2.move();
      sendBody(snake2.body);
      
      final PVector head = snake2.getHead();
      for (int i = 0; i < fruits.size(); i++) {
        if (fruits.get(i).pos.get(0).x == head.x && fruits.get(i).pos.get(0).y == head.y) {
          fruits.get(i).pos.get(0).y = -2;
          break;
        }
      }
      
      background(0);
      game.show();
      game.draw(snake1.body, #009900, #00FF00);
      game.draw(snake2.body, #000099, #0000FF);
      for (Fruit fruit : fruits) {
        game.draw(fruit.pos, #FF0000);
      }
    }
    
    
    
    
    
    
    
  }
  
  
  
  if (client.available() > 0) {
    final byte[] bytes = client.readBytes();
    final int reserved = 3; // First reserved byte:  STATE       = {0, 1, 2}
                            // Second reserved byte: Tail length = {-, +}
                            // Third reserved byte:  Game reset  = {0, 1}
    state = int(bytes[0]);
    snake2.newTail += int(bytes[1]);
    if (int(bytes[2]) == 1) {
      snake1 = new Snake(5, 12, DIM);
      snake2 = new Snake(19, 12, DIM);
    }
    
    ArrayList<PVector> newBody = new ArrayList<PVector>();
    for (int i = 0; i < fruitAmount; i++) {
      fruits.get(i).pos.get(0).x = int(bytes[reserved + 2 * i]);
      fruits.get(i).pos.get(0).y = int(bytes[reserved + 2 * i + 1]);
    }
    for (int i = 0; i < (bytes.length - 2 * fruitAmount - reserved) / 2; i++) {
      final PVector newPos = new PVector(int(bytes[reserved + 2 * i + 2 * fruitAmount]), int(bytes[reserved + 2 * i + 1 + 2 * fruitAmount]));
      newBody.add(newPos);
    }
    snake1.body = newBody;
  }
}

void sendBody(ArrayList<PVector> arr) {
  final int len = arr.size() * 2;
  byte[] bytes = new byte[len];
  for (int i = 0; i < arr.size(); i++) {
    bytes[2 * i] = byte(arr.get(i).x);
    bytes[2 * i + 1] = byte(arr.get(i).y);
  }
  client.write(bytes);
}

void keyPressed() {
  if (key == 'w' || key == 'W') {
    snake2.setDirection(0, -1);
  } else if (key == 'a' || key == 'A') {
    snake2.setDirection(-1, 0);
  } else if (key == 's' || key == 'S') {
    snake2.setDirection(0, 1);
  } else if (key == 'd' || key == 'D') {
    snake2.setDirection(1, 0);
  }
}
