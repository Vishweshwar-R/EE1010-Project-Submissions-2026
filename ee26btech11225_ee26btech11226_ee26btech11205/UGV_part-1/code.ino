#define CUSTOM_SETTINGS
#define INCLUDE_GAMEPAD_MODULE
#include <DabbleESP32.h>

#define IN1 26
#define IN2 27
#define IN3 25
#define IN4 33
#define ENA 14
#define ENB 32

const bool INVERT_LEFT  = false;
const bool INVERT_RIGHT = false;
const float LEFT_TRIM  = 1.00;
const float RIGHT_TRIM = 0.95;   

const int SPEED_TRIANGLE = 255;
const int SPEED_CIRCLE   = 205;
const int SPEED_SQUARE   = 160;
const int SPEED_CROSS    = 120;

int speedLevel = SPEED_TRIANGLE;   // starting speed

void pwmInit() {
#if ESP_ARDUINO_VERSION_MAJOR >= 3
  ledcAttach(ENA, 1000, 8);
  ledcAttach(ENB, 1000, 8);
#else
  ledcSetup(0, 1000, 8); ledcAttachPin(ENA, 0);
  ledcSetup(1, 1000, 8); ledcAttachPin(ENB, 1);
#endif
}
void pwmWrite(int ch, int pin, int duty) {
#if ESP_ARDUINO_VERSION_MAJOR >= 3
  ledcWrite(pin, duty);
#else
  ledcWrite(ch, duty);
#endif
}

void motor(int a, int b, int chan, int en, int v, bool inv) {
  if (inv) v = -v;
  if (v > 0)      { digitalWrite(a, HIGH); digitalWrite(b, LOW); }
  else if (v < 0) { digitalWrite(a, LOW);  digitalWrite(b, HIGH); }
  else            { digitalWrite(a, LOW);  digitalWrite(b, LOW); }
  pwmWrite(chan, en, abs(v));
}

void drive(int l, int r) {
  motor(IN1, IN2, 0, ENA, l, INVERT_LEFT);
  motor(IN3, IN4, 1, ENB, r, INVERT_RIGHT);
}

void setup() {
  Serial.begin(115200);
  pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);
  pwmInit();
  drive(0, 0);
  Dabble.begin("Terrri");
}

void loop() {
  Dabble.processInput();

  if (GamePad.isTrianglePressed()) speedLevel = SPEED_TRIANGLE;
  if (GamePad.isCirclePressed())   speedLevel = SPEED_CIRCLE;
  if (GamePad.isSquarePressed())   speedLevel = SPEED_SQUARE;
  if (GamePad.isCrossPressed())    speedLevel = SPEED_CROSS;

  bool up    = GamePad.isUpPressed();
  bool down  = GamePad.isDownPressed();
  bool left  = GamePad.isLeftPressed();
  bool right = GamePad.isRightPressed();

  int jx = GamePad.getXaxisData();
  int jy = GamePad.getYaxisData();

  int fwd = 0, turn = 0;   

  if (up || down || left || right) {
    if (up)    fwd  =  100;
    if (down)  fwd  = -100;
    if (right) turn =  100;
    if (left)  turn = -100;
  } else if (abs(jx) > 1 || abs(jy) > 1) {
    turn = constrain(jx * 100 / 7, -100, 100);
    fwd  = constrain(jy * 100 / 7, -100, 100);
  }

  int l = constrain(fwd + turn, -100, 100);
  int r = constrain(fwd - turn, -100, 100);
  drive(l * speedLevel / 100, r * speedLevel / 100);
}