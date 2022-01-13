
#include "GATTSUart.h"
#include <LBTServer.h>
#include <LGATTUUID.h>
#include <LGSM.h>
#include "Types.h"

void ISR();
extern char contact[20];
extern char RdWr;
extern volatile State state;

bool bleOK = false;

//----------- BLE helper Functions---------------//

void setupBLE()
{
    //Serial initialization
    Serial.println("BLE app started");

    //BT initialization
    const char *deviceName = "PSESI_SAFE";
    bool success = LBTServer.begin((uint8_t *)deviceName);
    delay(500);
    if (success)
    {
        //Disconnecting BT for opening BLE.
        LBTServer.end();
        bleOK = true;
    }
    else
    {
        LBTServer.end();
        Serial.println("[FAILED] BT config successfully");
    }
}

void identifyUser(GATTSUart &uart)
{
    Serial.println("in pairing");

    if (!LGATTServer.begin(1, &uart))
    {
        Serial.println("[FAILED] GATTS begin");
        return;
    }

    uint32_t interval = 30000; // give 30s for the user to authenticate
    uint32_t start = millis();
    Serial.println("GATTS begin");

    //  This loop handles events for Bluetooth 4.0
    // and process all the requests that have been added to the event queue
    while ((millis() - start < interval) && uart.isConnected())
    {
        LGATTServer.handleEvents();
        delay(1000);
    }
    LGATTServer.end();
}

//-------------SMS helper Functions---------------//

void setupSMS()
{
    attachInterrupt(0, ISR, FALLING);
    Serial.println("Initialize GSM for SMS");
    while (!LSMS.ready())
    {
        delay(1000);
        Serial.println(".");
    }
    Serial.println("GSM ready for sending SMS");
    state = S_IDLE;
}

void sendSMS()
{
    LSMS.beginSMS(contact);
    LSMS.print("Intrusion detected!");
    if (LSMS.endSMS())
        Serial.println("SMS successfully sent");
    else
        Serial.println("SMS failed to send");
}

void checkSMS()
{
    char buf[20];
    int v;
    if (!LSMS.available()) // Check if there is new SMS
        return;

    Serial.println("There is new message.");
    LSMS.remoteNumber(buf, 20); // display Number part
    Serial.print("Number:");
    Serial.println(buf);

    Serial.print("Content:"); // display Content part
    while (true)
    {
        v = LSMS.read();
        if (v < 0)
            break;
        Serial.print((char)v);
    }
    Serial.println();
    LSMS.flush();
}

//-------------Buzzer helper Functions---------------//

void raiseAlarm(int c1, int c2, int pin)
{
    int cycle = c1;
    uint32_t start = millis();
    while ((millis() - start) < ALARM_DURATION)
    {
        cycle = cycle == c1 ? c2 : c1;
        analogWriteAdvance(pin, PWM_SOURCE_CLOCK_13MHZ, PWM_CLOCK_DIV8, cycle, 50);
        delay(200);
    }
    analogWriteAdvance(pin, PWM_SOURCE_CLOCK_13MHZ, PWM_CLOCK_DIV8, cycle, 0);
}
