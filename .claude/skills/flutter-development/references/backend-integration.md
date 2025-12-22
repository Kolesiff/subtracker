# Backend Integration Guide

## Firebase vs Supabase

| Feature | Firebase | Supabase |
|---------|----------|----------|
| Database | NoSQL (Firestore) | PostgreSQL (SQL) |
| Auth | Firebase Auth | Supabase Auth |
| Storage | Cloud Storage | Supabase Storage |
| Real-time | Real-time Database | Real-time subscriptions |
| Pricing | Pay-as-you-go | Free tier generous |
| Open Source | No | Yes |

---

## Firebase Setup

### 1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase
```bash
flutterfire configure
```
This creates `firebase_options.dart` automatically.

### 3. Add Dependencies
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
```

### 4. Initialize Firebase
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Firebase Authentication
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email/Password Sign In
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
```

### Firestore CRUD
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create
  Future<void> createUser(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).set(data);
  }

  // Read single
  Future<DocumentSnapshot> getUser(String id) async {
    return await _firestore.collection(_collection).doc(id).get();
  }

  // Read all
  Future<QuerySnapshot> getAllUsers() async {
    return await _firestore.collection(_collection).get();
  }

  // Read with query
  Future<QuerySnapshot> getUsersByRole(String role) async {
    return await _firestore
        .collection(_collection)
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
  }

  // Update
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update(data);
  }

  // Delete
  Future<void> deleteUser(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Real-time stream
  Stream<QuerySnapshot> usersStream() {
    return _firestore.collection(_collection).snapshots();
  }
}
```

### Firebase Storage
```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }
}
```

---

## Supabase Setup

### 1. Create Supabase Project
- Go to https://supabase.com
- Create new project
- Get Project URL and Anon Key from Settings > API

### 2. Add Dependency
```yaml
dependencies:
  supabase_flutter: ^2.3.0
```

### 3. Initialize Supabase
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}

// Access client anywhere
final supabase = Supabase.instance.client;
```

### Supabase Authentication
```dart
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Email/Password Sign Up
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Email/Password Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // OAuth (Google, Apple, etc.)
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
```

### Supabase Database (PostgreSQL)
```dart
class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'users';

  // Create
  Future<void> createUser(Map<String, dynamic> data) async {
    await _supabase.from(_table).insert(data);
  }

  // Read single
  Future<Map<String, dynamic>?> getUser(String id) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  // Read all
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _supabase.from(_table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Read with query
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('role', role)
        .order('created_at', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  // Update
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _supabase.from(_table).update(data).eq('id', id);
  }

  // Delete
  Future<void> deleteUser(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  // Real-time subscription
  RealtimeChannel subscribeToUsers(void Function(List<Map<String, dynamic>>) callback) {
    return _supabase
        .channel('users_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _table,
          callback: (payload) {
            // Refetch data on change
            getAllUsers().then(callback);
          },
        )
        .subscribe();
  }
}
```

### Supabase Storage
```dart
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFile(File file, String bucket, String path) async {
    await _supabase.storage.from(bucket).upload(path, file);
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _supabase.storage.from(bucket).remove([path]);
  }
}
```

---

## Deep Links Setup (for OAuth)

### Android
`android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="io.supabase.yourapp"
    android:host="login-callback" />
</intent-filter>
```

### Supabase Dashboard
Add redirect URL: `io.supabase.yourapp://login-callback`

---

## Environment Variables

### Using flutter_dotenv
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Create `.env` file (add to .gitignore):
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MyApp());
}
```

## Best Practices

1. **Never expose secrets in code** - Use environment variables
2. **Handle errors gracefully** - Wrap in try-catch
3. **Use offline support** - Both Firebase and Supabase support offline
4. **Implement security rules** - Firestore rules / Supabase RLS
5. **Optimize queries** - Use indexes, limit results
6. **Unsubscribe streams** - Prevent memory leaks
