#pragma once

// Macros used to set pin numbers:
#define LED_PIN 13    //  LED pin
#define PAIR_BUTTON 7 //  Bluetooth paiting button pin
#define PWM_PIN 9     // Buzzer pin

#define ALARM_DURATION 5000
#define CYCLE_1 2700 // The PWM frequency will be 13MHz / 8 / (c1,c2) = (600,300)Hz
#define CYCLE_2 5400 // to have a siren like sound

//The finite state machine of the program has 4 states 
// that define the behaviour of the system

typedef enum
{
    S_IDLE,
    S_DETECT,
    S_ALARM,
    S_PAIR
} State;
