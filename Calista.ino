#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <time.h>

// =====================================================
// WIFI
// =====================================================

// =========================
// WiFi
// =========================
#define WIFI_SSID "TC40"
#define WIFI_PASSWORD "12345678q"

// =========================
// Firebase
// =========================
#define API_KEY "AIzaSyB-oc-r4e0O9LpJ5OXhhtnHTrtauHjot3M"
#define DATABASE_URL "https://calista-836a4-default-rtdb.firebaseio.com/"

// =====================================================
// RELAYS
// =====================================================

#define ACID_RELAY D1
#define BASE_RELAY D2

// =====================================================
// PH SENSOR
// =====================================================

#define PH_PIN A0

#define PH7_ADC 963.0
#define ADC_PER_PH 55.8

#define PH_LOW 6.5
#define PH_HIGH 8.0

// =====================================================
// ULTRASONIC SENSORS
// =====================================================

// Acid tank
#define ACID_TRIG D5
#define ACID_ECHO D6

// Base tank
#define BASE_TRIG D7
#define BASE_ECHO D8

// =====================================================
// TANK CALIBRATION
// =====================================================

#define ACID_FULL_DISTANCE 3.0
#define BASE_FULL_DISTANCE 3.0

#define ACID_EMPTY_DISTANCE 12.0
#define BASE_EMPTY_DISTANCE 12.0

// =====================================================
// DOSING
// =====================================================

#define PUMP_TIME 5000
#define WAIT_TIME 10000
#define MAX_DOSING_CYCLES 20

// =====================================================
// SENSOR INTERVAL
// =====================================================

#define SENSOR_INTERVAL 2000

// =====================================================
// HISTORY INTERVAL
// =====================================================

// Save one history record every 5 minutes
#define HISTORY_INTERVAL 300000UL

// =====================================================
// FIREBASE
// =====================================================

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// =====================================================
// VARIABLES
// =====================================================

float currentPH = 7.0;

float acidDistance = -1;
float baseDistance = -1;

float acidLevel = -1;
float baseLevel = -1;

int dosingCycles = 0;

bool waitingAfterDose = false;
unsigned long waitStartTime = 0;

// =====================================================
// SCHEDULE
// =====================================================

bool scheduleEnabled = false;
String scheduleTime = "";

bool scheduleRunning = false;

int lastRunDay = -1;

// =====================================================
// TIME
// =====================================================

int currentHour = -1;
int currentMinute = -1;
int currentSecond = -1;

// =====================================================
// TIMERS
// =====================================================

unsigned long lastSensorRead = 0;
unsigned long lastScheduleRead = 0;
unsigned long lastFirebaseStatus = 0;

unsigned long lastHistoryUpload = 0;

// =====================================================
// STOP PUMPS
// =====================================================

void stopPumps()
{
  digitalWrite(ACID_RELAY, HIGH);
  digitalWrite(BASE_RELAY, HIGH);

  Serial.println(">>> BOTH PUMPS OFF");
}

// =====================================================
// UPDATE TIME
// =====================================================

void updateTime()
{
  time_t now = time(nullptr);

  if (now < 100000)
  {
    return;
  }

  struct tm *timeinfo = localtime(&now);

  currentHour = timeinfo->tm_hour;
  currentMinute = timeinfo->tm_min;
  currentSecond = timeinfo->tm_sec;
}

// =====================================================
// PRINT TIME
// =====================================================

void printCurrentTime()
{
  updateTime();

  Serial.print("Current Sri Lanka Time: ");

  if (currentHour < 10)
    Serial.print("0");

  Serial.print(currentHour);

  Serial.print(":");

  if (currentMinute < 10)
    Serial.print("0");

  Serial.print(currentMinute);

  Serial.print(":");

  if (currentSecond < 10)
    Serial.print("0");

  Serial.println(currentSecond);
}

// =====================================================
// GET DATE STRING
// =====================================================

