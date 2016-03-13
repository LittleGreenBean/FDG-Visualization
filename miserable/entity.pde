class Node {
  String name;
  int group;
  PVector position;
  PVector velocity;
  PVector force;
  
  Node(float x, float y, String name, int group) {
    this.name = name;
    this.group = group;
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    force = new PVector(0, 0);
  }
}

class Edge {
  Node source;
  Node target;
  float value;
  
  Edge(Node source, Node target, float value) {
    this.source = source;
    this.target = target;
    this.value = value;
  }
}
