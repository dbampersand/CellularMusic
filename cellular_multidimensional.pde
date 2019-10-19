import processing.sound.*;

class Cell
{
  boolean alive = false;
  color col = color(1,1,1);
  
  int isActive()
  {
     if (alive)
       return 1;
     else
       return 0;
  }
  void interact(color other)
  {
    col *= other;
  }
  
  Cell()
  {
    alive = false;
    col = color(1,1,1);
  }
  
}
class Char
{
  boolean[][] pix;
  char ch;
  public Char(char c)
  {
    ch = c;
    pix = new boolean[9][9];
   
  }
}

class Scrollbar
{
    int x; int y;
    int w; int h;
    float val=0.1;
    float rangeMin = 0;
    float rangeMax = 200;
    public float getVal()
    {
       return (rangeMin+rangeMax) * val; 
    }
    public Scrollbar(int X, int Y, int W, int H)
    {
       x=X;
       y=Y;
       w=W;
       h=H;
       
    }
    public void isClicked(int mouseX, int mouseY)
    {
      if (pointIntersects(mouseX,mouseY))
      {
          val = 1/((x+w)/(float)mouseX); 
      }
    }
     private boolean pointIntersects(int X, int Y)
    {
      if (X>x && X < x+w)
        if (Y>y && Y < y+h)
          return true;
      return false;
  }

}
class RadioButton
{
  ArrayList<RadioButton> otherButtons = new ArrayList<RadioButton>();
  int x; int y; int w; int h; boolean active = false; String label = "";
  public RadioButton(int X, int Y, int W, int H, String lab)
  {
       x = X;
       y = Y;
       w = W;
       h = H;
       label = lab;
 }
 void LinkTo(ArrayList<RadioButton> linkedTo)
 {
   otherButtons = linkedTo;
 }
   void IsClicked(int mouseX, int mouseY)
   {
     if (pointIntersects(mouseX,mouseY))
     {
       activate();
     }
   }
   void activate()
   {
     for (int i = 0; i < otherButtons.size(); i++)
     {
         otherButtons.get(i).active = false;
     }
     active = true;
   }
  private boolean pointIntersects(int X, int Y)
  {
    if (X>x && X < x+w)
      if (Y>y && Y < y+h)
        return true;
    return false;
  }

}
class Button
{
  int x; int y;
  int w; int h;
  boolean isActive = false;
  public Button(int X, int Y, int W, int H)
  {
    x = X;
    y = Y;
    w = W;
    h = H;
  }
  public void IsClicked(int MouseX, int MouseY)
  {
    if (pointIntersects(MouseX,MouseY))
    {
      if (isActive)
        isActive = false;
      else
        isActive = true;
    }
  }
  public int isOn()
  {
     if (isActive == false)
       return 0;
     return 1;
  }
  private boolean pointIntersects(int X, int Y)
  {
    if (X>x && X < x+w)
      if (Y>y && Y < y+h)
        return true;
    return false;
  }
}
final int _WIDTH = 64;
final int _HEIGHT = 64;
final int _NUMDIMENSIONSX = 1;
final int _NUMDIMENSIONSY = 1;

Button[][] buttons = new Button[(8*_NUMDIMENSIONSX)][(_NUMDIMENSIONSY)+1];

final int _ButtonStartY = 600;
Scrollbar bpmSlider = new Scrollbar(10,520,300,30);
Scrollbar worldSlider = new Scrollbar(10,560,300,30);

float _SINSCALE = 200;
float noteAdd =1;
int currAudioLine = 0;
int currXAudio = 0;

int charsX = 0;
int linesY = 0;
ArrayList<Char> characters;


Cell[][] world = new Cell[_WIDTH][_HEIGHT]; 

float[] NoteFrequencies = {16.35,17.32,18.35,19.45,20.60,21.83,23.12,24.50,25.96,27.50,29.14,30.87};//starts at c0
boolean[] majorScale = {true,false,true,false,true,true,false,true,false,true,false,true};
boolean[] naturalMinorScale = {true,false,true,true,false,true,false,true,true,false,true,false};
boolean[] harmonicMinorScale = {true,false,true,true,false,true,false,true,true,false,false,true};
boolean[] pentatonicMinorScale = {true,false,false,true,false,true,false,true,false,false,true,false};
boolean[] currScale = harmonicMinorScale;

