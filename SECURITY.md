# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability within NNG-CINEMA, please report it responsibly. Do not use the public issue tracker for security vulnerabilities.

### Reporting Process

1. Contact the maintainer directly through GitHub
2. Include steps to reproduce the issue
3. Allow reasonable time for the issue to be addressed before public disclosure

---

## Firebase Security

### Firestore Security Rules

The application uses Firestore security rules to restrict access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Watchlist is private to each user
    match /watchlist/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tickets are private to each user
    match /tickets/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile pictures - users can only manage their own
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Firebase Authentication

- Google Sign-In is the primary authentication method
- Email/password authentication is optional
- Implement proper session management

---

## Dependency Security

Regularly audit dependencies for known vulnerabilities:

```bash
flutter pub outdated
```

Update dependencies with security patches promptly.

---

## Contact

For security-related inquiries, contact the repository maintainer through GitHub.

