<img width="1323" height="555" alt="book_recommandation" src="https://github.com/user-attachments/assets/022198f2-7238-4394-88ca-2c8e1cba7199" />


### Book Store - Smart Book Recommendation App

A complete, modern **Flutter** application that provides intelligent book recommendations using the Google Books API. Features a smooth, responsive UI optimized for different screen sizes, customized dark/light theming, state-manged bottom navigation, and a robust Firebase backend infrastructure. 

###  Key Features

* ** Smart Book Discovery:** Live search powered by a custom debounce timer (500ms) minimizing redundant API requests and resource overhead.
* ** Efficient Caching System:** Pre-cached catalog sections (Programming, Science, History, Biography, Trending) to ensure zero-latency initial rendering.
* ** Secure Firebase Authentication:** Email-password authentication flow reinforced with real-time email verification guards.
* ** State-Driven Navigation Stack:** Contextual persistent bottom menu seamlessly rendering contextual Home, Reply, Request, and User Profile segments via Provider architecture.
* ** Dynamic Theming & Premium UI:** Fully adaptive, pixel-perfect layouts using custom flutter_screenutil dimensions and enhanced with modern iconsax_flutter design elements.

###  Architecture & Tech Stack

* **Framework:** Flutter (Stable Channel)
* **State Management:** Provider Architecture
* **Backend Infrastructure:** Firebase Core, Firebase Auth, Cloud Firestore, Firebase Storage
* **UI Enhancements:** Flutter ScreenUtil (Adaptive sizing), Iconsax (Modern iconography), Google Books REST API Integration

###  Getting Started

Follow these step-by-step instructions to get a local copy of this project up and running smoothly. 

###  Prerequisites

Ensure your local development environment complies with the verified operational system status: 

* **Flutter SDK:** >=3.47.x (Stable Channel)
* **Java Platform Environment:** OpenJDK 17
* **Android Toolchain SDK Integration:** Build Tools API Level 36.x

###  Local Installation Setup

1. **Clone the Repository:** 

bash

git clone https://github.com/SB-Sagor/books_recommandation.git
cd books_recommandation

Use code with caution.
2. **Acquire Package Dependencies:** 

bash

flutter pub get

Use code with caution.
3. **Backend Credential Integration:** 

  * **Android:** Place your verified google-services.json setup inside the android/app/ subdirectory.
  * **iOS:** Attach your configured GoogleService-Info.plist file within ios/Runner/.
4. **Run Launcher Icons Script:** 

bash

dart run flutter_launcher_icons:main -f pubspec.yaml

Use code with caution.
5. **Wipe Residual System Caches & Run:** 

bash

flutter clean
flutter pub get
flutter run

Use code with caution.

### 🛠️ Pubspec Configuration Structure

The core system depends on the following stable packages specified in the environment manifest layout: 

yaml

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^4.15.0
  provider: ^6.1.5+1
  flutter_screenutil: ^5.9.3
  iconsax_flutter: ^1.0.1
  iconsax: ^0.0.8
  cloud_firestore: ^6.10.0
  firebase_auth: ^6.7.0
  firebase_storage: ^13.6.0
  url_launcher: ^6.3.2
  flutter_launcher_icons: ^0.14.4

Use code with caution.

### 📂 Project Organization Layout

text

lib/
├── common/             # Reusable custom global fields & widgets
├── controller/         # Native helper logics and contextual utilities
├── features/
│   ├── screens/        # Auth stacks (Login, Registration, Password recovery)
│   └── shop/screens/   # Application Core (Home catalog, Request, Reply, Profile)
├── services/           # External API structures & network integrations
└── utils/              # Hardcoded design configurations (Colors, Images, Helpers)

Use code with caution.

###  Contribution Guidelines

1. Fork the Project Repository.
2. Create your Feature Branch (git checkout -b feature/AmazingFeature).
3. Commit your design upgrades (git commit -m 'Add some AmazingFeature').
4. Push to the remote branch (git push origin feature/AmazingFeature).
5. Open a formal Pull Request.
