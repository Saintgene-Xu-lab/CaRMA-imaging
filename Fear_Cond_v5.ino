#include <Timer1.h>
#include <Timer3.h>
#include <Timer4.h>

#define ACQ_S_PIN 21
#define PUMP_TTL_WIDTH 120000 //us feeding trigger duration
#define TRG_TTL_WIDTH 200000   //us trigger mp3 player
#define PumpTTL_PIN 36
#define LICK_IND_PIN 35
#define EXT_INT 0 //interrupt number 0 is pin 2
#define LICK_INPUT_PIN 2
#define PUMP_START HIGH
#define SND_TRIG_PIN 39
#define SND_ACT 3 //input
#define SHOCK_TRIG 51
#define TIMER_PACE 1000000 //1 second pace

//Treadmill encoder
#define ENCODER_A_PIN 20
#define ENCODER_B_PIN 4
#define SPEED_COUNT_PEROID 1000000 // 1 second

enum STATE
{
  TRIAL_START,
  SPOUT_OUT,
  CUE_START,
  CUE_DELAY,
  SHOCK_S,
  SHOCK_E,
  SPOUT_IN,
  TRIAL_END
};

unsigned long lTime_Start_SpO = 30000000; //Duration between trial start and spout out
unsigned long lTime_SpO_Cue = 30000000; //Duration between spout out and auditory cue
unsigned long lTimeShockDrt = 2000000; // foot shock duration
unsigned long lTime_Shk_SpI = 30000000; //Duration between shock and spout in
unsigned long lTime_SpI_End = 30000000; //Duration between spout in and trial end
volatile int iLickAftPump = 0;
const int iConsumption = 3;
unsigned long lFeed = 0;
unsigned long lShock = 0;
volatile STATE emState = TRIAL_END;
volatile boolean bStateChanged = false;
volatile unsigned long lTimerLoops = 0;
volatile unsigned long lTimerResidual = 0;
volatile unsigned long lTimer = 0;
unsigned int iAutoPump = 30;
volatile unsigned int iPumpTime = iAutoPump;
unsigned char MtMsg[6] = {
  0, 0, 0, 0, 0, 0
};

volatile long lDist_Rel = 0;
volatile unsigned long lDist_Abs_Pre = 0;
volatile unsigned long lDist_Abs = 0;
volatile unsigned long lSpeed_Abs = 0;


void startTime3_Long(unsigned long lTime)
{
  pauseTimer3();
  lTimerLoops = lTime / TIMER_PACE;
  lTimerResidual = lTime % TIMER_PACE;
  if (lTimerLoops > 0)
  {
    startTimer3(TIMER_PACE);
  }
  else
  {
    startTimer3(lTime);
  }
  lTimer = 0;
}

void setup()
{
  pinMode(PumpTTL_PIN, OUTPUT);
  pinMode(LICK_INPUT_PIN, INPUT);
  pinMode(ACQ_S_PIN, INPUT);
  pinMode(LICK_IND_PIN, OUTPUT);
  pinMode(SND_TRIG_PIN, OUTPUT);
  pinMode(SND_ACT, INPUT_PULLUP);
  pinMode(SHOCK_TRIG, OUTPUT);
  pinMode(ENCODER_A_PIN, INPUT_PULLUP);
  pinMode(ENCODER_B_PIN, INPUT_PULLUP);
  digitalWrite(SND_TRIG_PIN, HIGH);
  digitalWrite(SHOCK_TRIG, LOW);
  //disableMillis();
  startTimer1(PUMP_TTL_WIDTH);
  pauseTimer1();
  startTime3_Long(lTime_Start_SpO);
  pauseTimer3();
  startTimer4(SPEED_COUNT_PEROID);
  attachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN), PumpAction, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ACQ_S_PIN), StartTrg, RISING);
  attachInterrupt(digitalPinToInterrupt(ENCODER_A_PIN), EncoderCal, RISING);
  attachInterrupt(digitalPinToInterrupt(SND_ACT), StartShk, RISING);
  Serial.begin(9600);
  Serial2.begin(9600);
  MtMsg[1] = 1;
  Serial2.write(MtMsg, 6);
}

