int esize = 20;
boolean one, two, three;

//added interface element at the end so it is just its own function and not a class
void drawModelInterface() {

  pushStyle();

  noStroke();
  textSize(20);

  fill(0, 0, 100);
  text("Model: ", 40, 20);

  ellipse(30, 60, esize, esize);
  text("1", 50, 60);

  ellipse(90, 60, esize, esize);
  text("2", 120, 60);

  ellipse(150, 60, esize, esize);
  text("3", 170, 60);

  popStyle();


  if (dist(mouseX, mouseY, 30, 60)< esize/2 && mousePressed) {
    one = true;
    two = false;
    three = false;

    useCertainty = false;
    useIngroup = true;
  }
  if (dist(mouseX, mouseY, 90, 60)< esize/2 && mousePressed) {
    two = true;
    one = false;
    three = false;

    useIngroup = false;
    useCertainty = true;
  }
  if (dist(mouseX, mouseY, 150, 60)< esize/2 && mousePressed) {
    three = true;
    one = false;
    two = false;

    useIngroup = true;
    useCertainty = true;
  }

  fill(200, 100, 100);

  if (one) {
    ellipse(30, 60, esize*.7, esize*.7);

    ingroup.isTrue = true;
    certainty.isTrue = false;
  } 
  if (two) {
    ellipse(90, 60, esize*.7, esize*.7);

    certainty.isTrue = true;
    ingroup.isTrue = false;
  } 
  if (three) {
    ellipse(150, 60, esize*.7, esize*.7);

    certainty.isTrue = true;
    ingroup.isTrue = true;
  }
}