String getDateString()
{
  time_t now = time(nullptr);

  if (now < 100000)
  {
    return "0000-00-00";
  }

  struct tm *timeinfo = localtime(&now);

  char dateBuffer[11];

  sprintf(
    dateBuffer,
    "%04d-%02d-%02d",
    timeinfo->tm_year + 1900,
    timeinfo->tm_mon + 1,
    timeinfo->tm_mday
  );

  return String(dateBuffer);
}

// =====================================================
// GET TIME STRING
// =====================================================

String getTimeString()
{
  time_t now = time(nullptr);

  if (now < 100000)
  {
    return "00:00";
  }

  struct tm *timeinfo = localtime(&now);

  char timeBuffer[6];

  sprintf(
    timeBuffer,
    "%02d:%02d",
    timeinfo->tm_hour,
    timeinfo->tm_min
  );

  return String(timeBuffer);
}

// =====================================================
// READ PH
// =====================================================

float readPH()
{
  long total = 0;

  const int samples = 20;

  for (int i = 0; i < samples; i++)
  {
    total += analogRead(PH_PIN);
    delay(10);
  }

  float adc = total / (float)samples;

  float ph =
    7.0 + ((PH7_ADC - adc) / ADC_PER_PH);

  if (ph < 0)
    ph = 0;

  if (ph > 14)
    ph = 14;

  Serial.println();
  Serial.println("===== PH SENSOR =====");

  Serial.print("ADC: ");
  Serial.println(adc, 2);

  Serial.print("Calculated pH: ");
  Serial.println(ph, 2);

  if (ph < PH_LOW)
  {
    Serial.println("pH STATUS: TOO LOW");
  }
  else if (ph > PH_HIGH)
  {
    Serial.println("pH STATUS: TOO HIGH");
  }
  else
  {
    Serial.println("pH STATUS: NORMAL");
  }

  Serial.println("=====================");

  return ph;
}

// =====================================================
// READ ULTRASONIC DISTANCE
// =====================================================

float readDistance(int trigPin, int echoPin)
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);

  digitalWrite(trigPin, LOW);

  unsigned long duration =
    pulseIn(echoPin, HIGH, 30000);

  if (duration == 0)
  {
    return -1;
  }

  float distance =
    duration * 0.0343 / 2.0;

  return distance;
}

// =====================================================
// CALCULATE LEVEL
// =====================================================

float calculateLevel(
  float distance,
  float fullDistance,
  float emptyDistance
)
{
  if (distance < 0)
  {
    return -1;
  }

  if (distance <= fullDistance)
  {
    return 100.0;
  }

  if (distance >= emptyDistance)
  {
    return 0.0;
  }

  float level =
    ((emptyDistance - distance) /
     (emptyDistance - fullDistance)) * 100.0;

  if (level < 0)
    level = 0;

  if (level > 100)
    level = 100;

  return level;
}

// =====================================================
// READ BOTH TANKS
// =====================================================

void readTankLevels()
{
  Serial.println();
  Serial.println("===== ULTRASONIC SENSORS =====");

  // -------------------------------
  // ACID
  // -------------------------------

  acidDistance =
    readDistance(
      ACID_TRIG,
      ACID_ECHO
    );

  if (acidDistance < 0)
  {
    Serial.println("ACID SENSOR: NO ECHO");
    acidLevel = -1;
  }
  else
  {
    acidLevel =
      calculateLevel(
        acidDistance,
        ACID_FULL_DISTANCE,
        ACID_EMPTY_DISTANCE
      );

    Serial.print("Acid Distance: ");
    Serial.print(acidDistance, 2);
    Serial.println(" cm");

    Serial.print("Acid Tank Level: ");
    Serial.print(acidLevel, 1);
    Serial.println("%");
  }

  delay(100);

  // -------------------------------
  // BASE
  // -------------------------------

  baseDistance =
    readDistance(
      BASE_TRIG,
      BASE_ECHO
    );

  if (baseDistance < 0)
  {
    Serial.println("BASE SENSOR: NO ECHO");
    baseLevel = -1;
  }
  else
  {
    baseLevel =
      calculateLevel(
        baseDistance,
        BASE_FULL_DISTANCE,
        BASE_EMPTY_DISTANCE
      );

    Serial.print("Base Distance: ");
    Serial.print(baseDistance, 2);
    Serial.println(" cm");

    Serial.print("Base Tank Level: ");
    Serial.print(baseLevel, 1);
    Serial.println("%");
  }

  Serial.println("==============================");
}

