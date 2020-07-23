//tracks the user input of the identity range and the identity comparison

class parameter {

  float xloc, yloc;
  float w, h;
  float totalWidth, totalHeight;

  boolean isActivated = false;
  boolean isAssigned = false;

  boolean flash = false;

  color ogFill = color(360);
  color fill;

  float VALUE;

  String toDisplay = "";

  String title;


  StringList content = new StringList();
  String c = "";
  char currentKey, prvKey;
  int currentKeyCount, prvKeyCount; 

  StringList trackContent = new StringList();
  int deleteCount = 0;
  parameter(float xloci, float yloci, String titlei) {

    title = titlei;

    w = 40;
    h = 20;

    xloc = xloci;
    yloc = yloci;

    fill = ogFill;

    totalWidth = w;
    totalHeight = h + (textAscent() + textDescent());

    c = "";
    cprev = "";
    content.clear();

    if (title == "Identity Compare") {
      VALUE = pvalueIC;
    }

    if (title == "Identity Range") {
      VALUE = pvalueIR;
    }
    c = str(int(VALUE));
    isAssigned = true;
  }

  void display() {

    noStroke();
    fill(fill);

    rect(xloc + w/2, yloc + h/2, w, h);

    //text cursor
    if (isActivated) { 
      fill = color(255, 100, 100);
      stroke(0);
      line(xloc + buffer + textWidth(c), yloc + buffer, xloc + buffer + textWidth(c), yloc +h - (buffer));
    } else {
      fill = ogFill;
    }
    if (setup) {
      storeContent();
    }

    if (isAssigned) {
      fill = color(120, 100, 100);
    }

    pushStyle();
    textAlign(LEFT);
    fill(360);
    text(title, xloc, yloc - textAscent());
    fill(0);
    text(c, xloc + buffer, yloc + textAscent());
    fill(360);
    text(toDisplay, xloc + w + 10, yloc + h);
    popStyle();
    checkHighlight();

    if (ingroup.isSwitched && ingroup.isTrue) {
      fill = ogFill;
    }
  }

  void checkHighlight() {
    if (mouseX > xloc && mouseX < xloc + w && mouseY > yloc && mouseY < yloc + h) {
      isActivated = true;
    } else {
      isActivated = false;
    }
  }

  String cprev;

  //stores what the user inputs as the parameters for the data
  void storeContent() {
    if (useIngroup == false && readytorun == false) {
      c = "1";
      isAssigned = true;
      returnValue(c);
    }
    if (useIngroup == true) {

      currentKey = key;
      currentKeyCount = keyCount;

      cprev = c;
      if (currentKeyCount != prvKeyCount && key != 0 && isActivated) {
        if (key == ENTER) {
          returnValue(c);
          c = "";
          cprev = "";
          keyCount = 0;
        } else if (keyCode == 8) {
          println("DELETE"); 
          setup = true;

          String tempc = "";
          for (int i = 0; i < c.length() - 1; i++) {
            println("CHAR AT", i, c.charAt(i));
            tempc += c.charAt(i);
            key = 0;
          }
          c = tempc;
          returnValue(c);
        } else {
          if (c.length() < 2) {
            c+= key;
            trackContent.append(c);

            returnValue(c);
            key = 0;
          }
        }
      } 

      prvKey = key;
      prvKeyCount = keyCount;
    }
  }

  void returnValue(String toReturn) {

    readytorun = false;
    VALUE = float(toReturn);

    if (Float.isNaN(VALUE)) {
      fill = color(0, 100, 100);
      toDisplay = "MUST BE AN INTEGER";
      isAssigned = false;
    } else {
      toDisplay = str(VALUE);
      isAssigned = true;
    }
    updateParameters();
  }

  void reset() {
    isAssigned = false;
    isActivated = false;
    c = "";
    println(c);
  }
}

//sets the parameters as the ones the user inputs
void updateParameters() {

  if (useInterface) {
    IDR = int(ir.VALUE);
    identityCompare = int(ic.VALUE);

    //updates Similarity Number based on Identity Compare
    if (ingroup.slider.button.isActive) {
      ingroup.slider.button.move();
    }
    ingroup.slider.higher = identityCompare;

    int allAssigned = 0;
    for (int i = 0; i < parameters.size(); i++) {
      if (parameters.get(i).isAssigned == true) {//SOMETHING IS WRONG HERE   
        allAssigned ++;
      }
      if (allAssigned == parameters.size()) {
        parametersSet = true;
      } else {
        parametersSet = false;
      }
    }

    if (parametersSet) {
      setupbutton.lightup = true;
    } else if (parametersSet == false) {
      setupbutton.lightup = false;
    }
  }
}


float buffer = 2;
int keyCount = 0;

//makes sure the new parameters are kept track of
void keyReleased() {
  keyCount ++;
}
