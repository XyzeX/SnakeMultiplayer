class Game {
  float x;
  float y;
  float w;
  float h;
  int[] DIM;
  
  Game(float x, float y, float w, float h, int[] d) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.DIM = d;
  }
  
  void show() {
    stroke(255);
    strokeWeight(8);
    fill(69);
    rect(this.x, this.y, this.w, this.h);
  }
  
  void draw(ArrayList<PVector> points, color... c) {
    
    final color c1 = c.length > 0 ? c[0] : 0;
    final color c2 = c.length > 1 ? c[1] : c1;
    
    
    strokeWeight(0);
    fill(c1);
    
    for (int i = 0; i < points.size(); i++) {
      if (i == points.size() - 1) {
        fill(c2);
      }
      rect(this.x + points.get(i).x * this.w / this.DIM[0], this.y + points.get(i).y * this.h / this.DIM[1], this.w / this.DIM[0], this.h / this.DIM[1]);
    }
  }
}
