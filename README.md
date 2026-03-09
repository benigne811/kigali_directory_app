# Kigali Directory App

## Overview

The Kigali Directory App is a mobile application developed using **Flutter** and **Firebase**.  
The application allows users to discover and manage listings such as businesses, services, or places in Kigali.

Users can browse listings, create their own listings, view locations on a map, and manage their account.

---

# Features

## 1. User Authentication
The app uses Firebase Authentication to manage users.

Users can:
- Register with email and password
- Log in with existing credentials
- Log out of the application
- Simulate email verification during signup

---

## 2. Directory / Browse Listings
Users can browse all available listings stored in Firestore.

Features include:
- Viewing available listings
- Searching listings by name
- Filtering listings by category
- Opening listings to see detailed information

---

## 3. My Listings
Users can manage listings they created.

Users can:
- Create new listings
- Edit existing listings
- Delete listings
- View only listings created by them

---

## 4. Map View
The application integrates Google Maps to display listing locations.

Users can:
- View listing locations on the map
- Navigate to the location

---

## 5. Listing Details
Each listing includes:

- Title
- Description
- Category
- Location (latitude and longitude)
- Creator information

---

## 6. Settings Screen
The settings screen includes:

- User account information
- Logout functionality
- Notification toggle for location alerts

---

# Navigation Structure

The application uses a **Bottom Navigation Bar** with the following sections:

1. Directory (Browse Listings)
2. My Listings
3. Map View
4. Settings

---

# Firestore Database Structure

The application uses **Cloud Firestore** to store its data.

## users Collection

Stores user account information.

Example document:

```
users
  └── userId
        ├── email: string
        ├── createdAt: timestamp
```

---

## listings Collection

Stores listings created by users.

Example document:

```
listings
  └── listingId
        ├── title: string
        ├── description: string
        ├── category: string
        ├── latitude: number
        ├── longitude: number
        ├── createdBy: userId
        ├── createdAt: timestamp
```

Each listing is linked to the user who created it through the `createdBy` field.

---

# State Management

The application uses **Provider** for state management.

## AuthProvider

Handles authentication state and communicates with Firebase Authentication.

Responsibilities:
- User login
- User registration
- User logout
- Managing authentication state

---

## ListingProvider

Handles listing operations and Firestore communication.

Responsibilities:
- Fetch listings
- Create listings
- Update listings
- Delete listings
- Manage listing state in the UI

---

# Services

## AuthService
Handles Firebase Authentication logic.

Functions include:
- Sign up
- Sign in
- Sign out

---

## ListingService
Handles Firestore operations for listings.

Functions include:
- Read listings
- Write listings
- Update listings
- Delete listings

---

# Project Structure

```
lib/
│
├── core/
├── models/
├── providers/
├── services/
├── screens/
├── widgets/
│
├── main.dart
└── main_shell.dart
```

This modular structure helps separate concerns and keep the project organized.

---

# Technologies Used

- Flutter
- Firebase Authentication
- Cloud Firestore
- Google Maps Flutter
- Provider (State Management)

---

# How to Access the Project

1. Clone the repository:

```
git clone https://github.com/benigne811/kigali-directory-app.git
```

2. Navigate to the project folder:

```
cd kigali-directory-app
```

3. Install dependencies:

```
flutter pub get
```

---

# How to Run the Application

### Requirements

Make sure the following are installed:

- Flutter SDK
- Android Studio or VS Code
- Android Emulator or Physical Device
- Firebase project configuration

---

### Steps to Run

1. Start an Android emulator or connect a physical Android device.

2. Run the following command in the project folder:

```
flutter run
```

3. The application will build and launch on the emulator or device.

---

# Firebase Configuration

The app requires a Firebase project configured with:

- Firebase Authentication (Email/Password)
- Cloud Firestore database

You must also include the Firebase configuration file:

```
android/app/google-services.json
```

---

# Conclusion

The Kigali Directory App demonstrates how Flutter and Firebase can be used together to build a mobile application with authentication, cloud database storage, and map-based features.

The project follows a modular architecture and uses Provider for scalable state management.
