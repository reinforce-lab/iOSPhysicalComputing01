/*
 * OTOsense_switch_led.ino - iPhone sensor shield base sketch
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
// LEDを接続したデジタルポート
const int LED_PORT = 2;

void loop()
{ 
  //パケットがないときは、受信処理には進まない。
  if(rcvLength == 0) return;

  // パケットを受信していたら、以下の処理が実行される。
  // ボタン1が押されていたら、外部接続LEDを点灯する
  /*9つのLEDを制御するときは、このブロックをコメントにしてください*/
  /* このようにコメントアウトします */
  /*
  if(rcvBuf[0] == BUTTONS_PACKET_ID) {
    if(rcvBuf[1] & 0x01) {
      //ボタン1が押されていたら
      digitalWrite(LED_PORT, HIGH);
    } 
    else {
      //ボタン1が押されていなかったら
      digitalWrite(LED_PORT, LOW);
    }
  }
  */
  /*ここまで、コメントにする*/
  
  // もしもスイッチ1~8それぞれでピン毎にLEDを光らせるならば
  /* この部分のコメントを解除しています*/
  if(rcvBuf[0] == BUTTONS_PACKET_ID) {
    byte mask = 0x01;
    for(int i=0; i < 8; i++) {
      bool pinValue = (rcvBuf[1] & mask) != 0;
      digitalWrite(2 + i, pinValue);
      mask <<= 1;
    }
    digitalWrite(10, rcvBuf[2] != 0);
  }/* */

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



