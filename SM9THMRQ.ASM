           

           ;THIS IS FEEDBACK REQ.SMS TO THE DIALED PERSON
           ;TEM+LIG+HUM+MOISTURE+WIND SPEED
           ; ON 13-03-2014 
           
           ;P2.0 =BUZZER  
           ;P2.1 =         
           ;P1.5 MUX ENABLE
           ;P0 = DISP DATA
           
           ;P2.7 = RS
           ;P2.6 = R/W
           ;P2.5 = EN

TXD     MACRO        
        JNB TI,$
        CLR TI
        MOV SBUF,R6
        MACEND

RXD     MACRO        
        
        JNB RI,$
        CLR RI
        MOV R7,SBUF
        
        MACEND
        
  
       ORG 0
       LJMP START
       ORG 0050H

START: MOV P2,#00H
       SETB P2.4

       LCALL SPGSM
       LCALL LCDINI
       LCALL DEL 
       
XX1:    MOV DPTR,#0900H
        LCALL TLINE
        MOV DPTR,#0910H
        LCALL BLINE
        LCALL SSEC
        
        MOV DPTR,#09C0H
        LCALL TLINE
        MOV DPTR,#09D0H
        LCALL BLINE
        
        
        MOV 7FH,#05H
VBN:    LCALL GPSTRDY
        DEC 7FH
        MOV A,7FH
        CJNE A,#00H,VBN
        
        LJMP SMSRX
RETRX:  LJMP SMSX

         
;***********  SMS  TXD  *********
SMSX:   MOV DPTR,#0960H
        LCALL TLINE
        MOV DPTR,#0970H
        LCALL BLINE
        ;-------------------
        
        MOV 3EH,#03H
        ;------------------------
SMSXX:  MOV DPTR,#AT_CMGF     ;SMS MODE PDU=0/TEXT=1
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER
        
        LCALL SEC
        
        MOV DPTR,#AT_ERS      ;ERASE OF 1 ST LOCATION
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER          
        
        LCALL SEC
        LCALL SEC
        
        MOV DPTR,#AT_CPMS      ;SIMM MEMORY SELECTION
        MOV R2,#0CH
        LCALL CMD1
        LCALL ENTER          
        
        LCALL SEC                       ;BETTER TO PUT ERASE   
        
        ;-----DATA SENDING FOR-REQ  NUMBERS -----------

       
        MOV DPTR,#AT_CMGW      
        MOV R2,#09H
        LCALL CMD1
        LCALL NUM 
        LCALL ENTER
        ;-----------------------------------
        LCALL SEC3
        LCALL MESS  
        
        LCALL SEC3
        MOV DPTR,#AT_CMSS       ;SEND COMMAND TO MODEM
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER
        
        SETB P2.0
        LCALL SEC
        CLR P2.0
        LCALL SEC3
        LJMP XX1

; ***************** MOB NUMBER ****************
NUM:    MOV R6,20H
        TXD
        MOV R6,21H
        TXD
        MOV R6,22H
        TXD
        MOV R6,23H
        TXD
        MOV R6,24H
        TXD
        MOV R6,25H
        TXD
        MOV R6,26H
        TXD
        MOV R6,27H
        TXD
        MOV R6,28H
        TXD
        MOV R6,29H
        TXD
        
        MOV R6,#22H
        TXD
        RET
NUMST: 
       MOV 20H,2DH
       MOV 21H,2EH
       MOV 22H,2FH
       MOV 23H,30H
       MOV 24H,31H
       MOV 25H,32H
       MOV 26H,33H
       MOV 27H,34H
       MOV 28H,35H
       MOV 29H,36H
       RET
