//sets up and displays graphs for data and understanding of the simulation dynamics

class Graph {

  PVector location;
  int sizew;
  int sizeh;
  int originalsizew;
  int originalsizeh;

  color bg;

  PVector originalLocation;

  FloatList[] idLines = new FloatList[agents.length];

  float yaxis, xaxis;

  String title, xlabel, ylabel;

  String label;

  boolean highlightAgent = false;

  Graph(float locx, float locy, int w, int h, String labeli) {

    label = labeli;
    highlightAgent = true;
    bg = color(360);
    sizew = w;
    sizeh = h;
    originalsizew = sizew;
    originalsizeh = sizeh;

    location = new PVector(locx, locy);
    originalLocation = location;

    xaxis = (location.x - sizew/2) -5;
    yaxis = (location.y + sizeh/2)- 5;

    for (int i = 0; i < idLines.length; i++) {

      idLines[i] = new FloatList();
    }
    fill(360);
    rect(location.x, location.y, sizew, sizeh);

    strokeWeight(1);
    stroke(0);
    line(location.x - sizew/2, location.y, location.x + sizew/2, location.y);

    c = get(int(location.x) - sizew/2, int(location.y) - sizeh/2, sizew, sizeh);
  }

  boolean zoom = false;
  int buffer = 0;

  int textNormal = 200;
  int textZoom = width - 100;

  PImage c;

  void display() {

    text(label + ":", location.x - sizew/2 + 30, location.y - sizeh/2 - 10);

    fill(360);
    rect(location.x, location.y, sizew, sizeh);

    strokeWeight(1);
    stroke(0);
    line(location.x - sizew/2, location.y, location.x + sizew/2, location.y);
    strokeWeight(2);

    if (runSimulation) {
      if (moveImage == false) {
        image(c, location.x - sizew/2, location.y - sizeh/2);
      } else {
        image(c, location.x - sizew/2 - 1, location.y - sizeh/2);//kind of low quality...maybe make it like not resample and only sample changed part/???
      }
    } else {
      image(c, location.x - sizew/2, location.y - sizeh/2);
    }
    if (xvaluesDisplay.size() >0) {
      for (int j = 0; j < yvaluesDisplay.get(xvaluesDisplay.size() - 1).length; j++) {

        stroke(hues.get(xvaluesDisplay.size() - 1)[j], 100, 100);
        point((location.x - sizew/2) + xvaluesDisplay.size() - 1, (yvaluesDisplay.get(xvaluesDisplay.size() - 1)[j] * sizeh) + (location.y- sizeh/2));
      
        if (broadcastingAgent != null && labels[j] == broadcastingAgent.id) {//FIGURE OUT BCAGENT THING

          stroke(270, 100, 100);
        }
      }
    }
    stroke(0);
    strokeWeight(buffer);
    noFill();
    rect(location.x, location.y, sizew + buffer, sizeh + buffer);
 
    c = get(int(location.x) - sizew/2, int(location.y) - sizeh/2, sizew, sizeh);

    if (highlightAgent) {
      for (int i = 0; i < xvaluesDisplay.size(); i++) {

        for (int j = 0; j < yvaluesDisplay.get(i).length; j++) {

          if (highlightedAgent != null && labels[j] == highlightedAgent.id) {
            pushStyle();
            strokeWeight(5);
            stroke(0, 100, 100);
            point((location.x - sizew/2) + i, (yvaluesDisplay.get(i)[j] * sizeh) + (location.y- sizeh/2));
            popStyle();
          }
        }
      }
    }
  }


  FloatList xvalues = new FloatList();
  ArrayList <float[]> yvalues = new ArrayList<float[]>();

  FloatList xvaluesDisplay = new FloatList();
  ArrayList <float[]> yvaluesDisplay = new ArrayList<float[]>();

  ArrayList <float[]> hues = new ArrayList<float[]>();

  int[] labels = new int[agents.length];
  boolean moveImage = false;

  void update(float x, float[]y, float[] cs, int[] ls) {

    labels = ls;

    xvalues.append(x);

    yvalues.add(y);

    hues.add(cs);

    xvaluesDisplay = xvalues;
    yvaluesDisplay = yvalues;

    if (xvaluesDisplay.size() > sizew) {
      moveImage = true;
      for (int i = 0; i < (xvaluesDisplay.size() - sizew); i++) { 
        xvalues.remove(i);
        yvalues.remove(i);
      }
    }
  }
}
