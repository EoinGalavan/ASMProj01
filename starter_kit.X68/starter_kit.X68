*-------------------------------------------------------
* STARTING MEMORY ADDRESS FOR THE PROGRAMME $1000
*-------------------------------------------------------
    
    ORG $1000

*-------------------------------------------------------
*CHOOSE TO BE A PLUMBER OR A RABBIT 
*-------------------------------------------------------

*-------------------------------------------------------
*VALIDATION VALUES TO BE USED, MODIFY AS NEEDED
*ADD ADDITIONAL VALIDATION VALUES AS REQUIRED
*-------------------------------------------------------
EXIT        EQU 0      USED TO EXIT ASSEMBLY PROGRAM
MIN_POTIONS EQU 1      MIN NUMBER OF POTIONS
MAX_POTIONS EQU 9      MAX NUMBER OF POTIONS
MIN_WEAPONS EQU 1      MIN WEAPONS
MAX_WEAPONS EQU 3      MAX WEAPONS
WIN_POINT   EQU 5      POINTS ACCUMILATED ON WIN
LOSE_POINT  EQU 8      POINTS DEDUCTED ON A LOSS

MINE_LOC    EQU 100    USED BELOW FOR SOME SIMPLE COLLISION DETECTION USING CMP
                       * EXAMPLE FOR A HIT


*START OF GAME
START:
    MOVE.l  #100,HEALTH 
    MOVE.l  #100,ENEMYHEALTH 
    MOVE.B  #0,GAMESTATE
    MOVE.B  #0,MOVE_CHOICE


    BSR     WELCOME    BRANCH TO THE WELCOME SUBROUTINE
    BSR     GAME       BRANCH TO THE GAME SUBROUTINE
*GAME LOOP
    ORG     $3000      THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BSR     GAMELOOP   BRANCH TO GAMELOOP SUBROUTINE
    RTS                RETURN FROM GAME: SUBROUTINE
          
END:
    SIMHALT

*-------------------------------------------------------
*-------------------WELCOME SUBROUTINE------------------
*-------------------------------------------------------
WELCOME:
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    LEA     WELCOME_MSG,A1  ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          MOVE LITERAL 14 TO DO
    TRAP    #15             TRAP AND INTERPRET VALUE IN D0
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    RTS                     RETURN FROM WELCOME: SUBROUTINE

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     UPDATE          BRANCH TO UPDATE GAME SUBROUTINE 
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN         
    BSR     DRAW            BRANCH TO DRAW SCREEN SUBROUTINE
GAMEPLAY_RESET:
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    BSR     GAMEPLAY        BRANCH TO GAMEPLAY SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    BSR     HUD             BRANCH TO DISPLAY HUD SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    BSR     REPLAY          BRANCH TO REPLAY GAME SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    RTS                     RETURN FROM GAMELOOP: SUBROUTINE

*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    BSR     ENDL            PRINT A CR AND LF
    BSR     DECORATE        DECORATE WITH DOTS USING A LOOP 
    CMP.B   #1, GAMESTATE
    BNE     SKIP        
    CMP.B   #0, MOVE_CHOICE
    BNE     MOVE_EXECUTE
    LEA     READY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
UPDATE_RETURN:
    BSR     DECORATE
    MOVE.B  #4,D0
    TRAP    #15
    RTS
SKIP:
    LEA     INTRO_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA.S   UPDATE_RETURN
    
MOVE_EXECUTE:
    CMP.B   #1, MOVE_CHOICE
    BEQ     ATTACK
    CMP.B   #2, MOVE_CHOICE
    BEQ     HEAL
PLAYER_COMPLETE:
    SUB.L   #10, HEALTH
    LEA     ENEMY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA.S   UPDATE_RETURN

ATTACK:
    SUB.L   #5, ENEMYHEALTH
    LEA     ATTACK_MSG,A1   
    MOVE.B  #14,D0
    TRAP    #15
    BRA.S   PLAYER_COMPLETE
HEAL:
    MOVE.l  #100,HEALTH
    LEA     HEAL_MSG,A1   
    MOVE.B  #14,D0
    TRAP    #15
    BRA.S   PLAYER_COMPLETE
*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL
    BSR     DECORATE
    LEA     DRAW_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
GAMEPLAY:
    BSR     ENDL
    BSR     DECORATE
    CMP.B   #0, (GAMESTATE)
    BEQ     GAMEPLAY_CHOOSE
    CMP.B   #1, (GAMESTATE)
    BEQ     GAMEPLAY_MISSION
GAMEPLAY_RETURN:
    MOVE.B  #1, GAMESTATE
    BSR     DECORATE
    BSR     COLLISION
    RTS
GAMEPLAY_CHOOSE:
    LEA     RABBITOR_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    MOVE.B  D1,TEAM    
    CMP.W   #0,D1
    BEQ     GAMEPLAY_RETURN
    CMP.W   #1,D1
    BEQ     GAMEPLAY_RETURN
    JMP     GAMEPLAY_RESET
GAMEPLAY_MISSION:
    CMP.B   #0, TEAM
    BEQ     RABBIT_SIDE
    BRA.S   PLUMBER_SIDE
