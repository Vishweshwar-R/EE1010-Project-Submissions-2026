#include <LiquidCrystal.h>

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

const int sensorPin = A0;
const float Vcc = 4.70;        // Measured supply rail
const float R_fixed = 119.0;  // Measured reference resistor

void setup() {
  lcd.begin(16, 2);
}

void loop() {
  // 1. Oversample 16 readings
  long adcSum = 0;
  for (int i = 0; i < 16; i++) {
    adcSum += analogRead(sensorPin);
    delay(2);
  }
  float avgADC = (float)adcSum / 16.0;

  // 2. Voltage across PT100
  float X = avgADC * (Vcc / 1023.0);

  // 3. Calculated PT100 resistance: R_pt = R_fixed * (X / (Vcc - X))
  float R_pt = R_fixed * (X / (Vcc - X));

  // 4. Standard PT100 conversion (approx 0.3851 Ohms per °C)
  float tempC = (R_pt - 100.0) / 0.3851;

  // 5. Display Voltage and Resistance on line 1, Temp on line 2
  lcd.setCursor(0, 0);
  lcd.print("V:");
  lcd.print(X, 2);
  lcd.print("V R:");
  lcd.print(R_pt, 1);
  lcd.print((char)244); // Ohm symbol / alt code

  lcd.setCursor(0, 1);
  lcd.print("Temp: ");
  lcd.print(tempC, 1);
  lcd.print(" ");
  lcd.write(223);
  lcd.print("C   ");

  delay(400);
}