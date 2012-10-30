/*
 * OTOsense_slider_blink.ino - iPhone sensor shield base sketch
 * Copyright (C) 2012 REINFORCE Lab. All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the MIT license.
 *
 */

#include <OTOReceiver1200.h>

// ****
// 定義
// ****
#define SERIAL_DEBUG 1
#if SERIAL_DEBUG
#endif

// ****
// 変数
// ****
uint8_t rcvBuf[MAX_PACKET_SIZE];
uint8_t rcvLength;
unsigned long delayTime;

// packet receiver method
void packetReceivedCallback(const uint8_t *buf, uint8_t length)
{
  if(length == 0 || rcvLength != 0) return;

  // copy buffer
  for(int i=0; i < length; i++) {
    rcvBuf[i] = buf[i];
  }
  rcvLength = length;
}

// packet dump 
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

void setup()
{
#if SERIAL_DEBUG
  Serial.begin(115200);
  Serial.println("Start:");
#endif

  for(int i = 2; i < 14; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }

  OTOReceiver1200.begin();
  OTOReceiver1200.attach(packetReceivedCallback);

  delayTime = 1000;
}

#define BUTTONS_PACKET_ID  0x01
#define SLIDEBAR_PACKET_ID 0x02
#define ACCS_PACKET_ID     0x03
#define GYRO_PACKET_ID     0x04
#define COMP_PACKET_ID     0x05
#define FACE_PACKET_ID     0x06

// マイコンボードのLEDポート
const int PORT13 = 13;
// LEDを接続したデジタルポート
const int LED_PORT = 2;

void loop()
{  
  //1回点滅
  digitalWrite(PORT13, HIGH);   //LEDを点灯する
  digitalWrite(LED_PORT, HIGH);
  delay(delayTime);             // delayTime遅延
  digitalWrite(PORT13, LOW);    // LEDを消す
  digitalWrite(LED_PORT, LOW);
  delay(delayTime);             // delayTime遅延

  // パケットを受信していなければ、ここでloop()関数を終わる。
  if(rcvLength == 0) return;

  //パケット受信処理。スライダー0番の値(0〜100)を5倍したものを遅延時間(0~500ミリ秒)とする。
  if(rcvBuf[0] == SLIDEBAR_PACKET_ID) {
    delayTime = rcvBuf[1] * 5;
  }
#if SERIAL_DEBUG
  packetDump(rcvBuf, rcvLength);
#endif
  rcvLength = 0;
}


