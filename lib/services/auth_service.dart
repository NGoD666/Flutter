import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register dan simpan ke Firestore
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Simpan user ke Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.code}');
      return null;
    }
  }

  // Login + validasi user juga ada di Firestore
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Validasi data user ada di Firestore
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (!doc.exists) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
