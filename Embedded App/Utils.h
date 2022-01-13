#pragma once

#include "GATTSUart.h"
#include <LBTServer.h>
#include <LGATTUUID.h>
#include <LGSM.h>

// flag for s the BLE status
extern bool bleOK;

//-- Interrupt Service Routine for intrusion Detection--//

void ISR();

//--------------- BLE helper Functions------------------//

void setupBLE();

void identifyUser(GATTSUart &uart);

//---------------SMS helper Functions------------------//

void setupSMS();

void sendSMS();

void checkSMS();

//--------------Buzzer helper Functions----------------//

void raiseAlarm(int cycle1, int cycle2, int pin);
