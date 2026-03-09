# Kigali Services Directory

A comprehensive directory and mapping application for services in Kigali, Rwanda. Built with Flutter, this app helps users discover, navigate to, and manage service listings with a real-time map interface and Firebase integration.

## 🚀 Features

- **Service Directory:** Browse through a wide range of services available in Kigali, including categories like Healthcare, Education, and Entertainment.
- **Interactive Map View:** Integrated OpenStreetMap (via `flutter_map`) to visualize service locations and find nearby facilities.
- **User Authentication:** Secure sign-up/login with Firebase Auth, featuring email verification and secure user profiles.
- **Listing Management:** Authenticated users can create, update, and remove their own service listings.
- **Review & Rating System:** Users can provide feedback and rate services to help others find the best quality options.
- **Search & Filter:** Easily find services by name or category.
- **External Navigation:** Quick links to launch external navigation apps for turn-by-turn directions.

## 🗄 Database Structure (Firestore)

The application uses **Cloud Firestore** for its real-time NoSQL database. The structure is organized into the following main collections:

### 1. `listings` Collection
Stores all service-related information.
- `name`: (string) Name of the service.
- `category`: (string) Type of service (e.g., Hospital, School).
- `address`: (string) Physical location description.
- `description`: (string) Details about the service provided.
- `contactNumber`: (string) Phone number for the service.
- `latitude`: (float) Geographic latitude.
- `longitude`: (float) Geographic longitude.
- `createdBy`: (string) UID of the user who added the listing.
- `timestamp`: (timestamp) Creation/last update date.
- `AverageRating`: (float) Aggregated user rating.
- `NumRatings`: (int) Total number of reviews.

### 2. `users` Collection
Stores application-specific user data.
- `uid`: (string) Unique ID from Firebase Auth.
- `email`: (string) User email address.
- `username`: (string) User's display name.
- `isEmailVerified`: (bool) Verification status.

## 🧠 State Management

This project implements the **Provider** pattern for state management, following the **ChangeNotifier** approach. This ensures a clean separation of concerns between business logic and UI.

- **`AuthProvider`**: Manages the user's authentication state (login, registration, logout) and persists the current user's session.
- **`ListingsProvider`**: Handles all CRUD operations for service listings. It listens to real-time updates from Firestore using Streams and notifies the UI when data changes.

---

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore)
- **Maps:** [OpenStreetMap](https://www.openstreetmap.org/) with `flutter_map`
- **State Management:** `Provider`

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `^3.10.3` or higher)
- [Dart SDK](https://dart.dev/get-started/sdk)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

## ⚙️ Getting Started

Since the build files and sensitive configurations are ignored in this repository, follow these steps to get the project running locally:

### 1. Clone the repository
```bash
git clone https://github.com/Tapiwanashe6/kigali-services-repo.git
cd kigali-services-repo
```

### 2. Install dependencies
Fetch the required Flutter packages:
```bash
flutter pub get
```

### 3. Firebase Setup
The project uses Firebase. You will need to set up your own Firebase project:
1. Create a project at the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android and/or iOS app.
3. Download the configuration files:
   - For Android: Place `google-services.json` in `android/app/`.
   - For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`.
4. Enable **Email/Password** authentication and **Cloud Firestore** in the Firebase console.

### 4. Run the app
Ensure you have a simulator/emulator running or a physical device connected:
```bash
flutter run
```

## 📂 Project Structure

- `lib/models/`: Data structures for service listings and users.
- `lib/screens/`: All UI screens (Home, Map, Login, Directory, etc.).
- `lib/providers/`: State management logic using the Provider pattern.
- `lib/services/`: Firebase and external API integration logic.
- `lib/widgets/`: Reusable UI components.

