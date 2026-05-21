import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static const _timeout = Duration(seconds: 15);

  // ═══════════════════════════════════════════════════════
  // INSCRIPTION
  // ═══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(_timeout);

      final userInfo = {
        'uid': credential.user!.uid,
        'email': email,
        'role': role,
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userInfo)
          .timeout(_timeout);

      return _cleanData(userInfo);
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e.code);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // CONNEXION
  // ═══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(_timeout);

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get()
          .timeout(_timeout);

      if (doc.exists) {
        return _cleanData(doc.data()!);
      }

      throw 'Compte introuvable';
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e.code);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // DÉCONNEXION
  // ═══════════════════════════════════════════════════════
  static Future<void> signOut() async {
    try {
      await _auth.signOut().timeout(_timeout);
    } catch (e) {
      debugPrint('❌ signOut error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════
  // UTILISATEUR ACTUEL
  // ═══════════════════════════════════════════════════════
  static User? get currentUser => _auth.currentUser;

  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get()
          .timeout(_timeout);

      if (doc.exists) {
        return _cleanData(doc.data()!);
      }
    } on TimeoutException {
      debugPrint('❌ getCurrentUserData timeout');
    } catch (e) {
      debugPrint('❌ getCurrentUserData error: $e');
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════
  // COMPTES
  // ═══════════════════════════════════════════════════════
  static Future<List<Map<String, dynamic>>> loadAllAccounts() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .get()
          .timeout(_timeout);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firebaseUserId'] = doc.id;
        return _cleanData(data);
      }).toList();
    } on TimeoutException {
      debugPrint('❌ loadAllAccounts timeout');
      return [];
    } catch (e) {
      debugPrint('❌ loadAllAccounts error: $e');
      return [];
    }
  }

  static Future<void> updateAccount(
    String firebaseUserId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(firebaseUserId)
          .update(data)
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur modification: $e';
    }
  }

  static Future<void> deleteAccountDoc(String firebaseUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(firebaseUserId)
          .delete()
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur suppression: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // ÉLÈVES
  // ═══════════════════════════════════════════════════════
  static Future<List<Map<String, dynamic>>> loadAllStudents() async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .get()
          .timeout(_timeout);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firebaseId'] = doc.id;
        return _cleanData(data);
      }).toList();
    } on TimeoutException {
      debugPrint('❌ loadAllStudents timeout');
      return [];
    } catch (e) {
      debugPrint('❌ loadAllStudents error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadStudentsByClass(
    String className,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .where('className', isEqualTo: className)
          .get()
          .timeout(_timeout);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firebaseId'] = doc.id;
        return _cleanData(data);
      }).toList();
    } on TimeoutException {
      debugPrint('❌ loadStudentsByClass timeout');
      return [];
    } catch (e) {
      debugPrint('❌ loadStudentsByClass error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadStudentsByCycle(
    String cycle,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .where('cycle', isEqualTo: cycle)
          .get()
          .timeout(_timeout);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firebaseId'] = doc.id;
        return _cleanData(data);
      }).toList();
    } on TimeoutException {
      debugPrint('❌ loadStudentsByCycle timeout');
      return [];
    } catch (e) {
      debugPrint('❌ loadStudentsByCycle error: $e');
      return [];
    }
  }

  static Future<String> addStudent(Map<String, dynamic> student) async {
    try {
      final docRef = await _firestore
          .collection('students')
          .add({...student, 'createdAt': FieldValue.serverTimestamp()})
          .timeout(_timeout);
      return docRef.id;
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur ajout élève: $e';
    }
  }

  static Future<void> updateStudent(
    String firebaseId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('students')
          .doc(firebaseId)
          .update(data)
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur modification élève: $e';
    }
  }

  static Future<void> deleteStudent(String firebaseId) async {
    try {
      await _firestore
          .collection('students')
          .doc(firebaseId)
          .delete()
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur suppression élève: $e';
    }
  }

  static Future<void> clearClass(String className) async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .where('className', isEqualTo: className)
          .get()
          .timeout(_timeout);

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit().timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur vidage classe: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // NOTES
  // ═══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> loadAllGrades() async {
    try {
      final snapshot = await _firestore
          .collection('grades')
          .get()
          .timeout(_timeout);

      final result = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        result[doc.id] = doc.data();
      }
      return result;
    } on TimeoutException {
      debugPrint('❌ loadAllGrades timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadAllGrades error: $e');
      return {};
    }
  }

  static Future<void> saveGrades(
    String key,
    Map<String, dynamic> grades,
  ) async {
    try {
      await _firestore
          .collection('grades')
          .doc(key)
          .set(grades)
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur sauvegarde notes: $e';
    }
  }

  static Future<Map<String, dynamic>> loadGradesForClass(String key) async {
    try {
      final doc = await _firestore
          .collection('grades')
          .doc(key)
          .get()
          .timeout(_timeout);

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {};
    } on TimeoutException {
      debugPrint('❌ loadGradesForClass timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadGradesForClass error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> loadGradesForClassName(
    String className,
  ) async {
    try {
      final start = '${className}_';
      final end = '$start\uf8ff';

      final snapshot = await _firestore
          .collection('grades')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
          .where(FieldPath.documentId, isLessThanOrEqualTo: end)
          .get()
          .timeout(_timeout);

      final result = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        result[doc.id] = doc.data();
      }
      return result;
    } on TimeoutException {
      debugPrint('❌ loadGradesForClassName timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadGradesForClassName error: $e');
      return {};
    }
  }

  // ═══════════════════════════════════════════════════════
  // ABSENCES
  // ═══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> loadAllAttendance() async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .get()
          .timeout(_timeout);

      final result = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        result[doc.id] = doc.data();
      }
      return result;
    } on TimeoutException {
      debugPrint('❌ loadAllAttendance timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadAllAttendance error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> loadAttendanceForClass(
    String className,
  ) async {
    try {
      final start = '${className}_';
      final end = '$start\uf8ff';

      final snapshot = await _firestore
          .collection('attendance')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
          .where(FieldPath.documentId, isLessThanOrEqualTo: end)
          .get()
          .timeout(_timeout);

      final result = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        result[doc.id] = doc.data();
      }
      return result;
    } on TimeoutException {
      debugPrint('❌ loadAttendanceForClass timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadAttendanceForClass error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> loadAttendanceForDate(
    String dateKey,
  ) async {
    try {
      final doc = await _firestore
          .collection('attendance')
          .doc(dateKey)
          .get()
          .timeout(_timeout);

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {};
    } on TimeoutException {
      debugPrint('❌ loadAttendanceForDate timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadAttendanceForDate error: $e');
      return {};
    }
  }

  static Future<void> saveAttendance(
    String dateKey,
    Map<String, dynamic> attendance,
  ) async {
    try {
      await _firestore
          .collection('attendance')
          .doc(dateKey)
          .set(attendance)
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur sauvegarde: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // PAIEMENTS
  // ═══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> loadAllPayments() async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .get()
          .timeout(_timeout);

      final result = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        result[doc.id] = doc.data()['list'] ?? [];
      }
      return result;
    } on TimeoutException {
      debugPrint('❌ loadAllPayments timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadAllPayments error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> loadPaymentsForClass(
    String className,
  ) async {
    try {
      final start = '${className}_';
      final end = '$start\uf8ff';

      final snapshot = await _firestore
          .collection('payments')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
          .where(FieldPath.documentId, isLessThanOrEqualTo: end)
          .get()
          .timeout(_timeout);

      final result = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        result[doc.id] = doc.data()['list'] ?? [];
      }
      return result;
    } on TimeoutException {
      debugPrint('❌ loadPaymentsForClass timeout');
      return {};
    } catch (e) {
      debugPrint('❌ loadPaymentsForClass error: $e');
      return {};
    }
  }

  static Future<List<dynamic>> loadStudentPayments(String key) async {
    try {
      final doc = await _firestore
          .collection('payments')
          .doc(key)
          .get()
          .timeout(_timeout);

      if (doc.exists) {
        return (doc.data()?['list'] ?? []) as List<dynamic>;
      }
      return [];
    } on TimeoutException {
      debugPrint('❌ loadStudentPayments timeout');
      return [];
    } catch (e) {
      debugPrint('❌ loadStudentPayments error: $e');
      return [];
    }
  }

  static Future<void> saveStudentPayments(
    String key,
    List<dynamic> payments,
  ) async {
    try {
      await _firestore
          .collection('payments')
          .doc(key)
          .set({'list': payments})
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur sauvegarde: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // COURS / CORRIGÉS
  // ═══════════════════════════════════════════════════════
  static Future<List<Map<String, dynamic>>> loadContent(String key) async {
    try {
      final doc = await _firestore
          .collection('content')
          .doc(key)
          .get()
          .timeout(_timeout);

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          return (data['items'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
      return [];
    } on TimeoutException {
      debugPrint('❌ loadContent timeout');
      return [];
    } catch (e) {
      debugPrint('❌ loadContent error: $e');
      return [];
    }
  }

  static Future<void> saveContent(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      await _firestore
          .collection('content')
          .doc(key)
          .set({'items': items})
          .timeout(_timeout);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur sauvegarde: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // NETTOYER LES DONNÉES
  // ═══════════════════════════════════════════════════════
  static Map<String, dynamic> _cleanData(Map<String, dynamic> data) {
    final cleanData = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Timestamp) {
        cleanData[key] = value.toDate().toIso8601String();
      } else if (value is FieldValue) {
        cleanData[key] = DateTime.now().toIso8601String();
      } else {
        cleanData[key] = value;
      }
    });
    return cleanData;
  }

  // ═══════════════════════════════════════════════════════
  // MESSAGES D'ERREUR
  // ═══════════════════════════════════════════════════════
  static String _getAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email existe déjà';
      case 'weak-password':
        return 'Mot de passe trop faible (min 6 caractères)';
      case 'invalid-email':
        return 'Email invalide';
      case 'network-request-failed':
        return 'Pas de connexion internet';
      default:
        return 'Erreur de connexion';
    }
  }

  // ═══════════════════════════════════════════════════════
  // MOT DE PASSE OUBLIÉ
  // ═══════════════════════════════════════════════════════
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).timeout(_timeout);
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e.code);
    } on TimeoutException {
      throw 'Délai dépassé. Vérifiez votre connexion.';
    } catch (e) {
      throw 'Erreur: $e';
    }
  }

  // ═══════════════════════════════════════════════════════
  // ANNONCES
  // ═══════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> loadAnnouncements() async {
    try {
      final snapshot = await _firestore.collection('announcements').get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _cleanData(data);
      }).toList();

      list.sort((a, b) {
        final dateA = a['date']?.toString() ?? '';
        final dateB = b['date']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<void> addAnnouncement(String title, String message) async {
    await _firestore.collection('announcements').add({
      'title': title,
      'message': message,
      'date': FieldValue.serverTimestamp(),
    });

    // Créer notifications pour tous les utilisateurs
    try {
      final users = await _firestore.collection('users').get();
      for (var user in users.docs) {
        if (user.data()['role'] != 'admin') {
          await _firestore.collection('notifications').add({
            'userId': user.id,
            'title': '📢 Nouvelle annonce',
            'message': title,
            'type': 'announcement',
            'date': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      }
    } catch (e) {
      // erreur notifications
    }
  }

  static Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  // ═══════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> loadMessages(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('participants', arrayContains: userId)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _cleanData(data);
      }).toList();

      list.sort((a, b) {
        final dateA = a['date']?.toString() ?? '';
        final dateB = b['date']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<void> sendMessage({
    required String fromUserId,
    required String fromName,
    required String toUserId,
    required String toName,
    required String message,
  }) async {
    await _firestore.collection('messages').add({
      'fromUserId': fromUserId,
      'fromName': fromName,
      'toUserId': toUserId,
      'toName': toName,
      'message': message,
      'participants': [fromUserId, toUserId],
      'date': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Créer notification
    try {
      await _firestore.collection('notifications').add({
        'userId': toUserId,
        'title': '💬 Nouveau message',
        'message': 'De: $fromName',
        'type': 'message',
        'date': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      // erreur notification
    }
  }

  // ═══════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> loadNotifications(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _cleanData(data);
      }).toList();

      list.sort((a, b) {
        final dateA = a['date']?.toString() ?? '';
        final dateB = b['date']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      int count = 0;
      for (var doc in snapshot.docs) {
        if (doc.data()['read'] == false) count++;
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> markNotificationAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'read': true});
  }

  static Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        if (doc.data()['read'] == false) {
          await doc.reference.update({'read': true});
        }
      }
    } catch (e) {
      // erreur
    }
  }

  // ═══════════════════════════════════════════════════════
  // MESSAGE À UNE CLASSE
  // ═══════════════════════════════════════════════════════

  static Future<void> sendMessageToClass({
    required String fromUserId,
    required String fromName,
    required String className,
    required String message,
  }) async {
    // Trouver tous les parents/élèves de cette classe
    final users = await _firestore.collection('users').get();

    for (var user in users.docs) {
      final data = user.data();
      final role = data['role'] ?? '';

      bool shouldSend = false;

      if (role == 'student' && data['className'] == className) {
        shouldSend = true;
      }

      if (role == 'parent') {
        final children = data['children'] as List<dynamic>? ?? [];
        for (var child in children) {
          if (child['className'] == className) {
            shouldSend = true;
            break;
          }
        }
      }

      if (shouldSend) {
        await _firestore.collection('messages').add({
          'fromUserId': fromUserId,
          'fromName': fromName,
          'toUserId': user.id,
          'toName': data['parentName'] ?? data['studentName'] ?? '',
          'message': message,
          'className': className,
          'isClassMessage': true,
          'participants': [fromUserId, user.id],
          'date': FieldValue.serverTimestamp(),
          'read': false,
        });

        await _firestore.collection('notifications').add({
          'userId': user.id,
          'title': '💬 Message de l\'école',
          'message': 'Classe $className',
          'type': 'message',
          'date': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    }
  }
}