// =====================================================
// UPLOAD CURRENT PH
// =====================================================

void uploadPH()
{
  if (
    Firebase.RTDB.setFloat(
      &fbdo,
      "/phData/currentPH",
      currentPH
    )
  )
  {
    Serial.println("pH uploaded to Firebase");
  }
  else
  {
    Serial.print("pH upload ERROR: ");
    Serial.println(fbdo.errorReason());
  }
}

// =====================================================
// UPLOAD TANK LEVELS
// =====================================================

void uploadTankLevels()
{
  if (acidLevel >= 0)
  {
    if (
      Firebase.RTDB.setFloat(
        &fbdo,
        "/chemicalTank/acid",
        acidLevel
      )
    )
    {
      Serial.println("Acid tank level uploaded");
    }
    else
    {
      Serial.print("Acid level ERROR: ");
      Serial.println(fbdo.errorReason());
    }
  }

  if (baseLevel >= 0)
  {
    if (
      Firebase.RTDB.setFloat(
        &fbdo,
        "/chemicalTank/base",
        baseLevel
      )
    )
    {
      Serial.println("Base tank level uploaded");
    }
    else
    {
      Serial.print("Base level ERROR: ");
      Serial.println(fbdo.errorReason());
    }
  }
}

// =====================================================
// ⭐ SAVE HISTORY
// =====================================================

void saveHistory()
{
  if (!Firebase.ready())
  {
    Serial.println("History: Firebase not ready");
    return;
  }

  updateTime();

  // Make a new unique ID under /history
  String historyPath = "/history";

  FirebaseJson historyData;

  historyData.set(
    "date",
    getDateString()
  );

  historyData.set(
    "time",
    getTimeString()
  );

  historyData.set(
    "ph",
    currentPH
  );

  Serial.println();
  Serial.println("===== SAVING HISTORY =====");

  Serial.print("Date: ");
  Serial.println(getDateString());

  Serial.print("Time: ");
  Serial.println(getTimeString());

  Serial.print("pH: ");
  Serial.println(currentPH, 2);

  if (
    Firebase.RTDB.pushJSON(
      &fbdo,
      historyPath,
      &historyData
    )
  )
  {
    Serial.println("HISTORY SAVED SUCCESSFULLY!");

    Serial.print("History ID: ");
    Serial.println(fbdo.pushName());
  }
  else
  {
    Serial.print("HISTORY ERROR: ");
    Serial.println(fbdo.errorReason());
  }

  Serial.println("==========================");
}

// =====================================================
// READ SCHEDULE
// =====================================================

void readSchedule()
{
  if (!Firebase.ready())
    return;

  if (
    Firebase.RTDB.getBool(
      &fbdo,
      "/schedule/enabled"
    )
  )
  {
    scheduleEnabled =
      fbdo.boolData();
  }
  else
  {
    Serial.print("Schedule enabled error: ");
    Serial.println(fbdo.errorReason());
  }

  if (
    Firebase.RTDB.getString(
      &fbdo,
      "/schedule/time"
    )
  )
  {
    scheduleTime =
      fbdo.stringData();

    scheduleTime.trim();
  }
  else
  {
    Serial.print("Schedule time error: ");
    Serial.println(fbdo.errorReason());
  }

  Serial.println();
  Serial.println("===== SCHEDULE =====");

  Serial.print("Enabled: ");
  Serial.println(
    scheduleEnabled ? "TRUE" : "FALSE"
  );

  Serial.print("Database Time: ");
  Serial.println(scheduleTime);

  printCurrentTime();

  Serial.println("====================");
}