void loop()
{
  if (bStateChanged)
  {
    bStateChanged = false;
    switch (emState)
    {
      case TRIAL_START:
        {
          startTime3_Long(lTime_Start_SpO);
          //Serial.println("TRIAL_START_s");
        }
        break;

      case SPOUT_OUT:
        {
          startTime3_Long(lTime_SpO_Cue);
          MtMsg[1] = 18;
          Serial2.write(MtMsg, 6);
        }
        break;

      case CUE_START:
        {
          digitalWrite(SND_TRIG_PIN, LOW);
          startTime3_Long(TRG_TTL_WIDTH);
          //Serial.println("Cue_s");
        }
        break;

      case SHOCK_S:
        {
          digitalWrite(SHOCK_TRIG, HIGH);
          startTime3_Long(lTimeShockDrt);
          Serial.println("Shock_s");
        }
        break;

      case SHOCK_E:
        {
          startTime3_Long(lTime_Shk_SpI);
          Serial.println("Shock_e");
        }
        break;

      case SPOUT_IN:
        {
          startTime3_Long(lTime_SpI_End);
          MtMsg[1] = 1;
          Serial2.write(MtMsg, 6);
        }
        break;

      case CUE_DELAY:
      case TRIAL_END:
        {
          pauseTimer3();
          //Serial.println("XX_s");
        }
        break;

      default:
        break;
    }
  }
}

void serialEvent()
{
  char inChar = (char)Serial.read();

  switch (inChar)
  {
    case 'V':
    case 'v':
      {
        Serial.println("Fear_Cond_2p");
      }
      break;

    case 'D':
    case 'd':
      {
        detachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN));
        Serial.println("Pump function detached!");
      }
      break;

    case 'A':
    case 'a':
      {
        attachInterrupt(digitalPinToInterrupt(LICK_INPUT_PIN), PumpAction, CHANGE);
        Serial.println("Pump function attached!");
      }
      break;

    case 'T':
    case 't':
      {
        ResetTrailStates();
        attachInterrupt(digitalPinToInterrupt(ACQ_S_PIN), StartTrg, RISING);
        Serial.println("Mount start trigger!");
      }
      break;

    case 'U':
    case 'u':
      {
        ResetTrailStates();
        detachInterrupt(digitalPinToInterrupt(ACQ_S_PIN));
        Serial.println("Unmount start trigger!");
      }
      break;

    case 'S':
    case 's':
      {
        ResetTrailStates();
        emState = TRIAL_START;
      }
      break;

    case 'E':
    case 'e':
      {
        ResetTrailStates();
      }
      break;

    case 'R':
    case 'r':
      {
        ResetTrailStates();
        lDist_Abs_Pre = 0;
        lDist_Abs = 0;
        Serial.println("Reset");
      }
      break;

    case 'X':
    case 'x':
    case 'B':
    case 'b':
      {
        if (inChar == 'B' || inChar == 'b')
        {
          MtMsg[1] = 1;
        }
        else
        {
          MtMsg[1] = 18;
        }
        Serial2.write(MtMsg, 6);
      }
      break;

    case 'P':
    case 'p':
      {
        iPumpTime = 0;
        resetTimer1();
        resumeTimer1();
      }

    default:
      break;
  }

  while (Serial.available() > 0)
  {
    Serial.read();
  }
}

