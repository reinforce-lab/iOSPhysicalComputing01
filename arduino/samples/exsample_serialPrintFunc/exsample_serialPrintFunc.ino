/* http://arduino.cc/en/Serial/Print のサンプルスケッチを日本語訳したものです。 */

void setup() {
  Serial.begin(115200); //シリアル・ポートを115200bpsで開く。
  while(!Serial){};   // シリアル・ポートの準備完了を待つ。Arduino leonardoのために必要。
}

void loop() {  
  // print labels 
  Serial.print("NO FORMAT"); //文字列をシリアルコンソールに出力する。
  Serial.print("\t");        //タブ文字は特殊な文字で、"バックスラッシュ+t"で指定する。
                             //Macでは、バックスラッシュは option+¥ で入力できる。
  Serial.print("DEC");  
  Serial.print("\t");      

  Serial.print("HEX"); 
  Serial.print("\t");   

  Serial.print("OCT");
  Serial.print("\t");

  Serial.println("BIN"); //println()関数は、print()関数と動作は同じで、最後に改行を出力する。

  for(int x=33; x< 127; x++){  
    // ASC文字コードを、文字、10進、16進、8進、2進数で表示する。印字可能な範囲(0x21~0x7e)の文字を印字する。
    Serial.print((char)x); // 文字を表示する。char型に型変換をしている。
    Serial.print("\t");    // タブ文字を印字する

    Serial.print(x, DEC);  // 10進数で表示する
    Serial.print("\t");    // タブ文字を印字する

    Serial.print(x, HEX);  // 16進数表記
    Serial.print("\t");    // タブ文字を印字する

    Serial.print(x, OCT);  // 8進数表記
    Serial.print("\t");    // タブ文字を印字する

    Serial.println(x, BIN);  // 2進数で表示。println()関数は、print()関数と動作は同じで、最後に改行を出力する。
   
    delay(200);            // 200ミリ秒の遅延
  }
  Serial.println("");      // 空白行を入れる。
}

