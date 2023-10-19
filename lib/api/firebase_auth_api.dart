import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<User?> getUser() {
    return auth.authStateChanges();
  }

  Future<String> signIn(
    String email,
    String password,
  ) async {
    UserCredential credential;
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return '';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //possible to return something more useful
        //than just print an error message to improve UI/UX
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return 'Invalid credentials';
      }
    }
  }

  // Future<String> signUp(
  //     String email,
  //     String password,
  //     String firstName,
  //     String lastName,
  //     String dateCreated,
  //     double lowerPH,
  //     double upperPH,
  //     double lowerTemp,
  //     double upperTemp) async {
  //   UserCredential credential;
  //   try {
  //     credential = await auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     if (credential.user != null) {
  //       saveUserToFirestore(credential.user?.uid, email, firstName, lastName,
  //           dateCreated, lowerPH, upperPH, lowerTemp, upperTemp);
  //     }
  //     return '';
  //   } on FirebaseAuthException catch (e) {
  //     //possible to return something more useful
  //     //than just print an error message to improve UI/UX
  //     if (e.code == 'weak-password') {
  //       return 'The password provided is too weak.';
  //     } else if (e.code == 'email-already-in-use') {
  //       return 'The account already exists for that email.';
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return '';
  // }
  Future<String> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String dateCreated,
  ) async {
    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        saveUserToFirestore(
            credential.user?.uid, email, firstName, lastName, dateCreated);
      }
      return '';
    } on FirebaseAuthException catch (e) {
      //possible to return something more useful
      //than just print an error message to improve UI/UX
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print(e);
    }
    return '';
  }

  void signOut() async {
    auth.signOut();
  }

  void saveUserToFirestore(
    String? uid,
    String email,
    String firstName,
    String lastName,
    String dateCreated,
  ) async {
    try {
      await db.collection("users").doc(uid).set({
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "dateCreated": dateCreated,
        "isLoggedIn": false
      });
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
}
