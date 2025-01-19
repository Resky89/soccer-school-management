# Soccer School Management System
[![Flutter Version](https://img.shields.io/badge/Flutter-Latest-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A comprehensive mobile application built with Flutter for soccer school administrators to manage operations, assessments, and team organization. Backend API integration with [fauzantaslim/soccer-school-api](https://github.com/fauzantaslim/soccer-school-api).

## 📚 Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Backend Integration](#backend-integration)
- [Environment Configuration](#environment-configuration)

## Overview
Soccer School Management System is a Flutter-based administrative application designed for staff and coaches to manage soccer school operations. The application provides a comprehensive interface for managing assessments, coaches, departments, and team categories.

## Project Structure
```
lib/
├── Layout/
├── Controllers/
├── Models/
├── Routes/
├── Views/
│   ├── aspek_sub.dart
│   ├── aspek.dart
│   ├── assessment_setting.dart
│   ├── assessment.dart
│   ├── coach_team_category.dart
│   ├── coach.dart
│   ├── departement.dart
│   ├── home.dart
│   ├── info_detail.dart
│   ├── info.dart
│   ├── login.dart
│   ├── management.dart
│   ├── point_rate.dart
│   ├── profile.dart
│   ├── schedule.dart
│   ├── student_detail.dart
│   ├── students.dart
│   └── team_category.dart
└── main.dart
```

## Features

### Administrative Functions
The application includes the following management modules:

- Staff Authentication & Authorization
- Department Management
- Coach Management & Team Assignment
- Assessment Configuration
  - Aspect Settings
  - Sub-aspect Configuration
  - Assessment Criteria
  - Point Rating System
- Team Category Organization
- Student Records Management
- Schedule Administration
- Information Management System
- Profile Management

## Getting Started

### Prerequisites
- Flutter SDK: Latest version
- Dart: 2.19.0 or higher
- iOS 11.0+ / Android 5.0+
- Backend server running [soccer-school-api](https://github.com/fauzantaslim/soccer-school-api)

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/soccer-school-management.git
cd soccer-school-management
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up environment variables:
```bash
cp .env.example .env
```

4. Configure your `.env` file:
```plaintext
# API Configuration
API_BASE_URL=http://your-backend-url
API_VERSION=v1

# Authentication
AUTH_TOKEN_KEY=your_auth_token_key

# Other Configuration
APP_NAME=Soccer School Management
DEBUG_MODE=true
```

5. Run the application:
```bash
flutter run
```

## Backend Integration
The application integrates with [fauzantaslim/soccer-school-api](https://github.com/fauzantaslim/soccer-school-api) for all data operations.

### API Configuration
API endpoints are configured using environment variables:

```dart
// Example API configuration using .env
class ApiConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
}
```

### Environment Setup
1. Create a `.env` file in the project root
2. Configure the necessary environment variables
3. Access environment variables in the code using:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

// Usage
String apiUrl = dotenv.env['API_BASE_URL'];
```

### API Integration Example
```dart
Future<void> fetchData() async {
  final url = '${ApiConfig.apiBaseUrl}/endpoint';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${dotenv.env['AUTH_TOKEN_KEY']}',
      'Content-Type': 'application/json',
    },
  );
  // Handle response
}
```

## Security Considerations
- Environment variables for sensitive configuration
- Secure authentication token handling
- Data validation and sanitization
- Comprehensive error handling
- Audit logging for administrative actions
