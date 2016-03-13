import java.util.*;

ArrayList<Node> nodes;
ArrayList<Edge> edges;

// parameters
float attractionFactor = 500;
float attractionMinDistance = 75;
float repelFactor = 25000;
float damping = 5;
//float centerFactor = 0.15;
float dt = 0.01;
//float temperature = 1000;

int x_max = 800;
int y_max = 800;

int selected = -1;

PFont my_font;

void setup() {
  
  colorMode(HSB, 360, 100, 100);
  size(800, 800);
  background(100);
  frameRate(30);
  
  nodes = new ArrayList<Node>();
  edges = new ArrayList<Edge>();
  
  my_font = loadFont("ComicSansMS-24.vlw");
  textFont(my_font);
  textAlign(RIGHT, CENTER);
  
  // read JSON file to initiate nodes and edges
  JSONObject json = loadJSONObject("miserables.json");

  JSONArray json_nodes = json.getJSONArray("nodes");
  
  int num_nodes = json_nodes.size();
  for(int i = 0; i < num_nodes; i++) {
    JSONObject node = json_nodes.getJSONObject(i);
    
    // random initial position;
    float x = 400 + (100 + random(-20, 20))*(float)Math.cos(2.0*PI*i/num_nodes);
    float y = 400 + (100 + random(-20, 20))*(float)Math.sin(2.0*PI*i/num_nodes);

    nodes.add(new Node(x, y, node.getString("name"), node.getInt("group")));
  }
  
  JSONArray json_edges = json.getJSONArray("links");
  int num_edges = json_edges.size();
  for(int i = 0; i < num_edges; i++) {
    JSONObject edge = json_edges.getJSONObject(i);
    edges.add(new Edge(nodes.get(edge.getInt("source")), nodes.get(edge.getInt("target")), edge.getFloat("value")));
  }
  
}

void initiateForces() {
  for(int i = 0; i < nodes.size(); i++) {
    nodes.get(i).force.x = 0;
    nodes.get(i).force.y = 0;
  }
}
  
void attractForces() {
  
  for(int i = 0; i < edges.size(); i++) {
    Node n1 = edges.get(i).source;
    Node n2 = edges.get(i).target;
    float distance = (float)Math.sqrt( Math.pow(n2.position.x - n1.position.x,2) + Math.pow(n2.position.y - n1.position.y,2));
    float theta = (float)Math.atan2(n2.position.y - n1.position.y, n2.position.x - n1.position.x);
    float attr_force = attractionFactor * edges.get(i).value * (float)Math.log(distance / attractionMinDistance);
    n1.force.x += attr_force * (float)Math.cos(theta);
    n1.force.y += attr_force * (float)Math.sin(theta);
    n2.force.x -= attr_force * (float)Math.cos(theta);
    n2.force.y -= attr_force * (float)Math.sin(theta);
  }
}
 
void repelForces() { 
  
  for(int i = 0; i < nodes.size(); i++) {
    Node n1 = nodes.get(i);
    for(int j = 0; j < nodes.size(); j++) {
      
      // if it is node itself, jump to the next node
      if(i == j) continue;
      
      Node n2 = nodes.get(j);
      float distance = (float)Math.sqrt( Math.pow(n2.position.x - n1.position.x,2) + Math.pow(n2.position.y - n1.position.y,2));
      float theta = (float)Math.atan2(n2.position.y - n1.position.y, n2.position.x - n1.position.x);
      float repl_force = - repelFactor / (distance * distance);
      
      // improve clustering
      if (n1.group != n2.group) repl_force *=5;
      
      n1.force.x += repl_force * (float)Math.cos(theta);
      n1.force.y += repl_force * (float)Math.sin(theta);
      n2.force.x -= repl_force * (float)Math.cos(theta);
      n2.force.y -= repl_force * (float)Math.sin(theta);
    }
  }
}

void dampForces() {
  
  for(int i = 0; i < nodes.size(); i++) {
    
    Node n = nodes.get(i);
    
    n.force.x -= damping * n.velocity.x;
    n.force.y -= damping * n.velocity.y;
    
    if(n.position.x < 10) n.force.x += 1000;
    else if(n.position.x > x_max - 10) n.force.x -= 1000;
    if(n.position.y < 10) n.force.y += 1000;
    else if(n.position.y > y_max - 10) n.force.y -= 1000;
    
  }
}

void update() {
  for(int i = 0; i < nodes.size(); i++) {
    Node n = nodes.get(i);
    n.velocity.x += n.force.x * dt;
    n.velocity.y += n.force.y * dt;
    n.position.x += n.velocity.x * dt;
    n.position.y += n.velocity.y * dt;
  }
}

void draw() {
  background(360);
  
  fill(150);
  textAlign(LEFT, CENTER);
  text("Les Miserables characters\nconnected by co-occurence", 25, 75);
  
  // reset forces
  initiateForces();
  
  // calculate attraction forces
  attractForces();
  
  // calculate repel forces
  repelForces();
  
  // calculate damping forces
  dampForces();
  
  // updating
  update();
  
  stroke(0, 0, 85);
  for(int i = 0; i < edges.size(); i++) {
    Node n1 = edges.get(i).source;
    Node n2 = edges.get(i).target;
    strokeWeight(sqrt(edges.get(i).value));
    line(n1.position.x, n1.position.y, n2.position.x, n2.position.y);
  }
  
  noStroke();
  for(int i = 0; i < nodes.size(); i++) {
    Node n = nodes.get(i);
    
    fill(0, 0, 85);
    ellipse(n.position.x, n.position.y, 20, 20);
    
    fill(36 * n.group, 100, 85);
    ellipse(n.position.x, n.position.y, 15, 15);
  }
}

void mousePressed() {
  for(int i = 0; i < nodes.size(); i++) {
    Node n = nodes.get(i);
    if( Math.pow(mouseX - n.position.x, 2) + Math.pow(mouseY - n.position.y, 2) < 400 ) {
      selected = i;
      //temperature = 500;
    }
  }
}

void mouseDragged() {
  if(selected != -1) {
    Node n = nodes.get(selected);
    n.position.x = mouseX;
    n.position.y = mouseY;
    n.velocity.x = 0;
    n.velocity.y = 0;
  }
}

void mouseReleased() {
  selected = -1;
}
