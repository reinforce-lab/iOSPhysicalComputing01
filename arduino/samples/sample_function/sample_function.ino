const int LED_PIN = 13;

// LEDの点滅処理を関数にまとめる。点滅回数を引数で与える。
void blinkLED(const int blinkCount) {
  for(int i=0; i < blinkCount; i++) {
   digitalWrite(LED_PIN, HIGH);
   delay(200); 
  digitalWrite(LED_PIN, LOW);
   delay(200);
  } 
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
   blinkLED(3); //”なにをしているか”が関数の名前と引数だけで分かる
  delay(1000);
}

