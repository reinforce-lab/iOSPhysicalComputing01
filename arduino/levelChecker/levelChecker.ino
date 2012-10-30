/*
 * levelChecker.ino - OTOplug input signal level checker
 * Copyright (C) 2012 REINFORCE Lab. All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the MIT license.
 *
 */

//定義
#define LPF_TIME_CONST     10
#define FIXED_POINT_SHIFT  11
#define REPORT_PER_SAMPLES 2000
//変数
int loopCnt;
long int lpfSig;
int maxLevel;

void setup()
{
  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  //起動確認のためのスタートメッセージ
  Serial.println("OTOplug input signal level checker. ver1.0");
  Serial.println("Start:");
}

void loop()
{ 
  // アナログポートA0を読み込む
  int inputSignal = (long int)analogRead(A0);  
  
  // 振幅の平均値を取る。1次LPFをかける。
  long int diff;
  diff = ((long int)inputSignal << FIXED_POINT_SHIFT) - lpfSig;
  lpfSig += (diff >> LPF_TIME_CONST);

  if(inputSignal > maxLevel) {
    maxLevel = inputSignal;
  }
  
  loopCnt++;
  if(loopCnt > REPORT_PER_SAMPLES) {
    loopCnt=0;
    
    int averageLevel = (int)(lpfSig >> FIXED_POINT_SHIFT);
    
    Serial.print("Average level:");
    Serial.println(averageLevel, DEC);
    Serial.print("Amplitude:");
    Serial.print((maxLevel - averageLevel), DEC);
    Serial.println("");
    
    loopCnt  = 0;
    maxLevel = 0;
  }
  delay(1); //シリアルバッファをうめつくさないためのディレイ
}

