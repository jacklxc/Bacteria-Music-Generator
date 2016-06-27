import processing.video.*;
import arb.soundcipher.*;
import blobDetection.*;

Capture video_sequencer, video_rack;
SoundCipher sc = new SoundCipher(this);

int grid_size=20;
int grid_num=16;
int window_size;
int window_height;
int block_number=3;

int interval=4;
int margin;

int n=0;//iterator for play()

int select=0;//which plate is selected?
boolean video_on=false;
boolean[] track= new boolean[block_number];
Sequencer[] sequencer= new Sequencer[block_number];
Sequencer_video sequencer_video;
Rack rack;

void setup() {
  window_size=displayWidth;
  window_height=displayHeight;

  margin=(window_size-(grid_num*(grid_size+interval)+interval)
    *block_number)/(block_number+1);

  size(window_size, window_height);

  //empty tracks
  for (int i=0; i<block_number; i++) {
    track[i]=false;
  }

  make_empty();

  String[] cameras = Capture.list();

  video_sequencer = new Capture(this, cameras[0]);  
  video_sequencer.start(); 
  sequencer_video=new Sequencer_video(video_sequencer, sc, grid_num, grid_size, interval); 

  video_rack = new Capture(this, cameras[0]);
  video_rack.start();
  rack=new Rack(video_rack, sc, window_size, window_height, 
  window_height-margin-grid_num*(grid_size+interval));

  frameRate(4);
}

void draw() {
  background(0);
  rack.get_color();
  rack.draw_rack();
  rack.glow(n);
  rack.play_sounds(n);


  for (int i=0; i<block_number; i++) {
    sequencer[i].draw_grid();

    if (track[i]) {
      sequencer[i].play_sounds(n);
      sequencer[i].glow(n);
    }
  }

  if (video_on) {

    sequencer_video.position(pos_x(select), margin);     
    sequencer_video.bd();
    sequencer_video.bd_draw(n);
  }

  n++;
  if (n>=grid_num) {
    n=0;
  }
}


void keyPressed() {
  if (key==CODED) {
    if (keyCode==UP) {
      if (track[select]) {
        sequencer[select].volume_up();
      } else if (video_on) {
        sequencer_video.volume_up();
      }
    } else if (keyCode==DOWN) {
      if (track[select]) {
        sequencer[select].volume_down();
      } else if (video_on) {
        sequencer_video.volume_down();
      }
    } else if (keyCode==LEFT) {
      sequencer[select].select(false);
      select-=1;
      if (select==-1) {
        select=block_number-1;
      }
      sequencer[select].select(true);
    } else if (keyCode==RIGHT) {
      sequencer[select].select(false);
      select+=1;
      if (select==block_number) {
        select=0;
      }
      sequencer[select].select(true);
    }
  } else if (keyCode==BACKSPACE) {
    track[select]=false;
    sequencer[select].delete();
  } else if (keyCode==TAB) {
    video_on=true;
    sequencer_video.grid_off();
    sequencer[select].select(false);
    sequencer[select].delete();
  } else if (keyCode==ENTER || keyCode==ENTER) {
    boolean[] sequence=sequencer_video.sequence();
    float[] grid_color=sequencer_video.grid_color();
    sequencer[select].get_sequence(sequence);
    sequencer[select].get_color(grid_color);
    video_on=false;

    track[select]=true;
    sequencer[select].select(true);
  } else if (key==' ') {
    sequencer_video.grid();
  } else if (key=='q'||key=='Q') {
    sequencer_video.threshold_down();
  } else if (key=='w'||key=='W') {
    sequencer_video.threshold_up();
  } else if (key=='a'||key=='A') {
    rack.volume_down();
  } else if (key=='s'||key=='S') {
    rack.volume_up();
  }
}

void make_empty() {
  for (int i=0; i<block_number; i++) {
    int x= pos_x(i);
    int y=margin;
    sequencer[i]=new Sequencer(sc, grid_num, grid_size, interval, x, y);
  }
}

int pos_x(int i) {
  int x=margin+(grid_num*(grid_size+interval)+interval+margin)*i;
  return x;
}

