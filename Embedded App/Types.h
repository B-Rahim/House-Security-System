#pragma once

// constants won't change. They're used here to set pin numbers:
#define LED_PIN 13    //  LED pin
#define PAIR_BUTTON 7 //  Bluetooth paiting button pin
#define PWM_PIN 9     // Buzzer pin

#define ALARM_DURATION 5000
#define CYCLE_1 2700 // The PWM frequency will be 13MHz / 8 / (c1,c2) = (600,300)Hz
#define CYCLE_2 5400 // to have a siren like sound

//The finite state machine of system has 4 states
typedef enum
{
    S_IDLE,
    S_DETECT,
    S_ALARM,
    S_PAIR
} State;