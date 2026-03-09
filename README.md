# Kigali Services Directory

A comprehensive directory and mapping application for services in Kigali, Rwanda. Built with Flutter, this app helps users discover, navigate to, and manage service listings with a real-time map interface and Firebase integration.

## 🚀 Features

- **Service Directory:** Browse through a wide range of services available in Kigali.
- **Interactive Map:** View service locations using OpenStreetMap (via `flutter_map`).
- **User Authentication:** Secure sign-up and login with Firebase Auth.
- **Listing Management:** Users can add, edit, and manage their own service listings.
- **Real-time Data:** Powered by Cloud Firestore for instant updates.
- **Navigation:** Deep links to external maps for guidance to service locations.

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

