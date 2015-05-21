Complex c,z0,zn;
PGraphics pg; // creating the output file buffer
int maxiterations;
double rmin,rmax,imin,imax,inf,zoom;
float huespeed, satspeed, brightspeed;
boolean toWhite;
boolean drawing = true;
float k;
 
void setup() {
  size(700,300);
  colorMode(HSB);
  pg = createGraphics(7000,3000);
  maxiterations = 800;
  c = new Complex(-0.95,-0.2555); // setting centre of image to a - bi
  zoom = 22*pg.width; // setting zoom factor
  // setting the bounds in the complex plane
  float w = (float) pg.width;
  float h = (float) pg.height;
  rmin = c.real - w/zoom; 
  rmax = c.real + w/zoom; 
  imin = c.img - h/zoom; 
  imax = c.img + h/zoom; 
  inf = 2000; // the value for which we treat to be effectively infinity
  huespeed = 1.28;
  satspeed = 1.86; 
  brightspeed = 0.89;
  k = 42; // color shift - between 0 and 135
  toWhite = true; // outside region fading to white (true) or to black (false)
  pg.translate(pg.width/2,pg.height/2); // centres the coordinate system
  mandelbrotDrawToFile();
}
void draw() {
  background(120);
  text("Finished!", 50,50);
  image(pg,0,0);
}
 
void mandelbrotDrawToFile() {
  pg.beginDraw();
  pg.loadPixels();
  int i,j; // iterators to cover the pixels
  double dr = (rmax - rmin) / (pg.width); // incriment in real axis
  double di = (imax - imin) / (pg.height); //incriment in imaginary axis
  // looping over the imaginary axis
  for (i = 0; i < pg.height; i++) {
    // looping over the real axis
    for (j = 0; j < pg.width; j++) {
      // code for checking pixel
      float n = 0; // the iteration number of the sequence
      z0 = new Complex(rmin + j*dr,imin + i*di); // the initial complex number
      zn = new Complex(z0.real,z0.img); // setting zn to starting point
      while (n < maxiterations) {
        zn = z0.cadd(zn.cmult(zn)); // setting zn = zn^2 + z0
        if (zn.cabs().real > inf) {break;}
        n++;
      }
      // the number of iterations taken to reach 'infinity' is n, now we need to color the pixel
      if (n == maxiterations) {
        pg.pixels[j + i*pg.width] = color(0);
      } else {
        if (toWhite) {
          float modzn = (float) zn.cabs().real;
          float nu = log(log(modzn)/log(2))/log(2);
          n = n + 1 - floor(nu);
          color color1 = color((255-(huespeed*n))% 120+k, 255-(satspeed*n)%150, (255-(brightspeed*n))%145+100);
          color color2 = color((255-(huespeed*(n+1))) % 120 +k, 255-(satspeed*(n+1))%150, (255-(brightspeed*(n+1)))%145+100);
          pg.pixels[j + i*pg.width] = lerpColor(color1,color2,0.5);
        } else {
          pg.pixels[j + i*pg.width] = color((huespeed*n) % 255, (satspeed*n)%255, (brightspeed*n)%255);
        }
      } 
    }
  }
  pg.updatePixels();
  pg.endDraw();
  pg.save("hixbrot.tif");
}
 
void mouseClicked() {
  //c = Complex(mouseX,mouseY); // resetting c parameter to mouse position (Julia set)
  draw();
}
 
// creating the class of complex numbers
class Complex {
    double real;   // the real part
    double img;   // the imaginary part
    public Complex(double real, double img) {
        this.real = real;
        this.img = img;
    }
// Complex multiplication
    public Complex cmult(Complex b) {
        double real = this.real * b.real - this.img * b.img;
        double img = this.real * b.img + this.img * b.real;
        return new Complex(real, img);
    }
   // Complex addition
    public Complex cadd(Complex b) {
        double real = this.real + b.real;
        double img = this.img + b.img;
        return new Complex(real, img);
    }
   // Complex absolute value (distance from the origin)
    public Complex cabs() {
        double abs = Math.pow(Math.pow(this.real,2) + Math.pow(this.img,2),0.5);
        return new Complex(abs,0);
    }
}
