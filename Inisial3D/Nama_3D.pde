// Import library font dari Java bawaan
import java.awt.Font;

// Inisialisasi font
PFont font;
String fontName = "LeoSemiRounded-Bold.ttf";

// Variabel untuk transformasi dan kontrol visual objek
float rotX = 0, rotY = 0, rotZ = 0;         // Rotasi sumbu X, Y, Z
float posX = 0, posY = 0, posZ = 0;         // Posisi translasi objek
float zoom = 1.0;                           // Skala zoom
boolean autoRoll = false;                  // Toggle roll otomatis
boolean useTexture = false;                // Toggle tekstur aktif/tidak

// Konfigurasi teks 3D
String text = "mar";                       // Teks yang akan ditampilkan
float textSize = 100;                      // Ukuran font
float textDepth = 60;                      // Kedalaman ekstrusi teks

// Posisi cahaya
float lightX = 100, lightY = -100, lightZ = 100;
PImage tex;                                // Gambar tekstur

void setup() {
  size(1200, 800, P3D);                    // Ukuran window dan mode 3D
  smooth(8);                               // Anti-aliasing
  font = createFont(fontName, textSize, true); // Load font dari file .ttf
  textFont(font);                          // Terapkan font ke teks
  tex = loadImage("texture.jpg");          // Load gambar tekstur
}

void draw() {
  background(255);                         // Latar belakang putih

  // Setup pencahayaan
  ambientLight(80, 80, 80);                // Cahaya ambient
  directionalLight(255, 255, 255, lightX/150.0, lightY/150.0, lightZ/150.0); // Cahaya arah
  specular(255);                           // Highlight spekular
  shininess(100);                          // Kilauan objek

  // Transformasi objek berdasarkan posisi, rotasi, dan zoom
  translate(width/2 + posX, height/2 + posY, posZ); // Pusatkan ke layar + translasi
  scale(zoom);                             // Zoom objek
  rotateX(rotX);                           // Rotasi X (pitch)
  rotateY(rotY);                           // Rotasi Y (yaw)
  rotateZ(autoRoll ? millis() * 0.001 + rotZ : rotZ); // Rotasi Z (roll)

  drawSmoothText3D();                      // Gambar objek teks 3D
  drawUI();                                // Tampilkan informasi kontrol
}

void drawSmoothText3D() {
  textAlign(CENTER, CENTER);
  textSize(textSize);
  strokeWeight(0.3);

  int layers = 120;                        // Jumlah lapisan untuk efek kedalaman
  for (int i = 0; i < layers; i++) {
    float t = (float)i / (layers - 1);     // Normalisasi lapisan
    float z = lerp(-textDepth/2, textDepth/2, t); // Posisi Z tiap lapisan

    pushMatrix();
    translate(0, 0, z);

    if (useTexture) {
      beginShape();
      texture(tex);
      fill(255);
      text(text, 0, 0);
      endShape();
    } else {
      fill(0, 0, 255, 255);                // Warna biru solid
      stroke(0, 0, 180, 180);              // Outline biru lebih tua
      text(text, 0, 0);
    }
    popMatrix();
  }

  // Tampilan depan teks
  pushMatrix();
  translate(0, 0, textDepth/2 + 1);
  fill(0, 0, 255);
  stroke(0, 0, 180);
  text(text, 0, 0);
  popMatrix();

  // Tampilan belakang teks
  pushMatrix();
  translate(0, 0, -textDepth/2 - 1);
  fill(0, 0, 150);
  stroke(0, 0, 100);
  text(text, 0, 0);
  popMatrix();
}

void drawUI() {
  camera();                                // Reset kamera untuk UI overlay
  hint(DISABLE_DEPTH_TEST);               // Hindari konflik depth dengan objek 3D

  // Panel UI semi transparan
  fill(255, 255, 255, 200);
  noStroke();
  rect(10, 10, 400, 230);

  fill(0);                                 // Warna teks hitam
  textAlign(LEFT, TOP);
  textSize(16);

  // Info kontrol untuk pengguna
  String info = 
    "═══ CONTROLS ═══\n" +
    "Panah ↑↓ → Pitch\n" +
    "Panah ←→ → Yaw\n" +
    "R → Toggle Auto Roll\n" +
    "W/A/S/D → Crab (↑↓←→)\n" +
    "Q/E → Geser Z (depan/belakang)\n" +
    "+ / - → Zoom In / Out\n" +
    "T → Toggle Texture\n" +
    "I/J/K/L/U/O → Geser Sumber Cahaya\n" +
    "SPASI → Reset posisi";

  text(info, 20, 20);                      // Tampilkan teks UI

  hint(ENABLE_DEPTH_TEST);                // Aktifkan depth test kembali
}

void keyPressed() {
  // Tombol translasi dan kontrol
  switch (key) {
    case 'w': case 'W': posY -= 15; break; // Naik (ped up)
    case 's': case 'S': posY += 15; break; // Turun (ped down)
    case 'a': case 'A': posX -= 15; break; // Geser kiri (crab)
    case 'd': case 'D': posX += 15; break; // Geser kanan (crab)
    case 'q': case 'Q': posZ -= 15; break; // Mundur
    case 'e': case 'E': posZ += 15; break; // Maju
    case 'r': case 'R': autoRoll = !autoRoll; break; // Toggle auto roll
    case 't': case 'T': useTexture = !useTexture; break; // Toggle texture
    case '+': zoom = constrain(zoom + 0.1, 0.2, 3.0); break; // Zoom in
    case '-': zoom = constrain(zoom - 0.1, 0.2, 3.0); break; // Zoom out
    case ' ': resetTransform(); break; // Reset semua
    // Geser arah cahaya
    case 'i': case 'I': lightY -= 25; break; 
    case 'k': case 'K': lightY += 25; break;
    case 'j': case 'J': lightX -= 25; break;
    case 'l': case 'L': lightX += 25; break;
    case 'u': case 'U': lightZ -= 25; break;
    case 'o': case 'O': lightZ += 25; break;
  }

  // Tombol khusus (panah keyboard)
  if (key == CODED) {
    switch (keyCode) {
      case UP: rotX -= 0.1; break;     // Pitch naik
      case DOWN: rotX += 0.1; break;   // Pitch turun
      case LEFT: rotY -= 0.1; break;   // Yaw kiri
      case RIGHT: rotY += 0.1; break;  // Yaw kanan
    }
  }
}

void resetTransform() {
  // Kembalikan semua ke posisi awal
  rotX = rotY = rotZ = 0;
  posX = posY = posZ = 0;
  zoom = 1.0;
  lightX = 100;
  lightY = -100;
  lightZ = 100;
  autoRoll = false;
}
