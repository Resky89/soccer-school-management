# Soccer School Management

[![Flutter Version](https://img.shields.io/badge/Flutter-Latest-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A comprehensive mobile application built with Flutter for managing soccer school operations, including student registrations, coach scheduling, and performance tracking.

## 📚 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Requirements](#system-requirements)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Architecture](#architecture)
- [Usage](#usage)
- [API Integration](#api-integration)

## Overview

Soccer School Management is a Flutter-based application designed to streamline the administrative operations of soccer schools. The application provides an intuitive interface for managing students, coaches, training sessions, and performance analytics. Our backend is developed in collaboration with [fauzantaslim/soccer-school-api](https://github.com/fauzantaslim/soccer-school-api).

## Features

### Student Management
- Student registration and profile management
- Attendance tracking
- Performance assessment
- Progress reports generation

### Coach Administration
- Coach profile management
- Schedule organization
- Training session planning
- Performance evaluation tools

### Training Management
- Session scheduling
- Match organization
- Equipment inventory
- Facility management

### Analytics & Reporting
- Student progress tracking
- Attendance reports
- Performance analytics
- Financial reporting

## System Requirements

- Flutter SDK: Latest version
- Dart: 2.19.0 or higher
- iOS 11.0+ / Android 5.0+
- Minimum 2GB RAM
- 500MB free storage space

## Getting Started

### Prerequisites

Before installation, ensure you have the following:
- Flutter SDK installed ([Installation Guide](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code with Flutter plugins
- Git installed
- A suitable IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Resky89/soccer-school-management.git
cd soccer-school-management
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:
```bash
cp .env.example .env
```
Edit the `.env` file with your configuration settings.

4. Run the application:
```bash
flutter run
```

## Architecture

The project follows a clean architecture pattern with the following structure:

```
lib/
├── core/
│   ├── config/
│   ├── constants/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── themes/
└── main.dart
```

## Usage

After installation, you can:

1. Launch the application
2. Log in with your administrator credentials
3. Navigate through the dashboard to access various features
4. Manage students, coaches, and schedules
5. Generate reports and analytics

## API Integration

The application integrates with our backend API for data management:

```dart
// Configure API endpoint in lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://examplelocalhost:3000';
  
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
}
```

For detailed API documentation, visit the [backend repository](https://github.com/fauzantaslim/soccer-school-api).