// =====================================================
// CHECK SCHEDULE TIME
// =====================================================

bool isScheduleTime()
{
  if (!scheduleEnabled)
    return false;

  if (scheduleTime.length() == 0)
    return false;

  int colon =
    scheduleTime.indexOf(':');

  if (colon < 0)
    return false;

  int targetHour =
    scheduleTime.substring(
      0,
      colon
    ).toInt();

  int targetMinute =
    scheduleTime.substring(
      colon + 1
    ).toInt();

  updateTime();

  return (
    currentHour == targetHour &&
    currentMinute == targetMinute
  );
}

// =====================================================
// ALREADY RAN TODAY
// =====================================================

bool alreadyRanToday()
{
  time_t now = time(nullptr);

  if (now < 100000)
    return false;

  struct tm *timeinfo =
    localtime(&now);

  int today =
    timeinfo->tm_yday;

  return lastRunDay == today;
}

// =====================================================
// START SCHEDULE
// =====================================================

void startScheduledRun()
{
  if (alreadyRanToday())
    return;

  Serial.println();
  Serial.println("################################");
  Serial.println("     SCHEDULE TIME REACHED");
  Serial.println("     CALISTA STARTING");
  Serial.println("################################");

  scheduleRunning = true;

  dosingCycles = 0;

  waitingAfterDose = false;

  time_t now = time(nullptr);

  struct tm *timeinfo =
    localtime(&now);

  lastRunDay =
    timeinfo->tm_yday;
}

// =====================================================
// ACID DOSING
// =====================================================

void doseAcid()
{
  Serial.println();
  Serial.println("################################");
  Serial.println("pH TOO HIGH");
  Serial.println("ACID DOSING START");
  Serial.println("################################");

  digitalWrite(BASE_RELAY, HIGH);

  digitalWrite(ACID_RELAY, LOW);

  Serial.println("ACID PUMP: ON");
  Serial.println("Duration: 5 seconds");

  unsigned long start = millis();

  while (millis() - start < PUMP_TIME)
  {
    delay(100);
  }

  digitalWrite(ACID_RELAY, HIGH);

  Serial.println("ACID PUMP: OFF");

  waitingAfterDose = true;

  waitStartTime = millis();

  dosingCycles++;

  Serial.print("Dosing Cycle: ");
  Serial.println(dosingCycles);

  Serial.println("Waiting 10 seconds...");
}

// =====================================================
// BASE DOSING
// =====================================================

void doseBase()
{
  Serial.println();
  Serial.println("################################");
  Serial.println("pH TOO LOW");
  Serial.println("BASE DOSING START");
  Serial.println("################################");

  digitalWrite(ACID_RELAY, HIGH);

  digitalWrite(BASE_RELAY, LOW);

  Serial.println("BASE PUMP: ON");
  Serial.println("Duration: 5 seconds");

  unsigned long start = millis();

  while (millis() - start < PUMP_TIME)
  {
    delay(100);
  }

  digitalWrite(BASE_RELAY, HIGH);

  Serial.println("BASE PUMP: OFF");

  waitingAfterDose = true;

  waitStartTime = millis();

  dosingCycles++;

  Serial.print("Dosing Cycle: ");
  Serial.println(dosingCycles);

  Serial.println("Waiting 10 seconds...");
}

// =====================================================
// PH CONTROL
// =====================================================

