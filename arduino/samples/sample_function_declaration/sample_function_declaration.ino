const int LED_PIN = 13;

//Arduino IDEではコンパイラはエラーしか表示しない。
//マイコン開発では、コンパイラはワーニングを出す。
//関数呼び出しが正しいか否かを、コンパイラが判断できるように、
//関数呼び出しより関数が後ろに書かれているなら、
//関数の引数と返り値がなにかを、コンパイラに伝えるために、ソース冒頭に関数宣言を書いておく。
void blinkLED(const int blinkCount);

void setup() {
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
   blinkLED(3); //”なにをしているか”が関数の名前と引数だけで分かる
  delay(1000);
}

// LEDの点滅処理を関数にまとめる。点滅回数を引数で与える。
void blinkLED(const int blinkCount) {
  for(int i=0; i < blinkCount; i++) {
   digitalWrite(LED_PIN, HIGH);
   delay(200); 
  digitalWrite(LED_PIN, LOW);
   delay(200);
  } 
}