void PumpAction()
{
  // bAction = true;
  int iLickVal = digitalRead(LICK_INPUT_PIN);
  digitalWrite(LICK_IND_PIN, iLickVal);
  if (iLickVal == HIGH )
  {
    if (iLickAftPump == 0 && digitalRead(PumpTTL_PIN) != PUMP_START)
    {
      digitalWrite(PumpTTL_PIN, PUMP_START);
      resetTimer1();
      resumeTimer1();
      lFeed++;
      Serial.print("Feed:");
      Serial.println(lFeed);
      //      if(lFeed == 1200)
      //      {
      //        pauseTimer3();
      //        digitalWrite(SND_TRIG_PIN,HIGH);
      //        digitalWrite(SHOCK_TRIG,LOW);
      //        bRunning = false;
      //        bStateChanged = true;
      //        emState = TRIAL_START;
      //        MtMsg[1] = 1;
      //        Serial2.write(MtMsg,6);
      //        Serial.println("Auto Stopped!");
      //      }
    }
    iLickAftPump++;
    if (iLickAftPump >= iConsumption)
    {
      iLickAftPump = 0;
    }
  }
}

void StartTrg()
{
  lTimer = 0;
  bStateChanged = true;
  emState = TRIAL_START;
  Serial.println("TRIAL_S");
}

void StartShk()
{
  if (emState == CUE_START || emState == CUE_DELAY)
  {
    emState = SHOCK_S;
    bStateChanged = true;
    //Serial.println("SHOCK_S");
  }
}

void EncoderCal()
{
  lDist_Abs++;
  if (digitalRead(ENCODER_B_PIN) == HIGH)
  {
    lDist_Rel++;
  }
  else
  {
    lDist_Rel--;
  }
}
// Define the function which will handle the notifications
ISR(timer1Event)
{
  if (iPumpTime < iAutoPump)
  {
    if (iPumpTime % 2 == 0)
    {
      digitalWrite(PumpTTL_PIN, PUMP_START);
    }
    else
    {
      digitalWrite(PumpTTL_PIN, !PUMP_START);
    }
    iPumpTime++;
  }
  else
  {
    pauseTimer1();
    digitalWrite(PumpTTL_PIN, !PUMP_START);
  }
}

ISR(timer3Event)
{
  lTimer++;
  //Serial.print("TimeLoop:");
  //Serial.println(lTimer);
  //Serial.println(lTimerLoops);
  if (lTimer < lTimerLoops)
  {
    resetTimer3();
    resumeTimer3();
  }
  else
  {
    pauseTimer3();
    if (lTimer == lTimerLoops && lTimerResidual > 0)
    {
      startTimer3(lTimerResidual);
    }
    else
    {
      switch (emState)
      {
        case TRIAL_START:
          {
            emState = SPOUT_OUT;
            //Serial.println("TRIAL_START_e");
          }
          break;

        case SPOUT_OUT:
          {
            emState = CUE_START;
          }
          break;

        case CUE_START:
          {
            digitalWrite(SND_TRIG_PIN, HIGH);
            emState = CUE_DELAY;
            //Serial.println("CUE_START_e");
          }
          break;


        case SHOCK_S:
          {
            digitalWrite(SHOCK_TRIG, LOW);
            emState = SHOCK_E;
            lShock++;
            Serial.print("Shock:");
            Serial.println(lShock);
          }
          break;

        case SHOCK_E:
          {
            emState = SPOUT_IN;
          }
          break;

        case SPOUT_IN:
          {
            emState = TRIAL_END;
          }
          break;

        default:
          break;
      }

      bStateChanged = true;
      lTimer = 0;
    }
  }
}

ISR(timer4Event)
{
  resetTimer4();
  lSpeed_Abs = lDist_Abs - lDist_Abs_Pre;
  if (lSpeed_Abs)
  {
    Serial.print("Dist_Abs: ");
    Serial.print(lDist_Abs);
    Serial.print(" Speed(Rel,Abs): (");
    Serial.print(lDist_Rel);
    Serial.print(",");
    Serial.print(lSpeed_Abs);
    Serial.println(")");
    lDist_Rel = 0;
    lDist_Abs_Pre = lDist_Abs;
  }
}

void ResetTrailStates()
{
  lTimer = 0;
  lFeed = 0;
  iLickAftPump = 0;
  lShock = 0;
  resetTimer3();
  pauseTimer3();
  digitalWrite(SND_TRIG_PIN, HIGH);
  digitalWrite(SHOCK_TRIG, LOW);
  emState = TRIAL_END;
  bStateChanged = true;
}