;*******************************************
SMSRX:  ;LCALL NDATA
                   
        CLR P2.0

        LCALL SEC3

        MOV DPTR,#AT_ERS      ;ERASE OF 1 ST LOCATION
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER          
        
        MOV DPTR,#AT_ERS2     ;ERASE OF 2 ST LOCATION
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER          
        
        MOV DPTR,#AT_ERS3     ;ERASE OF 3 ST LOCATION
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER          
        
        MOV DPTR,#AT_ERS4     ;ERASE OF 4 ST LOCATION
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER          
        
        MOV DPTR,#AT_ERS5     ;ERASE OF 5 ST LOCATION
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER          
        
        ;---------------------
        MOV DPTR,#AT_CMGF     ;SMS MODE PDU=0/TEXT=1
        MOV R2,#09H
        LCALL CMD1
        LCALL ENTER
        LCALL SEC

        MOV DPTR,#AT_CNMI     ;REQ. FOR RECEIVE     
        MOV R2,#11H
        LCALL CMD1
        LCALL ENTER
        LCALL SEC

        MOV DPTR,#AT_CNMA     ;READY TO RECEIVE      
        MOV R2,#07H
        LCALL CMD1
        LCALL ENTER
        LCALL SEC3
        LCALL SEC
        CLR P2.0
        MOV DPTR,#0980H
        LCALL TLINE
        MOV DPTR,#0990H
        LCALL BLINE
        LCALL SEC3

;********************************
MAIN:   MOV R0,#20H

NXTB:   LCALL RXD
        CJNE R4,#01H,NXTB
        MOV A,R1
        MOV @R0,A
        INC R0
        CJNE R0,#57H,NXTB
        
        LCALL SDISP
        LCALL SEC3
        LJMP RVERI
HHHH:   LJMP RETRX

;******* REQ VERIFICATION ***********
RVERI:  MOV A,54H
        CJNE A,#'O',MRET
        MOV A,55H
        CJNE A,#'N',MRET
        MOV A,56H
        CJNE A,#'M',MRET
        CLR P2.0
        SETB P2.1
        LCALL NUMST
        LJMP GPSTRDX
                     

        ;-------
MRET:   MOV A,54H
        CJNE A,#'O',MRET1
        MOV A,55H
        CJNE A,#'F',MRET1
        MOV A,56H
        CJNE A,#'M',MRET1
        CLR P2.0
        CLR P2.1
        LCALL NUMST
        LJMP GPSTRDX
                     
MRET1:  LJMP RETRX

;************************************
RXD:         MOV R4,#00H
             MOV R7,#1FH  
AE:          MOV R6,#FFH
AD:          MOV R5,#FFH
AB:          JNB RI,AC
             CLR RI
             MOV R1,SBUF
             MOV R4,#01H      ;STATUS CHK  #01 OK,#02 NOT OK
             ;MOV R6,SBUF
             ;TXD
             RET
AC:           DJNZ R5,AB
              DJNZ R6,AD
              DJNZ R7,AE
              MOV R4,#02H
              RET
;****************************************
SDISP:    CLR p2.7  
         CLR p2.6
         MOV P0,#80H
         LCALL WRI
         MOV R1,#2AH
MTKL:         
         CLR A
         MOV A,@R1
         MOV P0,A
         LCALL WRD
         INC R1
         CJNE R1,#3AH,MTKL
         ;---------
         
         CLR p2.7  
         CLR p2.6
         MOV P0,#C0H
         LCALL WRI
         MOV R1,#54H
XTKL:         
         CLR A
         MOV A,@R1
         MOV P0,A
         LCALL WRD
         INC R1
         CJNE R1,#57H,XTKL
         
        ;-----------------------
        RET

;********** LCD INI *************************
LCDINI:   
      
        CLR P2.5
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#30H
        LCALL WRI

        CLR p2.7  
        CLR p2.6
        MOV P0,#30H
        LCALL WRI

        CLR p2.7  
        CLR p2.6
        
        MOV P0,#30H
        LCALL WRI
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#38H
        LCALL WRI


        CLR p2.7  
        CLR p2.6
        MOV P0,#01H
        LCALL WRI

        CLR p2.7  
        CLR p2.6
        MOV P0,#01H
        LCALL WRI

        CLR p2.7  
        CLR p2.6
        MOV P0,#01H
        LCALL WRI
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#02H
        LCALL WRI
      

        CLR p2.7  
        CLR p2.6
        MOV P0,#0CH
        LCALL WRI
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#1CH
        LCALL WRI
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#38H
        LCALL WRI
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#06H
        LCALL WRI
      
        CLR p2.7  
        CLR p2.6
        MOV P0,#01H
        LCALL WRI
        
        RET
