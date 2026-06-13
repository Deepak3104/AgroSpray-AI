# AgroSpray

AgroSpray is a Flutter mobile application for crop management, pesticide recommendations, spray scheduling, reports, and user profile management.

## Stack

- Flutter with Material Design 3
- Provider for state management
- Firebase Authentication
- Cloud Firestore
- SharedPreferences for local storage
- PDF export and local notifications

## Project Structure

```text
lib/
  core/
  models/
  services/
  repositories/
  providers/
  screens/
  widgets/
  utils/
```

## Setup

1. Install the latest stable Flutter SDK.
2. Run `flutter pub get` in the project root.
3. Configure Firebase for Android and iOS with FlutterFire.
4. Replace the placeholder values in `lib/firebase_options.dart` with the generated Firebase options.
5. Enable Email/Password authentication in Firebase Authentication.
6. Create a Cloud Firestore database.
7. Run the app with `flutter run`.

## Firebase Configuration

The app expects these Firebase services:

- Firebase Authentication for login, registration, password reset, and password updates.
- Cloud Firestore for users, crops, schedules, reports, and recommendation records.

## Firestore Schema

### `users`

```json
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "photoUrl": "string | null",
  "phone": "string | null",
  "role": "farmer",
  "createdAt": "ISO-8601 string",
  "updatedAt": "ISO-8601 string"
}
```

### `crops`

```json
{
  "userId": "string",
  "name": "string",
  "variety": "string",
  "fieldArea": 0,
  "plantingDate": "ISO-8601 string",
  "status": "Active | Harvested | Monitoring",
  "notes": "string",
  "createdAt": "ISO-8601 string",
  "updatedAt": "ISO-8601 string"
}
```

### `schedules`

```json
{
  "userId": "string",
  "cropId": "string",
  "title": "string",
  "scheduledAt": "ISO-8601 string",
  "reminderMinutesBefore": 30,
  "status": "Scheduled",
  "notes": "string",
  "createdAt": "ISO-8601 string",
  "updatedAt": "ISO-8601 string"
}
```

### `reports`

```json
{
  "userId": "string",
  "title": "string",
  "type": "pdf",
  "fileUrl": "string",
  "generatedAt": "ISO-8601 string",
  "summary": "string"
}
```

### `pesticide_recommendations`

```json
{
  "cropType": "string",
  "issue": "string",
  "recommendedPesticide": "string",
  "dosage": "string",
  "precautions": "string",
  "notes": "string"
}
```

## Features

- Splash screen with delayed navigation
- Secure email/password authentication
- Home dashboard with statistics and quick actions
- Crop add/edit/delete/history flows
- Pesticide recommendation lookup
- Spray scheduling with calendar view and local reminders
- Reports list with PDF export
- Profile update, password change, dark mode, and logout

## Notes

- The project targets Flutter stable and uses Material 3 themes.
- Run `flutterfire configure` if you want FlutterFire to generate platform-specific Firebase options automatically.
- The current `lib/firebase_options.dart` file contains placeholders that must be replaced before running against a real Firebase project.