void runPHControl()
{
  if (!scheduleRunning)
    return;

  // -------------------------------
  // WAIT AFTER DOSING
  // -------------------------------

  if (waitingAfterDose)
  {
    unsigned long elapsed =
      millis() - waitStartTime;

    if (elapsed < WAIT_TIME)
    {
      Serial.print(
        "Waiting after chemical dosing: "
      );

      Serial.print(
        (WAIT_TIME - elapsed) / 1000
      );

      Serial.println(" seconds");

      delay(1000);

      return;
    }

    waitingAfterDose = false;

    Serial.println();
    Serial.println(
      "10 second waiting completed."
    );

    Serial.println(
      "Rechecking pH..."
    );
  }

  // -------------------------------
  // MAX SAFETY
  // -------------------------------

  if (
    dosingCycles >= MAX_DOSING_CYCLES
  )
  {
    stopPumps();

    scheduleRunning = false;

    Serial.println();
    Serial.println("################################");
    Serial.println("MAX DOSING LIMIT REACHED");
    Serial.println("SYSTEM STOPPED FOR SAFETY");
    Serial.println("################################");

    return;
  }

  // -------------------------------
  // READ PH
  // -------------------------------

  currentPH = readPH();

  uploadPH();

  // -------------------------------
  // NORMAL
  // -------------------------------

  if (
    currentPH >= PH_LOW &&
    currentPH <= PH_HIGH
  )
  {
    stopPumps();

    dosingCycles = 0;

    scheduleRunning = false;

    // Save final pH after dosing
    saveHistory();

    Serial.println();
    Serial.println("################################");
    Serial.println("       WATER pH IS NORMAL");
    Serial.println("       NO DOSING REQUIRED");
    Serial.println("       SCHEDULE RUN COMPLETE");
    Serial.println("################################");

    return;
  }

  // -------------------------------
  // LOW → BASE
  // -------------------------------

  if (currentPH < PH_LOW)
  {
    doseBase();
    return;
  }

  // -------------------------------
  // HIGH → ACID
  // -------------------------------

  if (currentPH > PH_HIGH)
  {
    doseAcid();
    return;
  }
}

// =====================================================
// PRINT SYSTEM STATUS
// =====================================================

void printSystemStatus()
{
  Serial.println();
  Serial.println("================================");
  Serial.println("       CALISTA STATUS");
  Serial.println("================================");

  printCurrentTime();

  Serial.print("Firebase: ");
  Serial.println(
    Firebase.ready()
      ? "READY"
      : "NOT READY"
  );

  Serial.print("Schedule Enabled: ");
  Serial.println(
    scheduleEnabled
      ? "YES"
      : "NO"
  );

  Serial.print("Schedule Time: ");
  Serial.println(scheduleTime);

  Serial.print("Schedule Running: ");
  Serial.println(
    scheduleRunning
      ? "YES"
      : "NO"
  );

  Serial.print("pH: ");
  Serial.println(currentPH, 2);

  Serial.print("Acid Tank: ");

  if (acidLevel >= 0)
  {
    Serial.print(acidLevel, 1);
    Serial.println("%");
  }
  else
  {
    Serial.println("NO READING");
  }

  Serial.print("Base Tank: ");

  if (baseLevel >= 0)
  {
    Serial.print(baseLevel, 1);
    Serial.println("%");
  }
  else
  {
    Serial.println("NO READING");
  }

  Serial.print("Dosing Cycles: ");
  Serial.println(dosingCycles);

  Serial.println("================================");
}

// =====================================================
// SETUP
// =====================================================

