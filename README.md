Calista — IoT-Based Swimming Pool Monitoring System

Calista is an IoT-based swimming pool monitoring and management system designed to monitor water quality, track chemical levels, and support automated pool maintenance.

The system combines an ESP8266-based hardware prototype with a Flutter mobile application and Firebase Realtime Database to provide real-time monitoring and centralized data management.

Overview

Maintaining appropriate swimming pool water quality requires regular monitoring of pH levels and chemical supplies. Calista aims to simplify this process by connecting IoT sensors and actuators with a mobile application.

The ESP8266 collects pH sensor data and communicates with Firebase Realtime Database. The Flutter application retrieves this information and presents it through a user-friendly interface.

The project consists of three main components:

1. IoT Hardware
2. Firebase Backend
3. Flutter Mobile Application

Key Features

Real-Time pH Monitoring

The system reads pH values from the connected pH sensor using an ESP8266 and sends the readings to Firebase Realtime Database.

The mobile application retrieves the latest pH value and displays the current water quality status.

Chemical Tank Monitoring

The system supports monitoring of acid and base chemical tank levels.

Chemical levels can be displayed in the mobile application to help users identify when supplies are running low.

Automated Chemical Control

The system is designed to support automatic chemical adjustment based on the measured pH value.

Depending on the pH condition:

- High pH can activate the acid dosing pump.
- Low pH can activate the base dosing pump.
- Normal pH keeps the pumps inactive.

The prototype uses relay-controlled pumps for testing the automated control mechanism.

Scheduled Monitoring

Users can configure a scheduled monitoring time through the application.

The configured schedule is stored in Firebase and can be accessed by the IoT device.

pH History

Calista stores scheduled pH readings in Firebase Realtime Database.

The mobile application provides a History screen where users can review previous readings, including:

- pH value
- Date
- Time

This allows users to track changes in pool water quality over time.

User Profile

The application includes a user profile section for managing user-related information.

System Architecture

pH Sensor
    |
    v
ESP8266
    |
    | Wi-Fi
    v
Firebase Realtime Database
    |
    v
Flutter Mobile Application
    |
    +-- Dashboard
    +-- pH Monitoring
    +-- Chemical Levels
    +-- Schedule
    +-- History
    +-- User Profile

For automated chemical control:

pH Sensor
    |
    v
ESP8266
    |
    v
pH Evaluation
    |
    +---- High pH ----> Acid Relay ----> Acid Pump
    |
    +---- Normal -----> Pumps OFF
    |
    +---- Low pH -----> Base Relay ----> Base Pump

Technologies Used

Mobile Application

- Flutter
- Dart
- Firebase Authentication
- Firebase Realtime Database

IoT

- NodeMCU ESP8266
- pH Sensor
- Dual-Channel Relay Module
- DC Pumps
- Wi-Fi

Backend

- Firebase Realtime Database
- Firebase Authentication

Development Tools

- Visual Studio Code
- Arduino IDE
- Firebase Console
- Git
- GitHub


Firebase Database Structure

The project uses Firebase Realtime Database to store real-time sensor data, chemical levels, schedules, and historical measurements.

Example structure:

calista
│
├── phData
│   └── currentPH
│
├── chemicalTank
│   ├── acid
│   └── base
│
├── schedule
│   ├── enabled
│   └── time
│
└── history
    └── generated_record_id
        ├── ph
        ├── date
        └── time

Getting Started

Prerequisites

Before running the project, install:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Arduino IDE
- ESP8266 board support for Arduino IDE
- A Firebase project

1. Clone the Repository

git clone https://github.com//calista.git
cd calista

2. Install Flutter Dependencies

Run:

flutter pub get

3. Configure Firebase

Create a Firebase project and configure Firebase for the Flutter application.

The project uses:

- Firebase Authentication
- Firebase Realtime Database



4. Configure the ESP8266

Open the IoT source code in Arduino IDE.

Configure:

#define WIFI_SSID "YOUR_WIFI_NAME"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

#define API_KEY "YOUR_FIREBASE_API_KEY"
#define DATABASE_URL "YOUR_FIREBASE_DATABASE_URL"

Replace the placeholder values with your own configuration.

Select the appropriate ESP8266 board and COM port, then upload the program.

5. Run the Flutter Application

Connect an Android device or start an Android emulator and run:

flutter run

Hardware Connections

The prototype uses an ESP8266, pH sensor, dual-channel relay module, and DC pumps.

For the relay control:

ESP8266 D1 -> Relay IN1
ESP8266 D2 -> Relay IN2
ESP8266 GND -> Relay GND

The pumps should be powered using an appropriate external power supply. The ESP8266 should not be used to directly power the pumps.

pH Control Logic

The prototype evaluates the measured pH value and determines the appropriate pump state.

pH > upper threshold
        |
        v
   Acid Pump ON

Normal pH
        |
        v
    Pumps OFF

pH < lower threshold
        |
        v
   Base Pump ON

The exact threshold values can be configured according to the requirements of the pool and the calibration of the pH sensor.

Data Flow

The general data flow of the system is:

pH Sensor
    |
    v
ESP8266 reads sensor
    |
    v
pH value calculated
    |
    v
Firebase Realtime Database
    |
    v
Flutter Application
    |
    +---- Dashboard
    |
    +---- History
    |
    +---- Schedule
    |
    +---- Chemical Monitoring

Testing

The project was tested in stages to verify individual components before integrating the complete system.

Software Testing

- Firebase connection testing
- Real-time database update testing
- Flutter Firebase data retrieval
- pH value display testing
- Schedule data synchronization
- History data storage and retrieval

Hardware Testing

- ESP8266 Wi-Fi connectivity
- pH sensor readings
- Relay switching
- Pump activation
- Automated pH control logic

Security Considerations

Firebase Realtime Database rules should be configured appropriately before deploying the system.

Do not use unrestricted database rules in a production environment.

Example development rules should not be considered suitable for production.

API keys and other configuration values should also be handled carefully, especially when publishing the project as a public GitHub repository.

Current Status

The Calista project currently includes:

- Flutter mobile application
- Firebase Realtime Database integration
- ESP8266 IoT prototype
- Real-time pH monitoring
- Chemical tank monitoring
- Schedule management
- pH history tracking
- Relay and pump prototype testing
- User authentication and profile functionality

Future Improvements

Potential future improvements include:

- Push notifications for critical pH and chemical-level alerts
- Cloud-based automated monitoring
- More accurate pH sensor calibration
- Improved chemical-level sensors
- Pump flow-rate monitoring
- Water temperature monitoring
- Advanced water-quality analytics
- Graph-based historical data visualization
- Improved authentication and database security
- Remote pump control
- Production-ready hardware enclosure
- Mobile application performance optimization

Project Goals

The main goal of Calista is to demonstrate how IoT hardware, cloud services, and mobile application development can be integrated into a single system to improve swimming pool monitoring and maintenance.

The project also provides practical experience in:

- IoT development
- Mobile application development
- Cloud database integration
- Real-time data communication
- Hardware and software integration
- Automated control systems

License

This project is intended for educational and development purposes.

If a specific open-source license is required, add the appropriate license file to the repository.

Contributors

Developed as a team project.

-Navod Pehesara
-Dilki Silva
-Wasana Bandara

Contributions, suggestions, and improvements are welcome.