Boolean[] ruleLiveDeath = {false,false,true,true,false,false,false,false,false};
Boolean[] ruleProcreate = {false,false,false,true,false,false,false,false,false};

boolean simulating = false;
int cellSize = 8;

int LAST=0;
int timer = 0;
int audioTimer=0;
SinOsc oscillator = new SinOsc(this);
ArrayList RadioButtons = new ArrayList();

boolean spaceBarPressedLastFrame = false;
Cell[][] RandomizeWorld(Cell[][] wor)
{
    for (int x = 0; x < wor.length; x++)
    {
        for (int y  = 0; y < wor[0].length; y++)
       {
         int i = (int)random(0,2);
         if (i == 0)
         {
             wor[x][y].alive = false;
         }
         if (i == 1)
         {
             wor[x][y].alive = true;
         }

       }
       
    }
    return wor;
}
ArrayList<Char> loadChars(String path)
{
  
  String[] lines = loadStrings(path);
  
  ArrayList<Char> chars = new ArrayList<Char>();
  
  int currY=0;
  int currX=0;
  for (int i = 0; i < lines.length; i++)
  {
    for (int z = 0; z < lines[i].length(); z++)
    {
       if (lines[i].charAt(z) >= 65 && lines[i].charAt(z) <= 90) //only characters A-Z capitals
       {
         chars.add(new Char(lines[i].charAt(z)));

         currY = -1;
         currX = 0;
         break;
       }
       
       if (chars.size() > 0)
       {
         if (lines[i].charAt(z) == '1')
         {
             Char c = (Char)(chars.get(chars.size()-1));
             c.pix[currX][currY] = true;
             currX++;

         }
          if (lines[i].charAt(z) == '0')
         {
             Char c = (Char)(chars.get(chars.size()-1));
             c.pix[currX][currY] = false;
             currX++;

         }

       }

    }
    currY++;
    currX=0;
  }
  return chars;
}
void mouseClicked() {
  for (int x =0; x < buttons.length;x++)
  {
    for (int y =0;y  < buttons[0].length;y++)
    {
        buttons[x][y].IsClicked(mouseX,mouseY);
    }
  }
  for (int i = 0; i < buttons.length; i++)
  {
    ruleLiveDeath[i] = buttons[i][0].isActive;
  }
    for (int i = 0; i < buttons.length; i++)
  {
    ruleProcreate[i] = buttons[i][1].isActive;
  }
      if (mouseX > 0 && (mouseX/cellSize) <= world.length-1)
  {
    if (mouseY > 0 && (mouseY/cellSize) <= world[0].length-1)
    {
        world[mouseX/cellSize][mouseY/cellSize].alive = !world[mouseX/cellSize][mouseY/cellSize].alive; 
    }
  }
  for (int i = 0; i < RadioButtons.size(); i++)
  {
     RadioButton r = (RadioButton)(RadioButtons.get(i));
     r.IsClicked(mouseX,mouseY);
     if (r.active)
     {
       if (r.label == "Major")
         currScale = majorScale;
        if (r.label == "Minor")
         currScale = naturalMinorScale;
       if (r.label == "Harmonic")
         currScale = harmonicMinorScale;
       if (r.label == "Pentatonic")
         currScale = pentatonicMinorScale;

     } 
}
  
  bpmSlider.isClicked(mouseX,mouseY);
  worldSlider.isClicked(mouseX,mouseY);

}
void mouseDragged() 
{
    if (mouseX > 0 && (mouseX/cellSize) < world.length-1)
  {
    if (mouseY > 0 && (mouseY/cellSize) < world[0].length-1)
    {
        world[mouseX/cellSize][mouseY/cellSize].alive = true; 
    }
  }
  for (int i = 0; i < RadioButtons.size(); i++)
  {
     RadioButton r = (RadioButton)(RadioButtons.get(i));
     r.IsClicked(mouseX,mouseY);
  }

  bpmSlider.isClicked(mouseX,mouseY);
  worldSlider.isClicked(mouseX,mouseY);

}
Cell[][] InitializeWorld(Cell[][] wor, int w, int h)
{
    wor = new Cell[w][h];
    for (int x = 0; x < w; x++)
    {
       for (int y  = 0; y < h; y++)
       {
           wor[x][y] = new Cell();
       }
    }
    return wor;
}
int QuantizeNearestScale(int midiNote)
{
  int n = midiNote;
  while (n>0)
  {
     n-=12;
  }
  n+= 12;
  if (n >= 0 && n < 12)
    if (currScale[n] == true)
    {
      return n;
    }
  for (int i = 0; i < currScale.length; i++)
  {
      if (ArrLoopAround(n-i,currScale) == true)
      {
          return (n-i);
      }
      if (ArrLoopAround(n+i,currScale) == true)
      {
        return (n+i);
      }
  }
  
  return 0;
}  
boolean ArrLoopAround(int i, boolean[] array)
{
  if (i>=array.length)
    return array[i-array.length];
  if (i < 0)
    return array[array.length-i];
  return array[i];
}

