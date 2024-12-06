# **ESP32-Sensor-Data-Mobile-App**

## **Overview**  
During my internship, I worked on developing an IoT-based system that integrates a mobile application, an embedded IoT device, and a backend infrastructure.  
- The project features a **mobile application** built using **Flutter**, which interfaces with an ESP32 microcontroller programmed in **Embedded C** with the **ESP-IDF framework**.  
- The ESP32 collects environmental data from a **DHT11 sensor** and sends it to a backend system, designed with **PHP**, **MySQL**, and **phpMyAdmin**.  
- The backend is responsible for managing data storage and retrieval, while the mobile app uses **APIs** to fetch and display the data in real time, delivering a seamless and user-friendly experience.  

---

## **Key Features**  
- **Real-time Data Collection**:  
   The ESP32 collects temperature and humidity data from the DHT11 sensor and sends it to the backend via Wi-Fi.  

- **Backend Management**:  
   PHP scripts process and store the sensor data in a **MySQL database**, ensuring efficient and reliable data management.  

- **Mobile Application**:  
   A Flutter-based mobile app interacts with the backend and ESP32 to display real-time sensor readings in an intuitive and user-friendly interface.  

---

## **Project Structure**  
```plaintext
ESP32-Sensor-Data-Mobile-App/
│
├── mobile-app/                     
│   └── lib/                     # Flutter app source code    
│
├── backend/                     # PHP scripts for database interactions
│  
└── embedded/                    
    ├── src/                     
    │   ├── main.c               # Main ESP32 source code
    │   └── my_data.h            # Header files for ESP32
```
---

## Workflow
- The ESP32 collects data from the DHT11 sensor and sends it to the backend using HTTP requests.
- The backend stores the data in a MySQL database and exposes it via APIs.
- The mobile application fetches the sensor data from the backend in real time and displays it through a clean and interactive interface.

---

## Technologies Used

### Mobile Application
- **Framework**: Flutter
- **Languages**: Dart

### Backend
- **Programming Language**: PHP
- **Database**: MySQL
- **Database Management Tool**: phpMyAdmin

### Embedded System
- **Microcontroller**: ESP32
- **Framework**: ESP-IDF
- **Sensor**: DHT11
