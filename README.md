# SUEvent
<p align="center">
  <img src="./assets/images/SUEventLogo.png" width="350px"/>
</p>

## What is SUEvent?
SUEvent is a CS310 project designed to help Sabancı University students connect with others who share similar interests. Whether you’d like to watch a movie, play a sport, or engage in other fun activities, SUEvent makes it easy to find someone to join you.

## Why SUEvent?
At Sabancı University, opportunities to socialize outside of student club activities are often limited and difficult to track. Recognizing this challenge, we will create SUEvent to make it easier for Sabanci University members to find opportunities to socialise and connect, as SUEvent will give users the perfect platform to find, track, announce events and other activities with ease.

## Need more information?
Check out [our final report](<./CS310 Team-23 SUEvent Final Report.pdf>) for further details.

# Project Group
| Name    | Student ID |
| -------- | ------- |
| Arda Ösün | 32319 |
| ~Furkan Gönen~* | ~34260~* |
| Mehmet Ali Bağıbala | 33907 |
| Ulaş Deniz | 34034 |
| Yağız Tüten | 33897 |

*Withdrawn after Phase-2 of the project
## Platforms
SUEvent will be available on mobile!

## Database
For the database of SUEvent, [Firebase](https://firebase.google.com/) was used.

## Before Trying to Run the Project
Before you try the project make sure you use ```flutter pub get```

## Setup & Run (Step‑by‑Step)
1. [Install Flutter](https://docs.flutter.dev/install) (tested with Flutter 3.x).
  Verify with: flutter --version
2. Install Dependencies:
   run: flutter pub get
3. Firebase setup:
  Create a Firebase project.
  Enable Firebase Auth (Email/Password).
  Enable Cloud Firestore.
  Add your Android app in Firebase and download google-services.json and place in android/app/.
  Download GoogleService-Info.plist and place in ios/Runner/.
  Update firebase_options.dart with your project config.
4. Run the App
   run: flutter run
5. Run tests
   run: flutter test

## Known Limitations / Bugs
- For an event, a maximum of 3 images can be added due to our storage constraints.
- On some devices, the navigation bar of the app may partially/fully fall behind the navigation buttons of the device itself.
