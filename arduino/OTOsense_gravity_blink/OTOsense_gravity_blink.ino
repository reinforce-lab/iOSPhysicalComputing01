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

// ****
// 変数
// ****
uint8_t rcvBuf[MAX_PACKET_SIZE];
uint8_t rcvLength;

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

#define BUTTONS_PACKET_ID  0x01
#define SLIDEBAR_PACKET_ID 0x02
#define ACCS_PACKET_ID     0x03
#define GYRO_PACKET_ID     0x04
#define COMP_PACKET_ID     0x05
#define FACE_PACKET_ID     0x06

// LEDポート。左を_L, 真ん中を_C, 右を_R、の添字で表す。
const int LED_L = 2;
const int LED_C = 3;
const int LED_R = 4;
#define TIME_OUT 2000

unsigned long lastPacketReceivedAt;

void setup()
{
#if SERIAL_DEBUG
  Serial.begin(115200);
  Serial.println("Start:");
#endif

  for(int i = 2; i < 5; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }

  OTOReceiver1200.begin();
  OTOReceiver1200.attach(packetReceivedCallback);

  //パケット通信断絶検出のための、最終受信時刻の記録
  lastPacketReceivedAt = millis();
}

void loop()
{  
  if(rcvLength == 0) {  //断絶検出処理
    unsigned long nowTime = millis();
    //通信断絶->LEDを全て点灯  
    if((nowTime - lastPacketReceivedAt) > TIME_OUT) {
      //ここのポート番号指定は、マジックワードでよくないが、LED_L, _C, _Rの数の大小関係がわからないから、数字で直接書く
      for(int i = 2; i < 5; i++) {
        digitalWrite(i, HIGH);
      } 
    }  
  } 
  else {
    //パケット受信時刻を更新
    lastPacketReceivedAt = millis();
    //加速度センサーのパケットかどうかを判別
    if(rcvBuf[0] == ACCS_PACKET_ID) {
      //真ん中、左、右
      float x_acs = (float)((int8_t)rcvBuf[1]);
      float z_acs = (float)((int8_t)rcvBuf[3]);

      /* デバッグ用の加速度ダンプ
       #if SERIAL_DEBUG
       Serial.print("x_acs:");
       Serial.println(x_acs, 2);
       Serial.print(" z_acs:");
       Serial.println(z_acs, 2);
       #endif
       */
      //tan(30度) = 0.577, tan(45度) = 1.0, tan(60度) = 1.73
      // 60度以上の傾きを検出する
      if( abs(z_acs) > 1.73 * abs(x_acs)) { //真ん中
        digitalWrite(LED_L, LOW);
        digitalWrite(LED_C, HIGH);
        digitalWrite(LED_R, LOW);
      } 
      else { //左か右に傾いている
        if(x_acs > 0) { //右に傾いている
          digitalWrite(LED_L, LOW);
          digitalWrite(LED_C, LOW);
          digitalWrite(LED_R, HIGH);
        } 
        else { //左に傾いている
          digitalWrite(LED_L, HIGH);
          digitalWrite(LED_C, LOW);
          digitalWrite(LED_R, LOW);
        }
      }
    }
#if SERIAL_DEBUG
    packetDump(rcvBuf, rcvLength);
#endif
    rcvLength = 0;
  }
}





