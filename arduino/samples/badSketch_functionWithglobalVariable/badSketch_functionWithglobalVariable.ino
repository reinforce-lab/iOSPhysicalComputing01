const int LED_PIN = 13;
// LEDの点滅回数をきめるグローバル変数
int ledBlinkCount = 3;

// LEDを点滅させる
void blinkLED() { //点滅回数をグローバル変数で指定するので、引数がない
  for(int i=0; i < ledBlinkCount; i++) {
   digitalWrite(LED_PIN, HIGH);
   delay(200); 
  digitalWrite(LED_PIN, LOW);
   delay(200);
  } 
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  ledBlinkCount = 3;
}

void loop() {
  //関数の振る舞いが、引数ではなく、グローバル変数で決まる。
  //はじめてスケッチを見た人は、blinkLED()関数の中身まで読まないと、それがわからない。
  blinkLED(); 
              
  // もしもここでledBlinkCountを変更してしまうと、点滅回数が変わってしまう。
  ledBlinkCount = 1; //点滅1回になってしまう。
  delay(1000);
}

