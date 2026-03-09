// lib/models/user_model.dart
//
// PURPOSE: Dart representation of a Firestore document in the `users` collection.
// fromMap()  → converts raw Firestore data into a usable Dart object  (READ)
// toMap()    → converts this object into Firestore-compatible map      (WRITE)
// copyWith() → creates a modified copy without mutating the original   (UPDATE)

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  // ── Firestore → Dart ───────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid:         uid,
      email:       (map['email']       as String?)  ?? '',
      displayName: (map['displayName'] as String?),
      // Firestore stores dates as Timestamp; convert to DateTime
      createdAt:   (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Dart → Firestore ───────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'uid':       uid,
    'email':     email,
    if (displayName != null) 'displayName': displayName,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  // ── Immutable update ───────────────────────────────────────────
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) => UserModel(
    uid:         uid         ?? this.uid,
    email:       email       ?? this.email,
    displayName: displayName ?? this.displayName,
    createdAt:   createdAt   ?? this.createdAt,
  );

  @override
  String toString() => 'UserModel(uid: $uid, email: $email)';
}
