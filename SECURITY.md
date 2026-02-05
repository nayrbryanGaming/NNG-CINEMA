# Security Policy
For security-related inquiries, contact the repository maintainer through GitHub.

## Contact

---

These are already listed in `.gitignore`.

- `*.jks` - Java keystore files
- `*.keystore` - Android signing keys
- `local.properties` - Local Android SDK configuration
- `GoogleService-Info.plist` - Firebase iOS configuration
- `google-services.json` - Firebase Android configuration
- `.env` - Environment variables with API keys

The following files should never be committed to version control:

## Sensitive Files

---

Update dependencies with security patches promptly.

```
flutter pub outdated
```bash

Regularly audit dependencies for known vulnerabilities:

## Dependency Security

---

- Use Firebase App Check for production
- Implement proper session management
- Email/password authentication is optional
- Google Sign-In is the primary authentication method

### Firebase Authentication

```
}
  }
    }
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    match /profile_pictures/{userId}/{allPaths=**} {
    // Profile pictures - users can only manage their own
  match /b/{bucket}/o {
service firebase.storage {
rules_version = '2';
```javascript

### Firebase Storage Rules

```
}
  }
    }
      allow read, write: if request.auth != null && request.auth.uid == userId;
    match /tickets/{userId}/{document=**} {
    // Tickets are private to each user
    
    }
      allow read, write: if request.auth != null && request.auth.uid == userId;
    match /watchlist/{userId}/{document=**} {
    // Watchlist is private to each user
    
    }
      allow read, write: if request.auth != null && request.auth.uid == userId;
    match /users/{userId} {
    // Users can only access their own data
  match /databases/{database}/documents {
service cloud.firestore {
rules_version = '2';
```javascript

Ensure your Firestore rules restrict access appropriately:

### Firestore Security Rules

## Firebase Security

---

   - Monitor API usage for anomalies
   - Rotate keys periodically
   - Use secure environment variable injection
3. **Production Deployment**

   - Never log or print API keys in build output
   - Use GitHub Secrets for GitHub Actions
   - Store secrets in your CI/CD platform's secret management
2. **CI/CD Pipeline**

   - Ensure `.env` is listed in `.gitignore`
   - Add your API keys to `.env`
   - Copy `.env.example` to `.env`
1. **Local Development**

### Configuration Guidelines

- `FIREBASE_STORAGE_BUCKET` - Firebase Storage bucket URL
- `FIREBASE_PROJECT_ID` - Firebase project identifier
- `FIREBASE_MESSAGING_SENDER_ID` - Firebase Cloud Messaging sender ID
- `FIREBASE_APP_ID` - Firebase application ID
- `FIREBASE_API_KEY` - Firebase project API key
- `WEATHER_API_KEY` - OpenWeatherMap API key
- `TMDB_API_KEY` - The Movie Database API key
**Required Environment Variables:**

This project uses compile-time environment variables for all API keys. Never commit API keys to version control.

### API Key Management

## Security Best Practices

---

3. Allow reasonable time for the issue to be addressed before public disclosure
2. Include steps to reproduce the issue
1. Email the maintainer directly with details of the vulnerability

### Reporting Process

If you discover a security vulnerability within NNG-CINEMA, please report it responsibly. Do not use the public issue tracker for security vulnerabilities.

## Reporting Security Vulnerabilities


