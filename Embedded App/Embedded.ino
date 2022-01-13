#include "Utils.h"
#include "Types.h"

GATTSUart uart; //This is the UART profile for the BLE.

volatile State state;

void ISR()
{
    state = S_DETECT;
}

void setup()
{
    pinMode(PWM_PIN, OUTPUT);
    pinMode(LED_PIN, OUTPUT);
    pinMode(PAIR_BUTTON, INPUT);
    Serial.begin(9600);
    setupSMS();
    setupBLE();
}

void loop()
{
    switch (state)
    {
    case S_IDLE:
        if (digitalRead(PAIR_BUTTON) == LOW && bleOK)
            state = S_PAIR;
        checkSMS();
        break;

    case S_DETECT:
        noInterrupts();
        digitalWrite(LED_PIN, HIGH);
        sendSMS();
        digitalWrite(LED_PIN, LOW);
        state = S_ALARM;
        break;

    case S_ALARM:
        raiseAlarm(CYCLE_1, CYCLE_2, PWM_PIN);
        interrupts(); // re-enabling the intrrupt
        state = S_IDLE;
        break;

    case S_PAIR:
        identifyUser(uart);
        state = S_IDLE;
        break;
    }
    delay(100); // For energy efficiency
}