;----------------------------
TLINE:   CLR p2.7  
         CLR p2.6
         MOV P0,#80H
         LCALL WRI
         MOV R7,#00H
TKL:         
         CLR A
         MOVC A,@A+DPTR
         MOV P0,A
         LCALL WRD
         INC DPTR
         INC R7
         CJNE R7,#10H,TKL
         RET

BLINE:   CLR p2.7  
         CLR p2.6
         MOV P0,#C0H
         LCALL WRI
         MOV R7,#00H
BKL:         
         CLR A
         MOVC A,@A+DPTR
         MOV P0,A
         LCALL WRD
         INC DPTR
         INC R7
         CJNE R7,#10H,BKL
         RET

;******** INSTRUCTION /DATA WRITE *********

WRI:   SETB P2.5
       MOV R0,#FFH
       DJNZ R0,$
       CLR P2.5
       MOV R0,#FFH
       DJNZ R0,$
       
       RET

WRD:   SETB p2.7 ; REGISTER
       CLR p2.6  ;READ WRITE
       SETB P2.5 ;ENABLE
       MOV R0,#FFH
       DJNZ R0,$
       CLR P2.5
       CLR p2.6
       CLR p2.7
       RET
;******************************


DEL:        MOV R7,#FFH
            DJNZ R7,$
            RET
DEL1:       MOV R7,#FFH
            DJNZ R7,$
            RET


SEC:        MOV R5,#03H
 M1:        MOV R6,#FFH
 M2:        MOV R7,#FFH
 M3:        DJNZ R7,M3
            DJNZ R6,M2
            DJNZ R5,M1
            RET

SEC3:        MOV R5,#0FH
 M13:        MOV R6,#FFH
 M23:        MOV R7,#FFH
 M33:        DJNZ R7,M33
            DJNZ R6,M23
            DJNZ R5,M13
            RET

SSEC:        MOV R5,#1FH
 SM1:        MOV R6,#FFH
 SM2:        MOV R7,#FFH
 SM3:        DJNZ R7,SM3
            DJNZ R6,SM2
            DJNZ R5,SM1
            RET
;********************************************

XDEL:    
        mov r4,#0FH
        djnz r4,$
        RET     
  
XDEL1:    mov r4,#0FH
         djnz r4,$
         RET     

XDEL2:  MOV R5,#5FH
GB:     mov r4,#FFH
        djnz r4,$
        DJNZ R5,GB
        RET
;**********************************************
ENTER:  MOV R6,#0DH
        TXD
        RET

CMD1:   CLR A
        MOVC A,@A+DPTR
        MOV R6,A
        TXD
        INC DPTR
        DJNZ R2,CMD1
        RET
;************** UART PORT INT *************
SPGPS:  
        MOV A,#00H
        MOV TCON,#40H
        MOV TMOD,#20H
        MOV SCON,#52H
        MOV IE,#9AH
        MOV TH1,#FAH
        MOV TL1,#FAH
        RET
        ;----------9600BPS------
SPGSM: 
        MOV A,#00H
        MOV TCON,#40H
        MOV TMOD,#20H
        MOV SCON,#52H
        MOV IE,#9AH
        MOV TH1,#FDH
        MOV TL1,#FDH
        RET

;************ DATA COLLECTION MODULE TEMP,GPS ********** 
GPSTRDX:        
        MOV DPTR,#09C0H
        LCALL TLINE
        MOV DPTR,#09D0H
        LCALL BLINE
        

