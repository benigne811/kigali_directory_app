# Kigali Directory App

## Overview

The Kigali Directory App is a mobile application developed using **Flutter** and **Firebase**.  
The purpose of the application is to allow users to discover, manage, and explore local listings such as businesses, services, or places in Kigali.

The app allows authenticated users to create, view, edit, and delete listings while also displaying locations on an embedded map.

---

# Features

## 1. User Authentication
The application uses Firebase Authentication to manage user accounts.

Users can:
- Register with an email and password
- Log in with existing credentials
- Log out of the application
- Simulate email verification during account creation

Authentication ensures that only logged-in users can access the main features of the application.

---

## 2. Directory / Browse Listings
The directory screen displays all available listings stored in the Firestore database.

Users can:
- View a list of available listings
- Open a listing to view its details
- Search listings by name
- Filter listings by category

---

## 3. My Listings
Authenticated users can manage their own listings.

Users can:
- Create new listings
- Edit existing listings
- Delete listings
- View only listings created by their account

---

## 4. Map View
The application integrates **Google Maps** to display listing locations.

Users can:
- View the location of a listing on a map
- Launch navigation directions to the location

---

## 5. Listing Details
Each listing contains detailed information including:

- Title
- Description
- Category
- Location
- Owner information

Users can open a listing to see the full details and map location.

---

## 6. Settings Screen
The settings screen displays user account information and app preferences.

It includes:

- Authenticated user email
- Logout functionality
- Location-based notification toggle (simulated locally)

The notification toggle allows the user to enable or disable location-based alerts.

---

# Navigation Structure

The application uses a **Bottom Navigation Bar** with the following sections:

1. Directory (Browse Listings)
2. My Listings
3. Map View
4. Settings

This allows easy navigation between the core features of the app.

---

# Firestore Database Structure

The application stores its data using **Cloud Firestore**.

## Collections

### users

Stores information about authenticated users.

Example document structure:

```
users
  └── userId
        ├── email: string
        ├── createdAt: timestamp
```

---

### listings

Stores all listings created by users.

Example structure:

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

Each listing is associated with the user who created it through the `createdBy` field.

---

# State Management Approach

The application uses **Provider-based state management** to handle application state and data flow.

## Providers Used

### AuthProvider

Manages authentication state and communicates with Firebase Authentication.

Responsibilities include:
- User login
- User registration
- User logout
- Managing the authenticated user state

---

### ListingProvider

Handles all listing-related operations and communicates with Firestore.

Responsibilities include:
- Fetching listings
- Creating listings
- Updating listings
- Deleting listings
- Managing listing data in the UI

---

# Service Layer

The project follows a layered architecture.

## AuthService

Handles Firebase Authentication operations such as:

- Sign up
- Sign in
- Sign out

---

## ListingService

Handles all interactions with Firestore including:

- Reading listings
- Writing listings
- Updating listings
- Deleting listings

---

# Project Architecture

The application follows a modular folder structure:

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

This structure separates responsibilities and keeps the project organized.

---

# Technologies Used

- Flutter
- Firebase Authentication
- Cloud Firestore
- Google Maps Flutter
- Provider (state management)

---

# Conclusion

The Kigali Directory App demonstrates how Flutter can be integrated with Firebase to build a fully functional mobile application that supports authentication, real-time database operations, and location-based services.

The project focuses on clean architecture, modular design, and scalable state management.