void playAudio()
{
  currAudioLine++;
  if (currAudioLine > world.length-1)
    currAudioLine=0;
    
   float note = 0; 
   float min = 60;
   float max = 82;
   
   boolean none = false;
   
   for (int x = 0; x < world.length; x++)
   {
     
     if (world[x][currAudioLine].alive == true)
       note += 1;
   }
   if (note == 0) none = true;
   note = min + (int)((max-min) * (note/world.length));
   if (note > 0)
   {
     float octave = (int)(note/12.0f);
     note = QuantizeNearestScale((int)note) + (octave*12);
   }
   float f = (pow(2,(note-69)/12.0f)) * 440;
   
   oscillator.freq(f);
   if (none)
     oscillator.amp(0.08);
   else
     oscillator.amp(0.4);

 }

 float log2(float f)
 {
     return (log(f) / log(2));
 }
void setup()
{
     size(650,750);
     frameRate(200);
     colorMode(RGB, 1.0f);
     world = InitializeWorld(world,_WIDTH,_HEIGHT);
   //  world = RandomizeWorld(world);
    // characters = loadChars("font.txt");
     for (int x =0; x < buttons.length;x++)
     {
        for (int y =0; y < buttons[0].length;y++)
        {
          buttons[x][y] = new Button(x*64, _ButtonStartY + (64 * y)+1, 63,64);
        }
     }

      buttons[2][0].isActive = true; 
      buttons[3][0].isActive = true; 
      buttons[3][1].isActive = true;

    
       RadioButtons.add(new RadioButton(550,300,32,32,"Major"));
       RadioButtons.add(new RadioButton(600,300,32,32,"Minor"));
       RadioButtons.add(new RadioButton(550,350,32,32,"Harmonic"));
       RadioButtons.add(new RadioButton(600,350,32,32,"Pentatonic"));
       
       for (int i = 0; i < RadioButtons.size(); i++)
       {
           RadioButton r = (RadioButton)RadioButtons.get(i);
           r.LinkTo(RadioButtons);
           r.activate();
       }
}

void doAudio()
{    if (audioTimer >  ((1/bpmSlider.getVal())*1000))
    {
        audioTimer=0;
        playAudio();
    }
}

