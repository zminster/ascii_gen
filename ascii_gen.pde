final int textHeight = 7;  // height of glyph box (font size)
final int textWidth = 5;   // width of glyph box
final int textOffset = 6;  // push text down inside the glyph box

String characterSet = "";  // full set of candidate characters
PGraphics[] glyphs;        // contains glyph representation of each character in set
float[] glyph_grays;       // grayscale values for each glyph
PFont font;                // font file
PImage img;                // base image

void setup() {
  fullScreen();
  noStroke();
  
  // construct requirements
  font = createFont("monospace.ttf", textHeight);
  img = loadImage("castle.jpg");
  img.resize(width, height);  
  for (int i = 33; i <= 126; i++) characterSet += (char) i;

  // create rendered glyph boxes for every character in the character set
  glyphs = new PGraphics[characterSet.length()];
  for (int charPos = 0; charPos < characterSet.length(); charPos++) {
    glyphs[charPos] = createGraphics(textWidth, textHeight);
    glyphs[charPos].beginDraw();
    glyphs[charPos].background(255);
    glyphs[charPos].textFont(font);
    glyphs[charPos].fill(0);
    glyphs[charPos].text(characterSet.charAt(charPos), 0, textOffset);
    glyphs[charPos].endDraw();
  }

  // judge how "dark" all the glyphs are and store the value
  glyph_grays = new float[characterSet.length()];
  for (int glyph = 0; glyph < characterSet.length(); glyph++) {
    glyph_grays[glyph] = grayOfChunk(glyphs[glyph].get());
  }

  // modify the glyph gray values across the full range 0-255
  float lowest = glyph_grays[findLowestPos(glyph_grays)];
  float highest = glyph_grays[findHighestPos(glyph_grays)];
  for (int glyph = 0; glyph < characterSet.length(); glyph++) {
    glyph_grays[glyph] = map(glyph_grays[glyph], lowest, highest, 0, 255);
  }

  // let's roll :: main algorithm
  // roll through the image in chunks of size textWidth x textHeight
  for (int y = 0; y < img.height; y += textHeight) {
    for (int x = 0; x < img.width; x += textWidth) {
      PImage chunk = img.get(x, y, textWidth, textHeight);
      // judge the average brightness of the chunk
      float gray = grayOfChunk(chunk);
      // compare chunk brightness to the glyphs
      // find the glyph with the closest brightness
      int closestPos = 0;
      for (int glyphPos = 0; glyphPos < glyph_grays.length; glyphPos++) {
        if (abs(glyph_grays[glyphPos] - gray) < abs(glyph_grays[closestPos] - gray))
          closestPos = glyphPos;
      }
      // render the glyphs on the screen for comparison
      image(glyphs[closestPos], x, y);
    }
  }
}

void draw() { }  // enables killing fullscreen

// loop through whole PImage and count black values to find/report average
float grayOfChunk(PImage chunk) {
  float blackSum = 0;
  for (int x = 0; x < chunk.width; x++) {
    for (int y = 0; y < chunk.height; y++) {
      blackSum += brightness(chunk.get(x, y));
    }
  }
  return blackSum / (chunk.width * chunk.height);
}

// find position of lowest value in float array
int findLowestPos(float[] arr) {
  int lowestPos = 0;
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] < arr[lowestPos]) {
      lowestPos = i;
    }
  }
  return lowestPos;
}

// find position of highest value in float array
int findHighestPos(float[] arr) {
  int highestPos = 0;
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] > arr[highestPos]) {
      highestPos = i;
    }
  }
  return highestPos;
}