RABBIT_SIDE:
    LEA     RABBIT_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.L  HEALTH,D1
    MOVE.B  #10,D2
    MOVE.B  #15,D0
    TRAP    #15
    LEA     RABBIT_MSG2,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.L  ENEMYHEALTH,D1
    MOVE.B  #10,D2
    MOVE.B  #15,D0
    TRAP    #15
    BRA.W   DISPLAY_OPTIONS
PLUMBER_SIDE:
    LEA     PLUMBER_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.L  HEALTH,D1
    MOVE.B  #10,D2
    MOVE.B  #15,D0
    TRAP    #15
    LEA     PLUMBER_MSG2,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.L  ENEMYHEALTH,D1
    MOVE.B  #10,D2
    MOVE.B  #15,D0
    TRAP    #15
    BRA.W   DISPLAY_OPTIONS
DISPLAY_OPTIONS:
    LEA     COMBAT_OPTIONS,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    MOVE.B  D1,MOVE_CHOICE 
    BRA.W   GAMEPLAY_RETURN
*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE)--------------
* RETRIEVES THE SCORE FROM MEMORY LOCATION
*-------------------------------------------------------   
HUD:

    BSR     ENDL
    BSR     DECORATE
    *LEA     HUD_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1     RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0       MOVE LITERAL 3 TO D0
    TRAP    #15         INTREPRET VALUE IN D0, WHICH 3 WHICH DISPLAYS D1
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*-------------------------------------------------------
COLLISION:
    MOVE.B  #MINE_LOC,D1
    CMP     #100,D1 IS( X == 100)?
	BNE     COLLISION_MISS IF X IS EQUAL TO 100, THEN HIT
COLLISION_HIT:
    *HIT
    LEA     HIT_MSG,A1
    MOVE    #14,D0
    TRAP    #15
    RTS
    
COLLISION_MISS:
    *MISS
    LEA     MISS_MSG,A1
    MOVE    #14,D0
    TRAP    #15
    RTS

*-------------------------------------------------------
*--------------------------LOOP-------------------------
*-------------------------------------------------------
LOOP:
    MOVE.B  #5, D3 LOOP COUNTER D3=5
NEXT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3   DECREMENT LOOP COUNTER
    BNE     NEXT    REPEAT UNTIL D0=0

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3
    BSR     ENDL
OUT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3   DECREMENT LOOP COUNTER
    BNE     OUT	    REPEAT UNTIL D0=0
    BSR     ENDL
    RTS
    
CLEAR_SCREEN: 
    MOVE.B  #11,D0      CLEAR SCREEN
    MOVE.W  #$FF00,D1
    TRAP    #15
    RTS
*-------------------------------------------------------
*------------------------REPLAY-------------------------
*-------------------------------------------------------
REPLAY:
    BSR     ENDL
    
    CMP.L   #0,ENEMYHEALTH
    BLE     WIN  

    CMP.L   #0,HEALTH
    BLE     LOSE         
    BSR     GAMELOOP

LOSE:    
    LEA     LOSE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA.S   STOP
WIN:
    LEA     LOSE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
STOP:
    MOVE.B  #4,D0
    TRAP    #15
    JMP     END

ENDL:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    RTS
    
*-------------------------------------------------------
*-------------------DATA DELARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0
WELCOME_MSG:    DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    'RABBITS VS PLUMBERS'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A,0
ATTACK_MSG:     DC.B    'ENEMY TOOK 5 DAMAGE',0
HEAL_MSG:       DC.B    'YOU HEALED BACK UP TO 100',0

RABBIT_MSG:     DC.B    'RABBIT HEALTH: ', 0
RABBIT_MSG2:    DC.B    $0D,$0A
                DC.B    'PLUMBER HEALTH: ', 0

PLUMBER_MSG:    DC.B   'PLUMBER HEALTH: ', 0
PLUMBER_MSG2:   DC.B    $0D,$0A
                DC.B    'RABBIT HEALTH: ', 0
COMBAT_OPTIONS: DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    '1: ATTACK'
                DC.B    $0D,$0A
                DC.B    '2: HEAL'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A,0
RABBITOR_MSG:   DC.B    'RABBIT OR PLUMBER?(0 FOR RABBIT, 1 FOR PLUMBER)'
                DC.B    $0D,$0A,0
DRAW_MSG:       DC.B    'DRAW SCREEN !',0
HIT_MSG:        DC.B    'STRIKE!',0
MISS_MSG:       DC.B    'MISS!',0
LOOP_MSG:       DC.B    '.',0
ENEMY_MSG:      DC.B    $0D,$0A
                DC.B    'YOU TOOK 10 DAMAGE!',0
WIN_MSG:        DC.B    'YOU WON!',0
LOSE_MSG:       DC.B    'YOU LOST..',0
INTRO_MSG:      DC.B    'FIRST CHOOSE A SIDE',0
READY_MSG:      DC.B    'FIGHT THE ENEMY!',0



HEALTH:         DS.L    1   PLAYERS HEALTH
ENEMYHEALTH:    DS.L    1   ENEMY HEALTH
SCORE:          DS.L    1   RESERVE SPACE FOR SCORE

GAMESTATE:      DS.B    1   CURRENT GAMESTATE
TEAM            DS.B    1   TEAMSELECTED
MOVE_CHOICE     DS.B    1   CURRECNTLY SELECTED MOVE

    END START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