void draw()
{
  fill(0.4,0.4,0.4);
  rect(0,0,650,750);
  if (simulating)
  {
    oscillator.play();
    timer += millis() - LAST;
    audioTimer += millis() - LAST;
    if (timer > (1/worldSlider.getVal())*1000)
    {
      DoTick();  
      timer=0;
    }
    doAudio();   
  }   
  for (int x = 0; x < world.length; x++)
  {
   for (int y = 0; y < world[0].length; y++)
   {
       fill(0,0,0);
       if (world[x][y].alive) {
         if (currAudioLine == y)
         {
            fill(1,0,0); 
         }
         else
             fill(world[x][y].col);
       }  
        rect((cellSize*x),(cellSize*y),cellSize,cellSize);

   }
  }
     for (int x =0; x < buttons.length;x++)
    {
      for (int y =0; y < buttons[0].length;y++)
      {
        if (buttons[x][y].isActive)
        {
           fill(1,1,1); 
        }
        else
        {
          fill(0.25,0.25,0.25);
        }
          rect(buttons[x][y].x,buttons[x][y].y,buttons[x][y].w,buttons[x][y].h);
      }
    }
    
    
    fill(1,1,1);
    textSize(12);
    
    text("Live/death rule",(buttons[0][0].w * 8) + 12, buttons[0][0].y + (buttons[0][0].h/2) + 10);
     text("Procreate rule",(buttons[0][0].w * 8) + 12, buttons[0][1].y + (buttons[0][0].h/2) + 10);

    
    text("Sound tick speed",bpmSlider.x+worldSlider.w + 10,bpmSlider.y +(worldSlider.h/2) + 4);
    rect(bpmSlider.x,bpmSlider.y,bpmSlider.w,bpmSlider.h);
    rect(bpmSlider.x+(bpmSlider.w*bpmSlider.val),bpmSlider.y,32,32);
    
    textSize(12);
    text("World tick speed",worldSlider.x+worldSlider.w + 10,worldSlider.y + (worldSlider.h/2)+4);
    rect(worldSlider.x,worldSlider.y,worldSlider.w,worldSlider.h);
    rect(worldSlider.x+(worldSlider.w*worldSlider.val),worldSlider.y,32,32);

     for (int i = 0; i < RadioButtons.size(); i++)
     {
         RadioButton r = (RadioButton)RadioButtons.get(i);
         fill(1,1,1);
         textSize(8);
         text(r.label,r.x-10,r.y-20);
         if (r.active)
           fill(1,1,1);
         else
           fill(0.6,0.6,0.6);
         circle(r.x,r.y,r.w);
     }
    LAST = millis();
 }
void keyPressed()
{
  /*for (int i = 0; i < characters.size(); i++)
   {

      Char c = (Char)(characters.get(i));
      if (key == c.ch)
      {
        world = addPixels(c.pix, world);
        charsX++;  
      }
   }
      }*/
      if (key == ' ')
      {
        charsX = 0;
        linesY = 0;
        simulating = !simulating;
        if (simulating)
          oscillator.play();
        if (!simulating)
          oscillator.stop();
      }
}
Cell[][] addPixels(boolean[][] pix, Cell[][] wor)
{
  Cell[][] newWorld = wor;
  int MoveLineAfter = (int)(wor.length / pix.length)-1;
  if (charsX > MoveLineAfter)
  {
     charsX = 0;
     linesY++;
  }
  int startX = charsX * pix.length;
  int startY = (linesY * pix[0].length) +1;
   for (int x = 0; x < pix.length; x++)
  {
     for (int y = 0; y < pix[0].length; y++)
     {
       if (isInBounds(x+startX,y+startY,wor.length,wor[0].length))
       {
         if (pix[x][y] == true)
         {
             wor[x+startX][y+startY].alive = true;
         }  
       }  
     }
  }
  return newWorld;
}
void DoTick()
{
  Cell[][] newWorld = null;
  newWorld = InitializeWorld(newWorld,_WIDTH,_HEIGHT);
  for (int x = 0; x < world.length; x++)
  {
     for (int y = 0; y < world[0].length; y++)
     {
         int numNeighbours = getNeighbours(x,y,world);
         if (world[x][y].alive == true)
         {
             if (ruleLiveDeath[numNeighbours] == true)
             {
               newWorld[x][y].alive = true;
             }
             //constructor defaults to false so nothing more needed
         }
         else
         {
               if (ruleProcreate[numNeighbours] == true)
               {
                  newWorld[x][y].alive = true; 
               }
         }
     }
  }
  world = newWorld;
  
}
int checkCell(int x, int y, Cell[][] wor)
{
    if (isInBounds(x,y,wor.length,wor[0].length))
    {
      return wor[x][y].isActive();
    }
    return 0;

}
int getNeighbours(int x, int y,Cell[][] wor)
{
  int neighbours = 0;
  
  //top row
  neighbours += checkCell(x-1,y-1,wor);
  neighbours += checkCell(x+1,y-1,wor);
  neighbours += checkCell(x,y-1,wor);

  //right side
  neighbours += checkCell(x+1,y,wor);

  //bottom row
  neighbours += checkCell(x-1,y+1,wor);
  neighbours += checkCell(x,y+1,wor);
  neighbours += checkCell(x+1,y+1,wor);

  //left side
  neighbours += checkCell(x-1,y,wor);

  return neighbours;
}

boolean isInBounds(int x, int y, int w, int h)
{
  return (x > 0 && x < w && y > 0 && y < h);
  
}
