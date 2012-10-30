/*
 * OTOsense_facedet_servo.ino - iPhone sensor shield base sketch
 * Copyright (C) 2012 REINFORCE Lab. All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the MIT license.
 *
 */

#include <Servo.h>
#include <OTOReceiver1200.h>

// ****
// 定義
// ****
#define SERIAL_DEBUG 0
#if SERIAL_DEBUG
#endif

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

//通信接続のタイムアウト。2秒以上パケットを受信しなければ、断絶とする。
#define DETECTION_TIME_OUT 2000
// サーボを接続するポート番号。左サーボは3ピン、右サーボは4ピン
const int L_CH = 3;
const int R_CH = 4;
// サーボのインスタンス
Servo l_servo;
Servo r_servo;
// サーボの位置を記録する変数
int l_servo_pos;
int r_servo_pos;
// 通信断絶を検出するための時間記録変数
unsigned long time;

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

  l_servo.attach(L_CH);
  r_servo.attach(R_CH);

  OTOReceiver1200.begin();
  OTOReceiver1200.attach(packetReceivedCallback);

  time = millis();
  l_servo_pos = 90;
  r_servo_pos = 90;
}

void loop()
{
  if(rcvLength == 0) {
    // 顔検出パケットが2秒以上届かなければ、初期状態に
    unsigned long now_time = millis();
    if((now_time - time) > DETECTION_TIME_OUT) {
      //切断の表情
      l_servo_pos = 90;
      r_servo_pos = 90;
    }
  } 
  else  {
    //顔検出パケット受信処理
    if(rcvBuf[0] == FACE_PACKET_ID) {
      //顔検出時間の更新
      time = millis();

      //顔検出の表情
      if(rcvBuf[1] == 0) {
        // 未検出時の表情
        l_servo_pos = 45;
        r_servo_pos = 135;
      } 
      else { 
        //検出時の表情
        l_servo_pos = 135;
        r_servo_pos = 45;
      }
    }

#if SERIAL_DEBUG
    packetDump(rcvBuf, rcvLength);
#endif

    rcvLength = 0;
  }

  //サーボ位置の更新
  l_servo.write(l_servo_pos);
  r_servo.write(r_servo_pos);
}





