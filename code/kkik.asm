
_main:

;kkik.c,18 :: 		void main(){
;kkik.c,19 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;kkik.c,20 :: 		TRISB = 0xB5
	MOVLW      181
	MOVWF      TRISB+0
;kkik.c,29 :: 		TRISC = 0x71;    // RC1 RC2 output (PWM)
	MOVLW      113
	MOVWF      TRISC+0
;kkik.c,32 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;kkik.c,33 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;kkik.c,35 :: 		ADC_Init();
	CALL       _ADC_Init+0
;kkik.c,36 :: 		Sonar_init();
	CALL       _Sonar_init+0
;kkik.c,37 :: 		PWM();
	CALL       _PWM+0
;kkik.c,43 :: 		while(1){
L_main0:
;kkik.c,44 :: 		unsigned int ldr_val     = ADC_Read();
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      main_ldr_val_L1+0
	MOVF       R0+1, 0
	MOVWF      main_ldr_val_L1+1
;kkik.c,45 :: 		unsigned int right_dis   = Sonar_read_right();
	CALL       _Sonar_read_right+0
;kkik.c,46 :: 		unsigned int front_dis   = Sonar_read_front();
	CALL       _Sonar_read_front+0
	MOVF       R0+0, 0
	MOVWF      main_front_dis_L1+0
	MOVF       R0+1, 0
	MOVWF      main_front_dis_L1+1
;kkik.c,47 :: 		unsigned char Right_sens = (PORTB & 0x20);   // RB5
	MOVLW      32
	ANDWF      PORTB+0, 0
	MOVWF      main_Right_sens_L1+0
;kkik.c,48 :: 		unsigned char Left_sens  = (PORTB & 0x10);   // RB4
	MOVLW      16
	ANDWF      PORTB+0, 0
	MOVWF      main_Left_sens_L1+0
;kkik.c,51 :: 		if(ldr_val > ldr_threshold && tunnel_detected == 0){
	MOVF       main_ldr_val_L1+1, 0
	SUBWF      _ldr_threshold+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main73
	MOVF       main_ldr_val_L1+0, 0
	SUBWF      _ldr_threshold+0, 0
L__main73:
	BTFSC      STATUS+0, 0
	GOTO       L_main4
	MOVF       _tunnel_detected+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main4
L__main71:
;kkik.c,52 :: 		tunnel_detected = 1;
	MOVLW      1
	MOVWF      _tunnel_detected+0
;kkik.c,53 :: 		PORTC = PORTC | 0x80;    // buzzer ON = entered tunnel
	BSF        PORTC+0, 7
;kkik.c,54 :: 		}
L_main4:
;kkik.c,56 :: 		if(ldr_val < ldr_threshold && tunnel_detected == 1){
	MOVF       _ldr_threshold+1, 0
	SUBWF      main_ldr_val_L1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main74
	MOVF       _ldr_threshold+0, 0
	SUBWF      main_ldr_val_L1+0, 0
L__main74:
	BTFSC      STATUS+0, 0
	GOTO       L_main7
	MOVF       _tunnel_detected+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main7
L__main70:
;kkik.c,57 :: 		tunnel_detected = 0;
	CLRF       _tunnel_detected+0
;kkik.c,58 :: 		maze_mode = 1;           // switch to maze
	MOVLW      1
	MOVWF      _maze_mode+0
;kkik.c,59 :: 		PORTC = PORTC & 0x7F;    // buzzer OFF = exited tunnel
	MOVLW      127
	ANDWF      PORTC+0, 1
;kkik.c,60 :: 		}
L_main7:
;kkik.c,63 :: 		if(maze_mode == 0){
	MOVF       _maze_mode+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main8
;kkik.c,65 :: 		if(Left_sens == 0 && Right_sens == 0){
	MOVF       main_Left_sens_L1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main11
	MOVF       main_Right_sens_L1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main11
L__main69:
;kkik.c,66 :: 		Move_forward(0, 70);
	CLRF       FARG_Move_forward_L+0
	MOVLW      70
	MOVWF      FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,67 :: 		while(!(PORTB & 0x20));
L_main12:
	BTFSC      PORTB+0, 5
	GOTO       L_main13
	GOTO       L_main12
L_main13:
;kkik.c,68 :: 		Move_forward(0, 0);
	CLRF       FARG_Move_forward_L+0
	CLRF       FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,69 :: 		msdelay(500);
	MOVLW      244
	MOVWF      FARG_msdelay_ms+0
	MOVLW      1
	MOVWF      FARG_msdelay_ms+1
	CALL       _msdelay+0
;kkik.c,71 :: 		} else if(Left_sens == 0 && Right_sens != 0){
	GOTO       L_main14
L_main11:
	MOVF       main_Left_sens_L1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main17
	MOVF       main_Right_sens_L1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main17
L__main68:
;kkik.c,72 :: 		Move_forward(0, 70);
	CLRF       FARG_Move_forward_L+0
	MOVLW      70
	MOVWF      FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,75 :: 		} else if(Left_sens != 0 && Right_sens == 0){
	GOTO       L_main18
L_main17:
	MOVF       main_Left_sens_L1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main21
	MOVF       main_Right_sens_L1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main21
L__main67:
;kkik.c,76 :: 		Move_forward(70, 0);
	MOVLW      70
	MOVWF      FARG_Move_forward_L+0
	CLRF       FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,79 :: 		} else {
	GOTO       L_main22
L_main21:
;kkik.c,80 :: 		Move_forward(70, 80);
	MOVLW      70
	MOVWF      FARG_Move_forward_L+0
	MOVLW      80
	MOVWF      FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,82 :: 		}
L_main22:
L_main18:
L_main14:
;kkik.c,85 :: 		} else {
	GOTO       L_main23
L_main8:
;kkik.c,87 :: 		msdelay(100);
	MOVLW      100
	MOVWF      FARG_msdelay_ms+0
	MOVLW      0
	MOVWF      FARG_msdelay_ms+1
	CALL       _msdelay+0
;kkik.c,91 :: 		if(Left_sens == 0 && Right_sens == 0){
	MOVF       main_Left_sens_L1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main26
	MOVF       main_Right_sens_L1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main26
L__main66:
;kkik.c,92 :: 		stop();
	CALL       _stop+0
;kkik.c,93 :: 		servo_90();          // raise flag
	CALL       _servo_90+0
;kkik.c,94 :: 		while(1);
L_main27:
	GOTO       L_main27
;kkik.c,97 :: 		} else if(front_dis < 15){
L_main26:
	MOVLW      0
	SUBWF      main_front_dis_L1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main75
	MOVLW      15
	SUBWF      main_front_dis_L1+0, 0
L__main75:
	BTFSC      STATUS+0, 0
	GOTO       L_main30
;kkik.c,98 :: 		Move_forward(70, 20);
	MOVLW      70
	MOVWF      FARG_Move_forward_L+0
	MOVLW      20
	MOVWF      FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,99 :: 		msdelay(300);
	MOVLW      44
	MOVWF      FARG_msdelay_ms+0
	MOVLW      1
	MOVWF      FARG_msdelay_ms+1
	CALL       _msdelay+0
;kkik.c,112 :: 		} */else {
	GOTO       L_main31
L_main30:
;kkik.c,113 :: 		Move_forward(60, 60);
	MOVLW      60
	MOVWF      FARG_Move_forward_L+0
	MOVLW      60
	MOVWF      FARG_Move_forward_R+0
	CALL       _Move_forward+0
;kkik.c,114 :: 		msdelay(150);
	MOVLW      150
	MOVWF      FARG_msdelay_ms+0
	CLRF       FARG_msdelay_ms+1
	CALL       _msdelay+0
;kkik.c,115 :: 		}
L_main31:
;kkik.c,116 :: 		}
L_main23:
;kkik.c,117 :: 		}
	GOTO       L_main0
;kkik.c,118 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_servo_pulse:

;kkik.c,120 :: 		void servo_pulse(unsigned int pulse_us){
;kkik.c,122 :: 		PORTC = PORTC | 0x08;            // RC3 HIGH
	BSF        PORTC+0, 3
;kkik.c,123 :: 		for(i = 0; i < pulse_us; i++){
	CLRF       servo_pulse_i_L0+0
	CLRF       servo_pulse_i_L0+1
L_servo_pulse32:
	MOVF       FARG_servo_pulse_pulse_us+1, 0
	SUBWF      servo_pulse_i_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__servo_pulse77
	MOVF       FARG_servo_pulse_pulse_us+0, 0
	SUBWF      servo_pulse_i_L0+0, 0
L__servo_pulse77:
	BTFSC      STATUS+0, 0
	GOTO       L_servo_pulse33
;kkik.c,124 :: 		usdelay();
	CALL       _usdelay+0
;kkik.c,123 :: 		for(i = 0; i < pulse_us; i++){
	INCF       servo_pulse_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       servo_pulse_i_L0+1, 1
;kkik.c,125 :: 		}
	GOTO       L_servo_pulse32
L_servo_pulse33:
;kkik.c,126 :: 		PORTC = PORTC & 0xF7;            // RC3 LOW
	MOVLW      247
	ANDWF      PORTC+0, 1
;kkik.c,127 :: 		for(i = 0; i < (2000 - pulse_us); i++){
	CLRF       servo_pulse_i_L0+0
	CLRF       servo_pulse_i_L0+1
L_servo_pulse35:
	MOVF       FARG_servo_pulse_pulse_us+0, 0
	SUBLW      208
	MOVWF      R1+0
	MOVF       FARG_servo_pulse_pulse_us+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      7
	MOVWF      R1+1
	MOVF       R1+1, 0
	SUBWF      servo_pulse_i_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__servo_pulse78
	MOVF       R1+0, 0
	SUBWF      servo_pulse_i_L0+0, 0
L__servo_pulse78:
	BTFSC      STATUS+0, 0
	GOTO       L_servo_pulse36
;kkik.c,128 :: 		usdelay();
	CALL       _usdelay+0
;kkik.c,127 :: 		for(i = 0; i < (2000 - pulse_us); i++){
	INCF       servo_pulse_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       servo_pulse_i_L0+1, 1
;kkik.c,129 :: 		}
	GOTO       L_servo_pulse35
L_servo_pulse36:
;kkik.c,130 :: 		}
L_end_servo_pulse:
	RETURN
; end of _servo_pulse

_servo_90:

;kkik.c,132 :: 		void servo_90(){
;kkik.c,134 :: 		for(cycles = 0; cycles < 50; cycles++){
	CLRF       servo_90_cycles_L0+0
	CLRF       servo_90_cycles_L0+1
L_servo_9038:
	MOVLW      0
	SUBWF      servo_90_cycles_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__servo_9080
	MOVLW      50
	SUBWF      servo_90_cycles_L0+0, 0
L__servo_9080:
	BTFSC      STATUS+0, 0
	GOTO       L_servo_9039
;kkik.c,135 :: 		servo_pulse(150);            // 150 * 10us = 1500us = 90 degrees
	MOVLW      150
	MOVWF      FARG_servo_pulse_pulse_us+0
	CLRF       FARG_servo_pulse_pulse_us+1
	CALL       _servo_pulse+0
;kkik.c,134 :: 		for(cycles = 0; cycles < 50; cycles++){
	INCF       servo_90_cycles_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       servo_90_cycles_L0+1, 1
;kkik.c,136 :: 		}
	GOTO       L_servo_9038
L_servo_9039:
;kkik.c,137 :: 		while(1){
L_servo_9041:
;kkik.c,138 :: 		servo_pulse(150);            // hold position forever
	MOVLW      150
	MOVWF      FARG_servo_pulse_pulse_us+0
	CLRF       FARG_servo_pulse_pulse_us+1
	CALL       _servo_pulse+0
;kkik.c,139 :: 		}
	GOTO       L_servo_9041
;kkik.c,140 :: 		}
L_end_servo_90:
	RETURN
; end of _servo_90

_ADC_Init:

;kkik.c,142 :: 		void ADC_Init(){
;kkik.c,143 :: 		ADCON0 = 0x41;
	MOVLW      65
	MOVWF      ADCON0+0
;kkik.c,144 :: 		ADCON1 = 0x8E;
	MOVLW      142
	MOVWF      ADCON1+0
;kkik.c,145 :: 		}
L_end_ADC_Init:
	RETURN
; end of _ADC_Init

_ADC_Read:

;kkik.c,147 :: 		unsigned int ADC_Read(){
;kkik.c,148 :: 		ADCON0 = ADCON0 | 0x04;
	BSF        ADCON0+0, 2
;kkik.c,149 :: 		while(ADCON0 & 0x04);
L_ADC_Read43:
	BTFSS      ADCON0+0, 2
	GOTO       L_ADC_Read44
	GOTO       L_ADC_Read43
L_ADC_Read44:
;kkik.c,150 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;kkik.c,151 :: 		}
L_end_ADC_Read:
	RETURN
; end of _ADC_Read

_Sonar_init:

;kkik.c,153 :: 		void Sonar_init(){
;kkik.c,155 :: 		TRISB = TRISB & 0xBF;
	MOVLW      191
	ANDWF      TRISB+0, 1
;kkik.c,156 :: 		TRISB = TRISB | 0x80;
	BSF        TRISB+0, 7
;kkik.c,159 :: 		TRISB = TRISB & 0xFD;
	MOVLW      253
	ANDWF      TRISB+0, 1
;kkik.c,160 :: 		TRISB = TRISB | 0x04;
	BSF        TRISB+0, 2
;kkik.c,161 :: 		}
L_end_Sonar_init:
	RETURN
; end of _Sonar_init

_Sonar_read_right:

;kkik.c,163 :: 		unsigned int Sonar_read_right(){
;kkik.c,164 :: 		unsigned int duration = 0;
	CLRF       Sonar_read_right_duration_L0+0
	CLRF       Sonar_read_right_duration_L0+1
	CLRF       Sonar_read_right_timeout_L0+0
	CLRF       Sonar_read_right_timeout_L0+1
;kkik.c,167 :: 		PORTB = PORTB & 0xBF;           // right TRIG LOW  (RB6)
	MOVLW      191
	ANDWF      PORTB+0, 1
;kkik.c,168 :: 		msdelay(2);
	MOVLW      2
	MOVWF      FARG_msdelay_ms+0
	MOVLW      0
	MOVWF      FARG_msdelay_ms+1
	CALL       _msdelay+0
;kkik.c,169 :: 		PORTB = PORTB | 0x40;           // right TRIG HIGH (RB6)
	BSF        PORTB+0, 6
;kkik.c,170 :: 		usdelay();
	CALL       _usdelay+0
;kkik.c,171 :: 		PORTB = PORTB & 0xBF;           // right TRIG LOW  (RB6)
	MOVLW      191
	ANDWF      PORTB+0, 1
;kkik.c,173 :: 		timeout = 0;
	CLRF       Sonar_read_right_timeout_L0+0
	CLRF       Sonar_read_right_timeout_L0+1
;kkik.c,174 :: 		while((PORTB & 0x80) == 0){     // wait ECHO HIGH (RB7)
L_Sonar_read_right45:
	MOVLW      128
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_Sonar_read_right46
;kkik.c,175 :: 		timeout++;
	INCF       Sonar_read_right_timeout_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Sonar_read_right_timeout_L0+1, 1
;kkik.c,176 :: 		if(timeout > 30000) return 500;
	MOVF       Sonar_read_right_timeout_L0+1, 0
	SUBLW      117
	BTFSS      STATUS+0, 2
	GOTO       L__Sonar_read_right85
	MOVF       Sonar_read_right_timeout_L0+0, 0
	SUBLW      48
L__Sonar_read_right85:
	BTFSC      STATUS+0, 0
	GOTO       L_Sonar_read_right47
	MOVLW      244
	MOVWF      R0+0
	MOVLW      1
	MOVWF      R0+1
	GOTO       L_end_Sonar_read_right
L_Sonar_read_right47:
;kkik.c,177 :: 		}
	GOTO       L_Sonar_read_right45
L_Sonar_read_right46:
;kkik.c,179 :: 		timeout = 0;
	CLRF       Sonar_read_right_timeout_L0+0
	CLRF       Sonar_read_right_timeout_L0+1
;kkik.c,180 :: 		while((PORTB & 0x80) != 0){     // count while ECHO HIGH
L_Sonar_read_right48:
	MOVLW      128
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_Sonar_read_right49
;kkik.c,181 :: 		duration++;
	INCF       Sonar_read_right_duration_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Sonar_read_right_duration_L0+1, 1
;kkik.c,182 :: 		usdelay();
	CALL       _usdelay+0
;kkik.c,183 :: 		timeout++;
	INCF       Sonar_read_right_timeout_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Sonar_read_right_timeout_L0+1, 1
;kkik.c,184 :: 		if(timeout > 30000) return 500;
	MOVF       Sonar_read_right_timeout_L0+1, 0
	SUBLW      117
	BTFSS      STATUS+0, 2
	GOTO       L__Sonar_read_right86
	MOVF       Sonar_read_right_timeout_L0+0, 0
	SUBLW      48
L__Sonar_read_right86:
	BTFSC      STATUS+0, 0
	GOTO       L_Sonar_read_right50
	MOVLW      244
	MOVWF      R0+0
	MOVLW      1
	MOVWF      R0+1
	GOTO       L_end_Sonar_read_right
L_Sonar_read_right50:
;kkik.c,185 :: 		}
	GOTO       L_Sonar_read_right48
L_Sonar_read_right49:
;kkik.c,186 :: 		return (duration / 6);
	MOVLW      6
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       Sonar_read_right_duration_L0+0, 0
	MOVWF      R0+0
	MOVF       Sonar_read_right_duration_L0+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
;kkik.c,187 :: 		}
L_end_Sonar_read_right:
	RETURN
; end of _Sonar_read_right

_Sonar_read_front:

;kkik.c,189 :: 		unsigned int Sonar_read_front(){
;kkik.c,190 :: 		unsigned int duration = 0;
	CLRF       Sonar_read_front_duration_L0+0
	CLRF       Sonar_read_front_duration_L0+1
	CLRF       Sonar_read_front_timeout_L0+0
	CLRF       Sonar_read_front_timeout_L0+1
;kkik.c,193 :: 		PORTB = PORTB & 0xFD;           // front TRIG LOW  (RB1)
	MOVLW      253
	ANDWF      PORTB+0, 1
;kkik.c,194 :: 		msdelay(2);
	MOVLW      2
	MOVWF      FARG_msdelay_ms+0
	MOVLW      0
	MOVWF      FARG_msdelay_ms+1
	CALL       _msdelay+0
;kkik.c,195 :: 		PORTB = PORTB | 0x02;           // front TRIG HIGH (RB1)
	BSF        PORTB+0, 1
;kkik.c,196 :: 		usdelay();
	CALL       _usdelay+0
;kkik.c,197 :: 		PORTB = PORTB & 0xFD;           // front TRIG LOW  (RB1)
	MOVLW      253
	ANDWF      PORTB+0, 1
;kkik.c,199 :: 		timeout = 0;
	CLRF       Sonar_read_front_timeout_L0+0
	CLRF       Sonar_read_front_timeout_L0+1
;kkik.c,200 :: 		while((PORTB & 0x04) == 0){     // wait ECHO HIGH (RB2)
L_Sonar_read_front51:
	MOVLW      4
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_Sonar_read_front52
;kkik.c,201 :: 		timeout++;
	INCF       Sonar_read_front_timeout_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Sonar_read_front_timeout_L0+1, 1
;kkik.c,202 :: 		if(timeout > 30000) return 500;
	MOVF       Sonar_read_front_timeout_L0+1, 0
	SUBLW      117
	BTFSS      STATUS+0, 2
	GOTO       L__Sonar_read_front88
	MOVF       Sonar_read_front_timeout_L0+0, 0
	SUBLW      48
L__Sonar_read_front88:
	BTFSC      STATUS+0, 0
	GOTO       L_Sonar_read_front53
	MOVLW      244
	MOVWF      R0+0
	MOVLW      1
	MOVWF      R0+1
	GOTO       L_end_Sonar_read_front
L_Sonar_read_front53:
;kkik.c,203 :: 		}
	GOTO       L_Sonar_read_front51
L_Sonar_read_front52:
;kkik.c,205 :: 		timeout = 0;
	CLRF       Sonar_read_front_timeout_L0+0
	CLRF       Sonar_read_front_timeout_L0+1
;kkik.c,206 :: 		while((PORTB & 0x04) != 0){     // count while ECHO HIGH
L_Sonar_read_front54:
	MOVLW      4
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_Sonar_read_front55
;kkik.c,207 :: 		duration++;
	INCF       Sonar_read_front_duration_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Sonar_read_front_duration_L0+1, 1
;kkik.c,208 :: 		usdelay();
	CALL       _usdelay+0
;kkik.c,209 :: 		timeout++;
	INCF       Sonar_read_front_timeout_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Sonar_read_front_timeout_L0+1, 1
;kkik.c,210 :: 		if(timeout > 30000) return 500;
	MOVF       Sonar_read_front_timeout_L0+1, 0
	SUBLW      117
	BTFSS      STATUS+0, 2
	GOTO       L__Sonar_read_front89
	MOVF       Sonar_read_front_timeout_L0+0, 0
	SUBLW      48
L__Sonar_read_front89:
	BTFSC      STATUS+0, 0
	GOTO       L_Sonar_read_front56
	MOVLW      244
	MOVWF      R0+0
	MOVLW      1
	MOVWF      R0+1
	GOTO       L_end_Sonar_read_front
L_Sonar_read_front56:
;kkik.c,211 :: 		}
	GOTO       L_Sonar_read_front54
L_Sonar_read_front55:
;kkik.c,212 :: 		return (duration / 6);
	MOVLW      6
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       Sonar_read_front_duration_L0+0, 0
	MOVWF      R0+0
	MOVF       Sonar_read_front_duration_L0+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
;kkik.c,213 :: 		}
L_end_Sonar_read_front:
	RETURN
; end of _Sonar_read_front

_usdelay:

;kkik.c,215 :: 		void usdelay(){
;kkik.c,217 :: 		for(i = 0; i < 20; i++){
	CLRF       R1+0
L_usdelay57:
	MOVLW      20
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_usdelay58
;kkik.c,218 :: 		asm NOP;
	NOP
;kkik.c,217 :: 		for(i = 0; i < 20; i++){
	INCF       R1+0, 1
;kkik.c,219 :: 		}
	GOTO       L_usdelay57
L_usdelay58:
;kkik.c,220 :: 		}
L_end_usdelay:
	RETURN
; end of _usdelay

_msdelay:

;kkik.c,222 :: 		void msdelay(unsigned int ms){
;kkik.c,224 :: 		for(i = 0; i < ms; i++){
	CLRF       R1+0
	CLRF       R1+1
L_msdelay60:
	MOVF       FARG_msdelay_ms+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msdelay92
	MOVF       FARG_msdelay_ms+0, 0
	SUBWF      R1+0, 0
L__msdelay92:
	BTFSC      STATUS+0, 0
	GOTO       L_msdelay61
;kkik.c,225 :: 		for(j = 0; j < 332; j++){
	CLRF       R3+0
	CLRF       R3+1
L_msdelay63:
	MOVLW      1
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msdelay93
	MOVLW      76
	SUBWF      R3+0, 0
L__msdelay93:
	BTFSC      STATUS+0, 0
	GOTO       L_msdelay64
;kkik.c,226 :: 		asm NOP;
	NOP
;kkik.c,225 :: 		for(j = 0; j < 332; j++){
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
;kkik.c,227 :: 		}
	GOTO       L_msdelay63
L_msdelay64:
;kkik.c,224 :: 		for(i = 0; i < ms; i++){
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;kkik.c,228 :: 		}
	GOTO       L_msdelay60
L_msdelay61:
;kkik.c,229 :: 		}
L_end_msdelay:
	RETURN
; end of _msdelay

_PWM:

;kkik.c,231 :: 		void PWM(){
;kkik.c,232 :: 		T2CON   = 0x07;
	MOVLW      7
	MOVWF      T2CON+0
;kkik.c,233 :: 		CCP1CON = 0x0C;
	MOVLW      12
	MOVWF      CCP1CON+0
;kkik.c,234 :: 		CCP2CON = 0x0C;
	MOVLW      12
	MOVWF      CCP2CON+0
;kkik.c,235 :: 		PR2     = 250;
	MOVLW      250
	MOVWF      PR2+0
;kkik.c,236 :: 		CCPR1L  = 0;
	CLRF       CCPR1L+0
;kkik.c,237 :: 		CCPR2L  = 0;
	CLRF       CCPR2L+0
;kkik.c,238 :: 		}
L_end_PWM:
	RETURN
; end of _PWM

_Move_forward:

;kkik.c,240 :: 		void Move_forward(unsigned char L, unsigned char R){
;kkik.c,241 :: 		PORTD  = 0x05;
	MOVLW      5
	MOVWF      PORTD+0
;kkik.c,242 :: 		CCPR1L = R;
	MOVF       FARG_Move_forward_R+0, 0
	MOVWF      CCPR1L+0
;kkik.c,243 :: 		CCPR2L = L;
	MOVF       FARG_Move_forward_L+0, 0
	MOVWF      CCPR2L+0
;kkik.c,244 :: 		}
L_end_Move_forward:
	RETURN
; end of _Move_forward

_stop:

;kkik.c,246 :: 		void stop(){
;kkik.c,247 :: 		PORTD  = 0x00;
	CLRF       PORTD+0
;kkik.c,248 :: 		CCPR1L = 0;
	CLRF       CCPR1L+0
;kkik.c,249 :: 		CCPR2L = 0;
	CLRF       CCPR2L+0
;kkik.c,250 :: 		}
L_end_stop:
	RETURN
; end of _stop
