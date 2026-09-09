# 🌊 Calista — IoT-Based Swimming Pool Monitoring System

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)
![C++](https://img.shields.io/badge/C++-00599C?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![Arduino](https://img.shields.io/badge/Arduino-00979D?style=for-the-badge&logo=arduino&logoColor=white)

Calista is an innovative, IoT-based swimming pool monitoring and management system designed to track water quality, monitor chemical levels, and automate pool maintenance.

By combining an ESP8266-based hardware prototype with a Flutter mobile application and Firebase Realtime Database, Calista provides seamless, real-time monitoring and centralized data management.

---

## 📋 Table of Contents
- [Overview](#-overview)
- [Key Features](#-key-features)
- [System Architecture](#-system-architecture)
- [Technologies Used](#-technologies-used)
- [Database Structure](#-database-structure)
- [Getting Started](#-getting-started)
- [Hardware Connections](#-hardware-connections)
- [pH Control Logic](#-ph-control-logic)
- [Testing](#-testing)
- [Security Considerations](#-security-considerations)
- [Current Status](#-current-status)
- [Future Improvements](#-future-improvements)
- [Project Goals](#-project-goals)
- [Contributors](#-contributors)
- [License](#-license)

---

## 📖 Overview

Maintaining optimal swimming pool water quality requires consistent monitoring of pH levels and chemical supplies. Calista simplifies this process by integrating IoT sensors and actuators with an intuitive mobile application.

The ESP8266 microcontroller collects pH sensor data and communicates directly with the Firebase Realtime Database. The Flutter application then retrieves this information and presents it through a user-friendly interface.

**The project consists of three main components:**
1. **IoT Hardware**
2. **Firebase Backend**
3. **Flutter Mobile Application**

---

## ✨ Key Features

- **💧 Real-Time pH Monitoring:** Reads pH values using an ESP8266 and sends them to Firebase. The app retrieves and displays the current water quality status.
- **🧪 Chemical Tank Monitoring:** Supports monitoring of acid and base chemical tank levels. Displays alerts in the app when supplies are running low.
- **⚙️ Automated Chemical Control:** Automatically adjusts chemicals based on the measured pH value:
  - **High pH:** Activates the acid dosing pump.
  - **Low pH:** Activates the base dosing pump.
  - **Normal pH:** Keeps pumps inactive.
- **📅 Scheduled Monitoring:** Users can configure a scheduled monitoring time via the app, which is stored in Firebase and accessed by the IoT device.
- **📊 pH History:** Stores scheduled pH readings (pH value, date, and time) in Firebase, allowing users to track changes in water quality over time.
- **👤 User Profile:** Manage user-related information directly from the mobile app.

---

## 🏗 System Architecture

### Application & Data Flow
```text
pH Sensor
    │
    ▼
 ESP8266
    │ (Wi-Fi)
    ▼
Firebase Realtime Database
    │
    ▼
Flutter Mobile Application
    ├── Dashboard
    ├── pH Monitoring
    ├── Chemical Levels
    ├── Schedule
    ├── History
    └── User Profile
```

### Automated Chemical Control Logic
```text
pH Sensor
    │
    ▼
 ESP8266
    │
    ▼
pH Evaluation
    ├── High pH ────► Acid Relay ────► Acid Pump
    ├── Normal ─────► Pumps OFF
    └── Low pH ─────► Base Relay ────► Base Pump
```

---

## 💻 Technologies Used

### Mobile Application
- **Framework:** Flutter, Dart
- **Services:** Firebase Authentication, Firebase Realtime Database

### IoT
- **Microcontroller:** NodeMCU ESP8266
- **Sensors/Actuators:** pH Sensor, Ultrasonic Sensors, Dual-Channel Relay Module, DC Pumps
- **Connectivity:** Wi-Fi

### Backend
- **Database:** Firebase Realtime Database
- **Auth:** Firebase Authentication

### Development Tools
- Visual Studio Code / Android Studio
- Arduino IDE
- Firebase Console
- Git & GitHub

---

## 🗄 Database Structure

The project uses Firebase Realtime Database to store real-time sensor data, chemical levels, schedules, and historical measurements.

**Example Structure:**
```json
calista
├── phData
│   └── currentPH
├── chemicalTank
│   ├── acid
│   └── base
├── schedule
│   ├── enabled
│   └── time
└── history
    └── generated_record_id
        ├── ph
        ├── date
        └── time
```

---

## 🚀 Getting Started

### Prerequisites
Before running the project, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio or Visual Studio Code
- Arduino IDE with ESP8266 board support
- A Firebase Project

### 1. Clone the Repository
```bash
git clone https://github.com//calista.git
cd calista
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
Create a Firebase project and configure it for the Flutter application. Enable **Firebase Authentication** and **Firebase Realtime Database**. Update your Firebase configuration files accordingly.

### 4. Configure the ESP8266
Open `Calista.ino` in the Arduino IDE and configure your credentials:
```cpp
#define WIFI_SSID "YOUR_WIFI_NAME"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

#define API_KEY "YOUR_FIREBASE_API_KEY"
#define DATABASE_URL "YOUR_FIREBASE_DATABASE_URL"
```
Select the appropriate ESP8266 board and COM port, then compile and upload the sketch.

### 5. Run the Flutter Application
Connect an Android device or start an emulator and run:
```bash
flutter run
```

---

## 🔌 Hardware Connections

The prototype uses an ESP8266, pH sensor, ultrasonic sensors, a dual-channel relay module, and DC pumps.

**Relay Control:**
- `ESP8266 D1` ➔ `Relay IN1` (Acid Pump)
- `ESP8266 D2` ➔ `Relay IN2` (Base Pump)
- `ESP8266 GND` ➔ `Relay GND`

> **Note:** The pumps must be powered using an appropriate external power supply. **Do not** power the pumps directly from the ESP8266.

---

## 🔬 pH Control Logic

The prototype evaluates the measured pH value and determines the appropriate pump state. Thresholds can be configured based on pool requirements and sensor calibration.

- **pH > upper threshold** ➔ Acid Pump **ON**
- **Normal pH** ➔ Pumps **OFF**
- **pH < lower threshold** ➔ Base Pump **ON**

---

## 🧪 Testing

The project was tested in stages to verify individual components before full system integration.

### Software Testing
- Firebase connection & real-time database updates
- Flutter Firebase data retrieval & synchronization
- UI/UX verification for pH display, schedules, and history

### Hardware Testing
- ESP8266 Wi-Fi connectivity stability
- pH and ultrasonic sensor calibration/readings
- Relay switching and pump activation
- Automated pH control logic validation

---

## 🛡 Security Considerations

- Configure **Firebase Realtime Database Rules** appropriately before deployment. Development rules are not suitable for production.
- Handle API keys and configuration values securely. Do not commit sensitive credentials to a public repository.

---

## 📌 Current Status

The Calista project successfully features:
- A fully functional Flutter mobile application.
- Firebase Realtime Database integration.
- An ESP8266 IoT prototype with real-time pH and chemical tank monitoring.
- Automated schedule management and pH history tracking.
- User authentication and profile functionality.

---

## 🔮 Future Improvements

- **Push Notifications:** Alerts for critical pH and chemical levels.
- **Sensor Upgrades:** More accurate pH calibration, improved chemical-level sensors, and water temperature monitoring.
- **Analytics:** Graph-based historical data visualization and advanced water-quality analytics.
- **Hardware Enhancements:** Remote pump control, flow-rate monitoring, and a production-ready hardware enclosure.
- **App Optimization:** Continued performance and security improvements.

---

## 🎯 Project Goals

Calista aims to demonstrate the seamless integration of IoT hardware, cloud services, and mobile application development into a unified system that modernizes swimming pool monitoring and maintenance.

This project also serves as practical experience in IoT development, real-time data communication, and automated control systems.

---

## 👥 Contributors

Developed as a collaborative team project by:
- **Navod Pehesara**
- **Dilki Silva**
- **Wasana Bandara**

*Contributions, suggestions, and improvements are always welcome!*

---

## 📄 License

This project is intended for educational and development purposes.