/*
 * OTOsense_switch_led3.ino - iPhone sensor shield base sketch
 * Copyright (C) 2012 REINFORCE Lab. All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the MIT license.
 *
 */
//インクルードファイル。
//OTOReceiver1200のライブラリを使うために、定義などの情報が入っているヘッダファイルを、読み込む。
#include <OTOReceiver1200.h>

// ****
// 定義
// ****
//iPhoneから受信したパケットを、シリアルコンソールに表示したい時は、1を、表示しないときは、0を、定義する。
#define SERIAL_DEBUG 1

// ****
// 変数
// ****
//パケット受信バッファ
uint8_t rcvBuf[MAX_PACKET_SIZE];
uint8_t rcvLength;

// パケット受信時のコールバック関数
void packetReceivedCallback(const uint8_t *buf, uint8_t length)
{
  if(length == 0 || rcvLength != 0) return;

  // copy buffer
  for(int i=0; i < length; i++) {
    rcvBuf[i] = buf[i];
  }
  rcvLength = length;
}

// デバッグ用の、パケットをシリアルコンソールにダンプする関数
#if SERIAL_DEBUG
void packetDump(const uint8_t *buf, uint8_t length)
{  
  Serial.print("Packet(len:");
  Serial.print(length, DEC);
  Serial.print(")");

  for(int i=0; i < length; i++) {
    Serial.print(", ");
    Serial.print(buf[i], HEX);
  }
  Serial.println("");
}
#endif

//セットアップ関数。実行開始時に1度だけ喚ばれる。
void setup()
{
#if SERIAL_DEBUG
  Serial.begin(115200);
  Serial.println("Start:");
#endif

  //デジタルポートは出力に設定する
  for(int i = 2; i < 14; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }

  //OTOReceiver1200のライブラリ初期化と、コールバック関数の設定
  OTOReceiver1200.begin();
  OTOReceiver1200.attach(packetReceivedCallback);
}

// パケット種別を表すID番号の定義。
// 本来はこのファイルの上、定数定義のあたりに書くのがC言語では普通だが、読みやすさのため、ここに書いた。
#define BUTTONS_PACKET_ID  0x01
#define SLIDEBAR_PACKET_ID 0x02
#define ACCS_PACKET_ID     0x03
#define GYRO_PACKET_ID     0x04
#define COMP_PACKET_ID     0x05
#define FACE_PACKET_ID     0x06

// マイコンボードにあるLEDポート
const int PORT13 = 13;

void loop()
{ 
  //パケットがないときは、受信処理には進まない。
  if(rcvLength == 0) return;

  // パケットを受信していたら、以下の処理が実行される。

  // もしもスイッチ1~8それぞれでピン毎にLEDを光らせるならば
  if(rcvBuf[0] == BUTTONS_PACKET_ID) {
    // ボタン1のLED表示 
    if((rcvBuf[1] & 0x01) != 0) { //0x01をマスクにして、最下位ビットを取り出す。
       digitalWrite(2, HIGH); //ビット1ならHIGHを書き込む
     } else {
       digitalWrite(2, LOW); //ビット0ならLOWを書き込む
     }
       
       // ボタン2のLED表示、
    if((rcvBuf[1] & 0x02) != 0) { //マスクが0x01から0x02になっている。次のビットをみている。
       digitalWrite(3, HIGH); 
     } else {
       digitalWrite(3, LOW); 
     }
     
       // ボタン3のLED表示 
    if((rcvBuf[1] & 0x04) == 0) { //if文は、等号、不等号などの演算子を組み合わせて使える
       digitalWrite(4, LOW); //ビットが0のとき、ここが実行される。演算子が"=="になったので、ボタン1のときと位置が逆になる。
     } else {
       digitalWrite(4, HIGH);
     }
   
       // ボタン4のLED表示 
    if(rcvBuf[1] & 0x08) { //C言語のif文は、数値が0か0以外で条件判定をしている
       digitalWrite(5, HIGH);//ビットが1だと、0x08との論理積は0ではないので、これが実行される
     } else {
       digitalWrite(5, LOW); //ビットが0だと、0x08との論理積は0なので、これが実行される。
     }
     
      // ボタン5のLED表示 
    if((rcvBuf[1] & 0x10) != 0) {
       digitalWrite(6, HIGH);
     } else {
       digitalWrite(6, LOW);
     }
     
       // ボタン6のLED表示 
    if((rcvBuf[1] & 0x20) != 0) {
       digitalWrite(7, HIGH);
     } else {
       digitalWrite(7, LOW);
     }
  
  /*
  本書では説明を省いたが、こんな書き方もできる。
  C言語の演算結果は、bool型という真/偽を表す変数型だが、その実体は数値になっている。
  bool型変数を数値としてみると、論理の真は0以外の値(たいていは1)、偽は0になる。
  また、HIGHは1、LOWは0に定義されているので、論理演算の結果を、数値としてdigitalWrite()に渡すこともできる。
  
  bool型の変数を数値として扱うのは、C#やJavaなどの最近の言語では、言語自体がそれを禁止している。
  例えば、bool b = true;
  if(b == 1) {
  }
  というコードを書いた時、もしも論理真が'1'ではないコンパイラがあれば、if文は実行されません。
  bool型変数を、数値として扱うと、見た目が簡素で、一見かっこいいコードになるのですが、
  その意味をよく理解していないと"とてもわかりにっくい"バグを生み出します。  
  */
       // ボタン7のLED表示 
    digitalWrite(8, (rcvBuf[1] & 0x40) != 0);
  
       // ボタン8のLED表示 
    digitalWrite(9, (rcvBuf[1] & 0x80));
     
    digitalWrite(10, rcvBuf[2] != 0);
  }

  //何か1つでもボタンが押されていたら、マイコンボード搭載のLEDを光らせる
  if(rcvBuf[0] == BUTTONS_PACKET_ID) {
    if(rcvBuf[1] | rcvBuf[2]) {
      digitalWrite(PORT13, HIGH);
    } 
    else {
      digitalWrite(PORT13, LOW);
    }
  }
//デバッグ用のダンプ関数呼び出し
#if SERIAL_DEBUG
  packetDump(rcvBuf, rcvLength);
#endif
  rcvLength = 0;
}



