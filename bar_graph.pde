//This class displays a bar graph of how many agents have each attitude. Used for data purposes.
//Not used in the interface!

class barGraph {

  float xloc, yloc;
  float w, h;
  float factor;

  barGraph(float xloci, float yloci) {

    xloc = xloci;
    yloc = yloci;

    w = 400;
    h = 200;
    
    factor = h/100;
    
    for (int i = 0; i < agentsToDisplay.length; i++) {
      attitudePop[int(agentsToDisplay[i].attitudesAgent[identityMode] * 100)] ++;
    }
  }

  void display() {

    fill(360);
    rect(xloc, yloc, w, h);
    
    pushStyle();
    stroke(0,100,100);
    strokeWeight(4);
    for(int i = 0; i < attitudePop.length; i++){
      for(int j = 0; j < attitudePop[i]; j++){
        //point((xloc - w/2)  + i * 4, (yloc + h/2 - 4) - j * 2);
        point((xloc - w/2) + j * 4, (yloc + h/2) - i * 2);
      } 
    }
    popStyle();
  }

  int[] attitudePop = new int[100];

  void update(int agentid, float prevAttitude, float currentAttitude) {
    
        attitudePop[int(currentAttitude * 100)] ++;
        attitudePop[int(prevAttitude * 100)] --;

  }
}
