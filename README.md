# Master's Thesis at UoB
## Introduction
This repository keeps the main pieces of source code for my master's thesis at the University of Bristol. There are two folders:
- Android: This folder includes the code for building my Android app that recieves the data from the Arduino device and summerise users' activities.
- Arduino: This folder stores the Sketch programmes and TinyML model for running a computer vision model on the Arduino.

## Summary of Project
This project proposes a system which helps people to self-monitor their sedentary habits. Nowadays, people spend a considerable amount of time in front of their desks working and studying. Growing evidence has shown that long sedentary time may pose a risk to our health. Therefore, the system aims to provide a way to help people understand how much time they have spent sitting in the past time period. By reviewing the matrices, people can respond positively, such as reducing sitting time or interrupting sitting with physical activities.

The system consists of an Arduino device and an Android application. Unlike other products on the market, the Arduino device with a camera module is placed on a desk, and faces the seat of a user. A computer vision model is the core component that makes the device distinguish between a person sitting or an empty chair. To deploy the model on a source-constrained device, Tiny Machine Learning techniques are applied in the development. The workflow includes training the model by TensorFlow, shrinking it down to small size by TensorFlow Lite and TensorFlow Lite for microcontrollers. The model performance is evaluated to ensure it can successfully identify between objects and is not biased toward edge cases. The binary outcome is produced by the model, which indicates whether a person is sitting on a chair or not. The Arduino device used in this project supports Bluetooth Low Energy (BLE) connection. The BLE connection is used for syncing data between the Arduino, mobile phone, and the cloud database.

Data originates from the Arduino is received by the user's mobile phone. Flutter is the framework for building an application in the project. The application has three main pages, which are the time tracker page, the log page, and the manually registration page. The time tracker page shows today's total sitting time of the user and displays a time series plot of the daily sitting time of the past five days. The log page shows a table of the raw data for making the plot. The manual registration page lets the user add or remove data manually. All users' data is kept on the Firebase. Therefore, several internal functions have been developed for communicating data between the device, the application, and the cloud.

The biggest limitation of the system is that the application can not run in the background. To support the background process, writing a native code in Java or Kotlin is required. Due to the time limit, the development can not be finished in this project, but it will be a top priority in future work. In addition, a more comprehensive training dataset can be collected to refine the model. In general, this project creates a prototype that serves as a great foundation for the development of related products in the future. The added value of the project is a large improvement in my personal development. I learned Sketch programming on Arduino, TinyML workflow, and Android development.
