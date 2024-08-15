import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider {
  Future<UserCredential?> createSinginAccount(
    context, {
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    } catch (e) {
      rethrow;
    }
    return userCredential;
  }

  Future<UserCredential?> loginAuth(
    context, {
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw e.toString();
    }
    return userCredential;
  }

  Future<UserCredential?> createEmailAccount({
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw e.toString();
    }
    return userCredential;
  }

  Future updateAdminAuth({
    required String oldEmail,
    required String email,
    required String oldPassword,
    required String password,
    required String uid,
  }) async {
    try {
      await FirebaseAuth.instance.signOut();
      UserCredential? userCredential;
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: oldEmail,
        password: oldPassword,
      );
      if (userCredential.user != null) {
        userCredential.user!
          ..updateEmail(email)
          ..updatePassword(password).then((value) {
            log("Update Success");
          });
      }
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> deleteAuth({
    required String uid,
    required String oldEmail,
    required String oldPassword,
  }) async {
    try {
      await FirebaseAuth.instance.signOut();
      UserCredential? userCredential;
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: oldEmail,
        password: oldPassword,
      );
      if (userCredential.user != null) {
        await userCredential.user!.delete().then((value) {
          return true;
        });
      }
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool?> updateUserLogin({
    required String email,
    required String password,
    required String oldEmail,
    required String oldPassword,
  }) async {
    try {
      UserCredential? userCredential;
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: oldEmail,
        password: oldPassword,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateEmail(email).catchError((onError) {
          throw onError.toString();
        }).then((value) async {
          await userCredential!.user!.updatePassword(password).then((value) {
            return true;
          });
        }).catchError((onError) {
          throw onError.toString();
        });
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
    return null;
  }
}
