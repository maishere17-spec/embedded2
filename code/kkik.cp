#line 1 "C:/Users/maish/Downloads/embedded-robot-project/kkik.c"
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
 ;







 TRISC = 0x71;


 PORTC = 0x00;
 PORTD = 0x00;

 ADC_Init();
 Sonar_init();
 PWM();





 while(1){
 unsigned int ldr_val = ADC_Read();
 unsigned int right_dis = Sonar_read_right();
 unsigned int front_dis = Sonar_read_front();
 unsigned char Right_sens = (PORTB & 0x20);
 unsigned char Left_sens = (PORTB & 0x10);


 if(ldr_val > ldr_threshold && tunnel_detected == 0){
 tunnel_detected = 1;
 PORTC = PORTC | 0x80;
 }

 if(ldr_val < ldr_threshold && tunnel_detected == 1){
 tunnel_detected = 0;
 maze_mode = 1;
 PORTC = PORTC & 0x7F;
 }


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


 } else {

 msdelay(100);



 if(Left_sens == 0 && Right_sens == 0){
 stop();
 servo_90();
 while(1);


 } else if(front_dis < 15){
 Move_forward(70, 20);
 msdelay(300);
#line 112 "C:/Users/maish/Downloads/embedded-robot-project/kkik.c"
 } else {
 Move_forward(60, 60);
 msdelay(150);
 }
 }
 }
}

void servo_pulse(unsigned int pulse_us){
 unsigned int i;
 PORTC = PORTC | 0x08;
 for(i = 0; i < pulse_us; i++){
 usdelay();
 }
 PORTC = PORTC & 0xF7;
 for(i = 0; i < (2000 - pulse_us); i++){
 usdelay();
 }
}

void servo_90(){
 unsigned int cycles;
 for(cycles = 0; cycles < 50; cycles++){
 servo_pulse(150);
 }
 while(1){
 servo_pulse(150);
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

 TRISB = TRISB & 0xBF;
 TRISB = TRISB | 0x80;


 TRISB = TRISB & 0xFD;
 TRISB = TRISB | 0x04;
}

unsigned int Sonar_read_right(){
 unsigned int duration = 0;
 unsigned int timeout = 0;

 PORTB = PORTB & 0xBF;
 msdelay(2);
 PORTB = PORTB | 0x40;
 usdelay();
 PORTB = PORTB & 0xBF;

 timeout = 0;
 while((PORTB & 0x80) == 0){
 timeout++;
 if(timeout > 30000) return 500;
 }

 timeout = 0;
 while((PORTB & 0x80) != 0){
 duration++;
 usdelay();
 timeout++;
 if(timeout > 30000) return 500;
 }
 return (duration / 6);
}

unsigned int Sonar_read_front(){
 unsigned int duration = 0;
 unsigned int timeout = 0;

 PORTB = PORTB & 0xFD;
 msdelay(2);
 PORTB = PORTB | 0x02;
 usdelay();
 PORTB = PORTB & 0xFD;

 timeout = 0;
 while((PORTB & 0x04) == 0){
 timeout++;
 if(timeout > 30000) return 500;
 }

 timeout = 0;
 while((PORTB & 0x04) != 0){
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
 T2CON = 0x07;
 CCP1CON = 0x0C;
 CCP2CON = 0x0C;
 PR2 = 250;
 CCPR1L = 0;
 CCPR2L = 0;
}

void Move_forward(unsigned char L, unsigned char R){
 PORTD = 0x05;
 CCPR1L = R;
 CCPR2L = L;
}

void stop(){
 PORTD = 0x00;
 CCPR1L = 0;
 CCPR2L = 0;
}
