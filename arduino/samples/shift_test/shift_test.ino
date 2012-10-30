/*
 * shift_test.ino
 * Copyright (C) 2012 REINFORCE Lab. All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the MIT license.
 *
 */

void setup()
{
  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  //起動確認のためのスタートメッセージ
  Serial.println("Shift test, Start:");
}

void loop()
{ 
  int8_t  v1;//符号あり変数
  uint8_t v2;//符号なし変数
 

  //符号あり変数の左シフト
  v1 = 0x01;
  Serial.println("Left shift of a signed variable.");
  for(int i=0; i < 8; i++) {
    Serial.println(v1,BIN);
    v1 = v1 << 1; //左シフト
  }
  //符号なし変数の左シフト
  v2 = 0x01;
  Serial.println("Left shift of a unsigned variable.");
  for(int i=0; i < 8; i++) {
    Serial.println(v2,BIN);
    v2 = v2 << 1; //左シフト
  }
   //符号あり変数の右シフト
  v1 = 0x80;
  Serial.println("Right shift of a signed variable.");
  for(int i=0; i < 8; i++) {
    Serial.println(v1,BIN);
    v1  = v1 >> 1; //右シフト
  }
  //符号なし変数の右シフト
  v2 = 0x80;
  Serial.println("Right shift of a unsigned variable.");
  for(int i=0; i < 8; i++) {
    Serial.println(v2,BIN);
    v2 = v2 >> 1; //右シフト
  }
  
  Serial.println("");
  delay(5000); //5秒待ち
}

