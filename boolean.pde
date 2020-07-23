//This displays the booleans for the interface.
//The user can choose between using ingroups, certainty or both, which then triggers which model is used.

class booleanParameter {

  float xloc, yloc;
  float boxSize = 30;

  float totalHeight;

  color fill = color(360);
  color ogfill = fill;

  boolean isHighlighted = false;

  String title;
  String info;
  float twi;
  boolean isTrue;
  boolean isSwitched = false;

  slider slider;

  booleanParameter(float xloci, float yloci, String titlei) {

    xloc = xloci;
    yloc = yloci;

    title = titlei;

    if (title == "Certainty") {
      isTrue = useCertainty;
      info = "";
    }
    if (title == "Ingroup") {
      isTrue = useIngroup;
      info = "Average Ingroup Size: " + str(avgPIsize);
    }

    twi = textWidth(info);
    slider = new slider(xloc, yloc + boxSize, this);

    totalHeight = boxSize + (textAscent() + textDescent()+ slider.h) + textAscent() + textDescent();
  }

  //displays booleans as squares which can be checked off
  void display() {

    fill(fill);
    rect(xloc, yloc, boxSize, boxSize);

    fill(ogfill);
    text(title, xloc, yloc - boxSize/2 - (textAscent() ));
    if (title == "Ingroup") {
      text("Average Ingroup Size: " + str(avgPIsize), xloc + twi/2, yloc + slider.h + textAscent() + 20);
    } else { 
      rect(xloc, yloc + slider.h + textAscent() + 20, 20, 20);
      text("Random", xloc + 20 + 20, yloc + slider.h + textAscent() + 20);
      if (randomDT) {
        pushStyle();
        stroke(0);
        strokeWeight(2);
        line(xloc - 10, yloc + slider.h + textAscent() + 20 - 10, xloc + 10, yloc + slider.h + textAscent() + 20 + 10);
        line(xloc + 10, yloc + slider.h + textAscent() + 20 - 10, xloc - 10, yloc + slider.h + textAscent() + 20 + 10);
        popStyle();
      }
    }
    checkHighlight();

    if (isHighlighted) { 
      fill = color(100, 100, 100);
    } else {
      fill = ogfill;
    }

    if (isTrue) {
      pushStyle();
      strokeWeight(3);
      stroke(0);
      line(xloc - boxSize/2, yloc - boxSize/2, xloc + boxSize/2, yloc + boxSize/2);
      line(xloc + boxSize/2, yloc - boxSize/2, xloc - boxSize/2, yloc + boxSize/2);
      fill(100, 100, 100);
      //ellipse(xloc, yloc, 100, 100);
      popStyle();

      //triggers which model is being used
      if (title == "Certainty" && ingroup.isTrue == false) { 
        two = true;
        one = false;
        three = false;
      }
      // if (title == "Certainty" && ingroup.isTrue == true) { 
      if (title == "Ingroup" && ingroup.isTrue == true && certainty.isTrue == true) { 

        three = true;
        one = false;
        two = false;
      }
      if (title == "Ingroup" && certainty.isTrue == false) {
        one = true;
        two = false;
        three = false;
      } 
 
      if (setup) {  
        slider.isActive = true;
      }
    }

    if (isSwitched) {
      fill(340, 100, 100);
    }

    isSwitched = false;

    slider.display();
  }

  void checkHighlight() {

    if (mouseX > xloc - boxSize/2 && mouseX < xloc + boxSize/2 && mouseY > yloc - boxSize/2 && mouseY < yloc + boxSize/2) {
      isHighlighted = true;
    } else {     
      isHighlighted = false;
    }
  }

  class slider {

    float xloc, yloc, sliderx, slidery;
    float w, h;
    booleanParameter owner;

    String title;

    int lower, higher;

    float textHeight;

    button button;

    color fill, ogfill;

    boolean isActive;

    float value = 0;
    float ogvalue;


    slider(float xloci, float yloci, booleanParameter owneri) {

      xloc = xloci;
      yloc = yloci;

      owner = owneri;

      textHeight = textAscent() + textDescent();

      sliderx = xloc;
      slidery = yloc + textHeight;

      w = 100;
      h = 20 + textHeight;

      lower = 0;

      if (owner.title == "Certainty") {
        title = "Difference Tolerance: ";
        higher = 1;
        value = 1;
      }
      if (owner.title == "Ingroup") {
        title = "Similarity Number: ";
        higher = identityCompare;
        value = 0;
      }

      ogvalue = value;

      button = new button(sliderx, slidery, this);

      fill = color(100);
      ogfill = fill;
    }

    void display() {

      if (isActive) {
        fill = color(360);
        button.isActive = true;
      } else {

        fill = ogfill;
        button.isActive = false;
        value = ogvalue;
        button.xloc = button.ogxloc;
      }
      pushStyle();
      textAlign(LEFT, CENTER);

      stroke(fill);
      strokeWeight(10);

      text(title, xloc, yloc);
      text(str(lower), sliderx - 15, slidery);
      text(str(higher), sliderx + w + 10, slidery);
      line(sliderx, slidery, sliderx + w, slidery);

      noStroke();
      fill(360);
      //rect(sliderx + w/2, slidery + 10, 20, 20);
      rect(xloc + textWidth(title) + 10, yloc, 30, 20);
      //println(yloc, "VALUE", value);
      fill(0);
      if (title == "Similarity Number: ") {
        text(str(SN), xloc + textWidth(title), yloc);
      } else {
        text(nf(value, 0, 2), xloc + textWidth(title), yloc);
      }

      popStyle();

      button.display();
    }

    class button {

      float xloc, yloc, ogxloc;
      float size = 11;

      color fill, ogfill;
      boolean isActive;
      boolean isHighlighted;

      slider sowner;

      button(float xloci, float yloci, slider sowneri) {

        xloc = xloci;
        yloc= yloci;

        fill = color(50);
        ogfill = fill;

        sowner = sowneri;

        xloc = xloc + sowner.value * sowner.w;
        ogxloc = xloc;
      }

      void display() {

        if (isActive && setup) {
          button.fill = color(200, 100, 100);
        } else {
          button.fill = button.ogfill;
        }
        if (isHighlighted) {
          fill = color(0, 100, 100);
        }

        fill(fill);
        ellipse(xloc, yloc, size, size);
        checkHighlight();

        if (mousePressed && setup) {//sowner is different...if its ingroup u want to move it only if there is more than one idr and idc!!!!!!!!

          move();
        }
      }

      void checkHighlight() {

        if (dist(mouseX, mouseY, xloc, yloc) < size && isActive) {
          isHighlighted = true;
        } else {
          isHighlighted = false;
        }
      }
      int psn = SN;

      void move() {

        if (mouseX < sowner.xloc + sowner.w && mouseX > sowner.xloc && mouseY > yloc - 5 && mouseY < yloc + 5) {

          xloc = mouseX;
          println("SLIDER", mouseX, xloc - ogxloc, (xloc - ogxloc)/sowner.w );
        }

        sowner.value = sowner.ogvalue + (xloc - ogxloc)/sowner.w;
       
        if (sowner.title == "Difference Tolerance: ") {
          DT = sowner.value;
        }
        if (sowner.title == "Similarity Number: ") {

          SN = int(sowner.value * identityCompare);
          if (psn != SN) {
            createAgents(true);
          }
          psn= SN;
        }
      }
    }
  }
}

void adjustbooleans() {
  useCertainty = certainty.isTrue;
  useIngroup = ingroup.isTrue;
}