GPSTRD: SETB P2.0
        CLR P3.4
        CLR P3.5
        LCALL VSEN
        MOV R7,51H
        LCALL CONVERT
        
        MOV 35H,32H
        MOV 34H,31H
        MOV 33H,30H
        
        
        ;------------
        
        CLR P3.4
        SETB P3.5
        LCALL VSEN
        MOV R7,51H
        LCALL CONVERT
        
        MOV 38H,32H
        MOV 37H,31H
        MOV 36H,30H
        
       ;-------------
       SETB P3.4
        CLR P3.5
        LCALL VSEN
        MOV R7,51H
        LCALL CONVERT
        
        MOV 3BH,32H
        MOV 3AH,31H
        MOV 39H,30H
       ;--------------
        
        
        
        LCALL DISP
        CLR P2.0
        
        LCALL SEC
        ;RET

        LJMP RETRX


GPSTRDY:SETB P2.0
        CLR P3.4
        CLR P3.5
        LCALL VSEN
        MOV R7,51H
        LCALL CONVERT
        
        MOV 35H,32H
        MOV 34H,31H
        MOV 33H,30H
        
        
        ;------------
        
        CLR P3.4
        SETB P3.5
        LCALL VSEN
        MOV R7,51H
        LCALL CONVERT
        
        MOV 38H,32H
        MOV 37H,31H
        MOV 36H,30H
        
       ;-------------
       SETB P3.4
        CLR P3.5
        LCALL VSEN
        MOV R7,51H
        LCALL CONVERT
        
        MOV 3BH,32H
        MOV 3AH,31H
        MOV 39H,30H
       ;--------------
        
        
        LCALL DISP
        CLR P2.0
        
        LCALL SEC
        RET


;******************************************************* 
        ;R4 IS STATUS,R1 REG DATA

XRXD:    MOV R4,#00H
         MOV R7,#08H  
XAE:     MOV R6,#FFH
XAD:     MOV R5,#FFH
XAB:     
         JNB RI,XAC
         CLR RI
         MOV R1,SBUF
         MOV R4,#01H      ;STATUS CHK  #01 OK,#02 NOT OK
         RET

XAC:     DJNZ R5,XAB
         DJNZ R6,XAD
         DJNZ R7,XAE
         MOV R4,#02H
         RET

;********* VOLTAGE SENSE  ************
VSEN:     
        
       ;CLR P3.4
       ;CLR P3.5
        
        mov p1,#FFH 
        SETB P3.2
        SETB P3.3
        SETB P3.6
        SETB P3.7

        CLR P3.2
        CLR P3.3
        

        LCALL DEL
        
        LCALL DEL
        SETB P3.2
        LCALL DEL
        SETB P3.3
        LCALL DEL
        CLR P3.2
        LCALL DEL
        CLR P3.3
        LCALL SEC

        MOV R6,P1
        MOV 51H,R6
        LCALL XDEL
        LCALL SEC

        RET

;************************************
CONVERT:  
        MOV 32H,#30H
        MOV 31H,#30H
        MOV 30H,#30H
        
NDEC:   DEC R7
        CJNE R7,#FFH,INC1
        RET

INC1:  INC 30H
       MOV A,30H
       CJNE A,#3AH,NDEC
       MOV 30H,#30H
       INC 31H
       MOV A,31H
       CJNE A,#3AH,NDEC
       MOV 31H,#30H
       INC 32H
       LJMP NDEC
