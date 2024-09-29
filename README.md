# Trade Stream

Trade Stream is a Flutter application for real-time trading instrument tracking and visualization.



## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Running Tests](#running-tests)


## Features

- Real-time trading instrument data
- Interactive price charts
- Market selector for different trading markets
- Search functionality for instruments
- Detailed view for individual instruments

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Flutter SDK
- Dart SDK
- An IDE (e.g., Android Studio, VS Code) with Flutter and Dart plugins installed
- Git for version control

## Getting Started

To get a local copy up and running, follow these steps:

1. Clone the repository:
   ```
   git clone https://github.com/ayaanpathan/trade_stream.git
   ```

2. Navigate to the project directory:
   ```
   cd trade_stream
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Set up your API key:
   - Create a file named `.env` in the root directory
   - Go to https://finnhub.io/ and register to get the free API key 
   - Add your Finnhub API key:
     ```
     API_KEY=your_finnhub_api_key_here
     ```

## Running the App

To run the app, use the following command:

```
flutter run
```

This will launch the app on your connected device or emulator.

## Running Tests

To run all tests, use the following command:

```
flutter test
```

To run a specific test file:

```
flutter test test/path/to/test_file.dart
```