void setup()
{
  Serial.begin(115200);

  delay(1000);

  // ===================================================
  // RELAYS
  // ===================================================

  pinMode(ACID_RELAY, OUTPUT);
  pinMode(BASE_RELAY, OUTPUT);

  stopPumps();

  // ===================================================
  // ULTRASONIC
  // ===================================================

  pinMode(ACID_TRIG, OUTPUT);
  pinMode(ACID_ECHO, INPUT);

  pinMode(BASE_TRIG, OUTPUT);
  pinMode(BASE_ECHO, INPUT);

  digitalWrite(ACID_TRIG, LOW);
  digitalWrite(BASE_TRIG, LOW);

  // ===================================================
  // START
  // ===================================================

  Serial.println();
  Serial.println("================================");
  Serial.println("        CALISTA IoT");
  Serial.println("================================");

  // ===================================================
  // WIFI
  // ===================================================

  Serial.println();
  Serial.println("Connecting to WiFi...");

  WiFi.begin(
    WIFI_SSID,
    WIFI_PASSWORD
  );

  while (
    WiFi.status() != WL_CONNECTED
  )
  {
    Serial.print(".");
    delay(500);
  }

  Serial.println();
  Serial.println("WiFi CONNECTED!");

  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  Serial.print("WiFi RSSI: ");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");

  // ===================================================
  // TIME
  // ===================================================

  Serial.println();
  Serial.println(
    "Synchronizing Sri Lanka time..."
  );

  configTime(
    19800,
    0,
    "pool.ntp.org",
    "time.nist.gov",
    "time.google.com"
  );

  for (int i = 0; i < 20; i++)
  {
    time_t now = time(nullptr);

    if (now > 100000)
      break;

    Serial.print(".");
    delay(500);
  }

  Serial.println();

  printCurrentTime();

  // ===================================================
  // FIREBASE
  // ===================================================

  Serial.println();
  Serial.println("Starting Firebase...");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  Firebase.begin(
    &config,
    &auth
  );

  Firebase.reconnectWiFi(true);

  // ===================================================
  // ANONYMOUS LOGIN
  // ===================================================

  Serial.println(
    "Signing in anonymously..."
  );

  if (
    Firebase.signUp(
      &config,
      &auth,
      "",
      ""
    )
  )
  {
    Serial.println(
      "ANONYMOUS LOGIN SUCCESS!"
    );
  }
  else
  {
    Serial.println(
      "ANONYMOUS LOGIN FAILED!"
    );

    Serial.println(
      config.signer.signupError.message.c_str()
    );
  }

  Serial.println();
  Serial.println("================================");
  Serial.println("       SYSTEM READY");
  Serial.println("================================");

  // Force first sensor reading
  lastSensorRead = millis() - SENSOR_INTERVAL;

  // Force first history record
  lastHistoryUpload = millis() - HISTORY_INTERVAL;
}

// =====================================================
// LOOP
// =====================================================

void loop()
{
  // ===================================================
  // FIREBASE
  // ===================================================

  if (!Firebase.ready())
  {
    Serial.println();
    Serial.println("FIREBASE NOT READY");

    stopPumps();

    delay(2000);

    return;
  }

  // ===================================================
  // SCHEDULE
  // ===================================================

  if (
    millis() - lastScheduleRead >= 10000
  )
  {
    lastScheduleRead = millis();

    readSchedule();
  }

  // ===================================================
  // CHECK SCHEDULE
  // ===================================================

  if (
    !scheduleRunning &&
    isScheduleTime()
  )
  {
    startScheduledRun();
  }

  // ===================================================
  // READ SENSORS
  // ===================================================

  if (
    millis() - lastSensorRead >= SENSOR_INTERVAL
  )
  {
    lastSensorRead = millis();

    // pH
    currentPH = readPH();

    // Ultrasonic
    readTankLevels();

    // Firebase
    uploadPH();

    uploadTankLevels();
  }

  // ===================================================
  // ⭐ HISTORY
  // ===================================================

  if (
    millis() - lastHistoryUpload >= HISTORY_INTERVAL
  )
  {
    lastHistoryUpload = millis();

    saveHistory();
  }

  // ===================================================
  // PH CONTROL
  // ===================================================

  runPHControl();

  // ===================================================
  // STATUS
  // ===================================================

  if (
    millis() - lastFirebaseStatus >= 10000
  )
  {
    lastFirebaseStatus = millis();

    printSystemStatus();
  }

  delay(100);
}