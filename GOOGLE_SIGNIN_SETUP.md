# Quick Setup: Google Sign-In for Android

## 🚀 Quick Steps

### 1. Enable Google Sign-In in Firebase
- Go to Firebase Console → **Authentication** → **Sign-in method**
- Enable **Google** provider
- Save

### 2. Add SHA-1 Fingerprint

Get your SHA-1:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Add to Firebase:
- Firebase Console → **Project Settings** → **Android App**
- Click **Add fingerprint**
- Paste SHA-1
- Save

### 3. Run the App
```bash
flutter pub get
flutter run
```

## ✅ Done!

Students can now tap "Continue with Google" on the login screen.

---

**See [google_signin_setup.md](./google_signin_setup.md) for detailed troubleshooting.**
