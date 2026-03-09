import GoogleMaps
// inside didFinishLaunchingWithOptions, before return:
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

## Step F — Firestore Security Rules
Paste in Firebase Console → Firestore → Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /listings/{id} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth != null
                            && resource.data.createdBy == request.auth.uid;
      match /reviews/{rid} {
        allow read: if request.auth != null;
        allow create: if request.auth != null
                      && request.resource.data.userId == request.auth.uid;
      }
    }
  }
}