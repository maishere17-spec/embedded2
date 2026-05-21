 void PWM();
void ADC_Init();
unsigned int ADC_Read();
void Sonar_init();
unsigned int Sonar_read_right();
unsigned int Sonar_read_front();
void Move_forward(unsigned char L, unsigned char R);
void stop();
void msdelay(unsigned int ms);
void usdelay();
void servo_90();
void servo_pulse(unsigned int pulse_us);

unsigned char maze_mode = 0;
unsigned char tunnel_detected = 0;
unsigned int ldr_threshold = 300;

void main(){
    TRISD = 0x00;
    TRISB = 0xB5
    ;    // 0b10010101
                     // RB0 input (button)
                     // RB1 output (front TRIG)
                     // RB2 input  (front ECHO)
                     // RB4 input  (left IR)
                     // RB5 input  (right IR)
                     // RB6 output (right TRIG)
                     // RB7 input  (right ECHO)
    TRISC = 0x71;    // RC1 RC2 output (PWM)
                     // RC3 output (servo)
                     // rest input
    PORTC = 0x00;
    PORTD = 0x00;

    ADC_Init();
    Sonar_init();
    PWM();

    // --- wait for button press on RB0 (pull-up = HIGH, pressed = LOW) ---
    //while((PORTB & 0x01) != 0);
   // msdelay(3000);               // 3 second delay then start

    while(1){
        unsigned int ldr_val     = ADC_Read();
        unsigned int right_dis   = Sonar_read_right();
        unsigned int front_dis   = Sonar_read_front();
        unsigned char Right_sens = (PORTB & 0x20);   // RB5
        unsigned char Left_sens  = (PORTB & 0x10);   // RB4

        // --- LDR tunnel detection ---
        if(ldr_val > ldr_threshold && tunnel_detected == 0){
            tunnel_detected = 1;
            PORTC = PORTC | 0x80;    // buzzer ON = entered tunnel
        }

        if(ldr_val < ldr_threshold && tunnel_detected == 1){
            tunnel_detected = 0;
            maze_mode = 1;           // switch to maze
            PORTC = PORTC & 0x7F;    // buzzer OFF = exited tunnel
        }

        // --- line following mode ---
        if(maze_mode == 0){

            if(Left_sens == 0 && Right_sens == 0){
                Move_forward(0, 70);
                while(!(PORTB & 0x20));
                Move_forward(0, 0);
                msdelay(500);

            } else if(Left_sens == 0 && Right_sens != 0){
                Move_forward(0, 70);


            } else if(Left_sens != 0 && Right_sens == 0){
                Move_forward(70, 0);


            } else {
                Move_forward(70, 80);

            }

        // --- maze mode: wall following + parking detection ---
        } else {
                       //      Move_forward(0, 0);
                msdelay(100);


            // IR ONLY for parking detection
            if(Left_sens == 0 && Right_sens == 0){
                stop();
                servo_90();          // raise flag
                while(1);

            // front wall detected -> sharp left
            } else if(front_dis < 15){
                Move_forward(70, 20);
                msdelay(300);

            // too close to right wall -> steer left
            } /*else if(right_dis < 8){
                Move_forward(70, 35);
                msdelay(100);

            // too far from right wall -> steer right
            } else if(right_dis > 15){
                Move_forward(35, 70);
                msdelay(100);

            // sweet spot -> go straight
            } */else {
                Move_forward(60, 60);
                msdelay(150);
            }
        }
    }
}

void servo_pulse(unsigned int pulse_us){
    unsigned int i;
    PORTC = PORTC | 0x08;            // RC3 HIGH
    for(i = 0; i < pulse_us; i++){
        usdelay();
    }
    PORTC = PORTC & 0xF7;            // RC3 LOW
    for(i = 0; i < (2000 - pulse_us); i++){
        usdelay();
    }
}

void servo_90(){
    unsigned int cycles;
    for(cycles = 0; cycles < 50; cycles++){
        servo_pulse(150);            // 150 * 10us = 1500us = 90 degrees
    }
    while(1){
        servo_pulse(150);            // hold position forever
    }
}

void ADC_Init(){
    ADCON0 = 0x41;
    ADCON1 = 0x8E;
}

unsigned int ADC_Read(){
    ADCON0 = ADCON0 | 0x04;
    while(ADCON0 & 0x04);
    return ((ADRESH << 8) | ADRESL);
}

void Sonar_init(){
    // right sonar: RB6 output (TRIG), RB7 input (ECHO)
    TRISB = TRISB & 0xBF;
    TRISB = TRISB | 0x80;

    // front sonar: RB1 output (TRIG), RB2 input (ECHO)
    TRISB = TRISB & 0xFD;
    TRISB = TRISB | 0x04;
}

unsigned int Sonar_read_right(){
    unsigned int duration = 0;
    unsigned int timeout  = 0;

    PORTB = PORTB & 0xBF;           // right TRIG LOW  (RB6)
    msdelay(2);
    PORTB = PORTB | 0x40;           // right TRIG HIGH (RB6)
    usdelay();
    PORTB = PORTB & 0xBF;           // right TRIG LOW  (RB6)

    timeout = 0;
    while((PORTB & 0x80) == 0){     // wait ECHO HIGH (RB7)
        timeout++;
        if(timeout > 30000) return 500;
    }

    timeout = 0;
    while((PORTB & 0x80) != 0){     // count while ECHO HIGH
        duration++;
        usdelay();
        timeout++;
        if(timeout > 30000) return 500;
    }
    return (duration / 6);
}

unsigned int Sonar_read_front(){
    unsigned int duration = 0;
    unsigned int timeout  = 0;

    PORTB = PORTB & 0xFD;           // front TRIG LOW  (RB1)
    msdelay(2);
    PORTB = PORTB | 0x02;           // front TRIG HIGH (RB1)
    usdelay();
    PORTB = PORTB & 0xFD;           // front TRIG LOW  (RB1)

    timeout = 0;
    while((PORTB & 0x04) == 0){     // wait ECHO HIGH (RB2)
        timeout++;
        if(timeout > 30000) return 500;
    }

    timeout = 0;
    while((PORTB & 0x04) != 0){     // count while ECHO HIGH
        duration++;
        usdelay();
        timeout++;
        if(timeout > 30000) return 500;
    }
    return (duration / 6);
}

void usdelay(){
    unsigned char i;
    for(i = 0; i < 20; i++){
        asm NOP;
    }
}

void msdelay(unsigned int ms){
    unsigned int i, j;
    for(i = 0; i < ms; i++){
        for(j = 0; j < 332; j++){
            asm NOP;
        }
    }
}

void PWM(){
    T2CON   = 0x07;
    CCP1CON = 0x0C;
    CCP2CON = 0x0C;
    PR2     = 250;
    CCPR1L  = 0;
    CCPR2L  = 0;
}

void Move_forward(unsigned char L, unsigned char R){
    PORTD  = 0x05;
    CCPR1L = R;
    CCPR2L = L;
}

void stop(){
    PORTD  = 0x00;
    CCPR1L = 0;
    CCPR2L = 0;
}