;**********************************
DISP:    
         CLR p2.7  
         CLR p2.6
         MOV P0,#82H
         LCALL WRI
         
         MOV P0,35H
         LCALL WRD
         MOV P0,34H
         LCALL WRD
         MOV P0,33H
         LCALL WRD
         
         MOV 10H,35H
         MOV 11H,34H
         MOV 12H,33H
         
         CLR p2.7  
         CLR p2.6
         MOV P0,#89H
         LCALL WRI
         MOV P0,38H
         LCALL WRD
         MOV P0,37H
         LCALL WRD
         MOV P0,36H
         LCALL WRD
         MOV 13H,38H
         MOV 14H,37H
         MOV 15H,36H
         
         CLR p2.7  
         CLR p2.6
         MOV P0,#C4H
         LCALL WRI
         MOV P0,3BH
         LCALL WRD
         MOV P0,3AH
         LCALL WRD
         MOV P0,39H
         LCALL WRD
         
         MOV 16H,3BH
         MOV 17H,3AH
         MOV 18H,39H
         
         RET




;----------SENDING MES.INFORMATION 
MESS: 
        MOV R6,#54H
        TXD
        MOV R6,#3AH
        TXD
        MOV R6,#20H
        TXD
        MOV R6,10H 
        TXD
        MOV R6,11H 
        TXD
        MOV R6,12H
        TXD
        MOV R6,#20H
        TXD
        
        MOV R6,#'H'
        TXD
        MOV R6,#3AH
        TXD
        MOV R6,#20H
        TXD
        MOV R6,13H 
        TXD
        MOV R6,14H 
        TXD

        MOV R6,15H
        TXD
        MOV R6,#20H
        TXD

        MOV R6,#'S'
        TXD
        MOV R6,#'M'
        TXD

        MOV R6,#3AH
        TXD
        MOV R6,#20H
        TXD
        MOV R6,16H 
        TXD
        MOV R6,17H 
        TXD
        
        MOV R6,18H
        TXD
        MOV R6,#20H
        TXD
        MOV R6,#6DH
        TXD
        MOV R6,#41H
        TXD

        
        MOV R6,#20H
        TXD
        
        MOV R6,#1AH
        TXD
        RET

;##############################
      
       ORG 0900H
       ;************  1 LINE
      
      DB 'ADVANCED FORMING'
      DB 'WITH DAS - GSM  '
      
      DB 'TR:             '
      DB '                '
      
      DB '  SMS SENT OK   '
      DB '                '
      
      DB '  SMS SENDING.. '
      DB '                '
      
      DB 'WAITING FOR REQ.'
      DB '                '

      DB 'RQ:             '
      DB '                '

      DB 'T:    H:        '  ;09C0
      DB 'SM:             '
      
      DB 'LON:            '
      DB 'LAT:            '
      
;*********************************
        
        ORG 1B00H
AT_CMGF: DB "AT+CMGF=1"

         ORG 1B20H
AT_CPMS: DB "AT+CPMS="
         DB 22H
         DB "SM"
         DB 22H

         ORG 1B40H
AT_CMGW: DB "AT+CMGS="
         DB 22H
         DB "9246400662"
         DB 22H
         
         ORG 1B60H
AT_CMD:  DB "                               "       
         DB 1AH

         ORG 1BA0H
AT_CMSS: DB "AT+CMSS=1"
         
         ORG 1BC0H
AT_D:    DB "ATD9491896606;"
         
         ORG 1C00H
AT_ERS:  DB "AT+CMGD=1"     
         ORG 1C10H
AT_ERS2: DB "AT+CMGD=2"     
         ORG 1C20H
AT_ERS3: DB "AT+CMGD=3"     
         ORG 1C30H
AT_ERS4: DB "AT+CMGD=4"     
         ORG 1C40H
AT_ERS5: DB "AT+CMGD=5"     

        ORG 1C50H
AT_CNMI: DB "AT+CNMI=2,2,0,0,0"

         ORG 1C70H
AT_CNMA: DB "AT+CNMA"             

         
         ORG 1C80H          ;2ND SMS
AT_CMGW2:DB "AT+CMGS="
         DB 22H
         DB "9533306284"
         DB 22H

         ORG 1CA0H          ;3RD SMS
AT_CMGW3:DB "AT+CMGS="
         DB 22H
         DB "9491896606"
         DB 22H
        END;

;AAAAAAAAAAAAA---------------FINAL  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  
             
