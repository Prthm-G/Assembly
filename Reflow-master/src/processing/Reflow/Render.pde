float x, y;

void mode1() {
    fill(0);
    rectMode(CORNER);
    rect(0, 0, 120, height);
    rect(0, height - 50, width, height);

    // display array
    stroke(255);
    strokeWeight(1);
    for (int i = 0; i < data.length; i++) {
      y = map(data[i], 0, 260, height - 50, 50);
      x = map(i, 0, data.length + 1, 120, width);
      if (data.length > 1 && i != data.length-1) {
        line(
          x,
          y,
          map(i+1, 0, data.length + 1, 120, width),
          (data[i+1] == 0) ? y : map(data[i+1], 0, 260, height-50, 50)
          );
      }
    }
    noStroke();
    fill(255);
    text(str(millis() / 1000) + 's', x, height - 25);

    // display temperature
    textAlign(CORNER, CENTER);
    text(str(signal) + " deg C", 10, y);
}

void mode2() {
    fill(0, 25);
    noStroke();
    rect(0, 0, width, height);
    fill(255);
    drawSignal(signal);
    displayState(state);

    // draw onto the screen
    if (readString != null) {
        // println(readString);
        textSize(50);
        stroke(240);
        rectMode(CENTER);
        fill(power == 1 ? 0: 50, 100);
        noStroke();
        rect(width/2, height/2, width/4, 100);
        rectMode(CORNER);
        fill(255);
        // text(components[0] + " : " + components[1] + " : "  + components[2], width/2, height/2);
        textAlign(CENTER, CENTER);
        text(str(signal) + " deg C", width/2, height/2);
    }
}

void mode3() {
    fill(0, 25);
    noStroke();
    rect(0, 0, width, height);
    fill(255);
    float strip_y = map(signal, 0, 260, height - 50, 50);
    fill(
        map(strip_y, 0.3 * (height - 50), 0.7 * (height - 50), 255, 0),
        (1 - sq(map(strip_y, 0, height, -1, 1))) * 255,
        map(strip_y, 0.3 * (height - 50), 0.7 * (height - 50), 0, 255)
        );
    rect(strip_x, strip_y, 5, height-50-strip_y);

    // display x-axis label
    fill(0);
    rect(0, height-50, width, height);
    textSize(20);
    fill(255);
    text(str(millis() / 1000) + 's', strip_x, height - 25);

    // display temperature
    textAlign(CORNER, CENTER);
    text(str(signal) + " deg C", 20, strip_y);

    // increment horizontal
    strip_x = (strip_x >= width) ? 0 : strip_x + 5;
}

void drawSignal(float value) {
    theta = (theta >= TWO_PI) ? 0 : theta + 0.01;
    float r = map(value, 0, 260, 30, 400);
    float sx = width/2 + r * cos(theta);
    float sy = height/2 + r * sin(theta);
    stroke(0, 255, 255);
    strokeWeight(10);
    line(width/2, height/2, sx, sy);
}

void generateHexagon(float x, float y, float radius, int nstates) {
    float angle = TWO_PI / nstates;
    for (int i = 0; i < nstates; i++) {
        hex_x[i] = x + cos(i * angle) * radius;
        hex_y[i] = y + sin(i * angle) * radius;
    }
}

void displayState(int activeState) {
    for (int i = 0; i < STATES.length; i++) {
        if (i == activeState) {
            stroke(0, 255, 255, 50);
            strokeWeight(20);
            if (activeState == 5) {
              line(hex_x[i], hex_y[i], hex_x[0], hex_y[0]);
            } else {
              line(hex_x[i], hex_y[i], hex_x[i+1], hex_y[i+1]);
            }
            stroke(0, 255, 255);
        } else {
            stroke(240);
            strokeWeight(1);
        }
        noFill();
        polygon(hex_x[i], hex_y[i], SMALL_HEX, 6);
        textSize(20);
        text(STATES[i], hex_x[i], hex_y[i]);
    }
}

void polygon(float x, float y, float radius, int npoints) {
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
        float sx = x + cos(a) * radius;
        float sy = y + sin(a) * radius;
        vertex(sx, sy);
    }
    endShape(CLOSE);
}
