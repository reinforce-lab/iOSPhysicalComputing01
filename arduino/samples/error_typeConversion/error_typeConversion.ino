void setup() {
  // シリアルコンソールを使うための設定
  Serial.begin(115200);
}

void loop() {
   // int型の変数をbyte型に代入
  int  i = 1025;
  byte b = (byte)i;
  
   // シリアルコンソールに出力
  Serial.print("int i:");
  Serial.println(i, DEC);
  Serial.print("byte b: ");
  Serial.println(b, DEC);
  Serial.println("");
  
  delay(3000);
}



