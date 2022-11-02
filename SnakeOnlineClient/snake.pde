class Snake {
  float x;
  float y;
  int[] DIM;
  
  ArrayList<PVector> body = new ArrayList<PVector>();
  PVector direction = new PVector(0, -1);
  
  boolean hasMoved = false;
  int newTail = 3;
  PVector delayedTurn;
  
  Snake(float x, float y, int[] DIM) {
    this.x = x;
    this.y = y;
    this.body.add(new PVector(x, y));
    this.DIM = DIM;
  }
  
  void move() {    
    final PVector oldHead = this.getHead();
    final PVector newHead = new PVector((this.DIM[0] + oldHead.x + this.direction.x) % this.DIM[0], (this.DIM[1] + oldHead.y + this.direction.y) % this.DIM[1]);
    this.body.add(newHead);
    
    if (this.newTail > 0) {
      this.newTail -= 1;
    } else {
      this.body.remove(0);
    }
    
    this.hasMoved = true;
    if (this.delayedTurn != null) {
      this.setDirection(round(this.delayedTurn.x), round(this.delayedTurn.y));
      this.delayedTurn = null;
    }
  }
  
  void setDirection(int x, int y) {
    if (this.direction.x == x && this.direction.y == -y || this.direction.x == -x && this.direction.y == y) {
      return;
    }
    
    if (!this.hasMoved) {
      this.delayedTurn = new PVector(x, y);
    } else {
      this.direction.x = x;
      this.direction.y = y;
      this.hasMoved = false;
    }
  }
  
  PVector getHead() {
    final PVector head = this.body.get(this.body.size() - 1);
    return head;
  }
}
