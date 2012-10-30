const int LED_PIN = 13;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  //analogWriteでLEDをゆっくり明るくしていく
  for(int i=0; i < 1024; i++) {
    analogWrite(LED_PIN, i);
    delay(10);
  }
  delay(5000); //5秒待ち
  digitalWrite(LED_PIN,LOW); //LEDを消す
}

void loop() {
}

