import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createTask(String title, String description, int points) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('tasks').add({
        'title': title,
        'description': description,
        'points': points,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> getUserTasks() {
    final user = _auth.currentUser;
    if (user != null) {
      return _db
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return Stream.empty();
  }

  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    }
  }

  Future<void> completeTask(String taskId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final taskDoc =
          await _db
              .collection('users')
              .doc(user.uid)
              .collection('tasks')
              .doc(taskId)
              .get();

      if (taskDoc.exists) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final points = taskData['points'] as int;

        await taskDoc.reference.update({'completed': true});

        await updateUserPoints(points);
        await incrementStreak();
      }
    }
  }

  Future<void> createReward(
    String title,
    String description,
    int points,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('rewards').add({
        'title': title,
        'description': description,
        'points': points,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> getUserRewards() {
    final user = _auth.currentUser;
    if (user != null) {
      return _db
          .collection('users')
          .doc(user.uid)
          .collection('rewards')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return Stream.empty();
  }

  Future<void> deleteReward(String rewardId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('rewards')
          .doc(rewardId)
          .delete();
    }
  }

  Future<void> updateReward(
    String rewardId,
    String title,
    String description,
    int points,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('rewards')
          .doc(rewardId)
          .update({
            'title': title,
            'description': description,
            'points': points,
          });
    }
  }

  Future<void> initializeUserStats() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = _db.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      if (!userData.exists) {
        await userDoc.set({
          'points': 0,
          'streak': 0,
          'lastActivity': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> updateUserPoints(int pointsToAdd) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = _db.collection('users').doc(user.uid);
      await userDoc.update({'points': FieldValue.increment(pointsToAdd)});
    }
  }

  Future<void> incrementStreak() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = _db.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        final lastActivity = data['lastActivity'] as Timestamp?;

        if (lastActivity != null) {
          final now = DateTime.now();
          final lastDate = lastActivity.toDate();

          if (now.difference(lastDate).inDays == 1) {
            await userDoc.update({
              'streak': FieldValue.increment(1),
              'lastActivity': FieldValue.serverTimestamp(),
            });
          } else if (now.day == lastDate.day) {
            await userDoc.update({
              'lastActivity': FieldValue.serverTimestamp(),
            });
          } else if (now.difference(lastDate).inDays > 1) {
            await userDoc.update({
              'streak': 1,
              'lastActivity': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    }
  }

  Stream<DocumentSnapshot> getUserStats() {
    final user = _auth.currentUser;
    if (user != null) {
      return _db.collection('users').doc(user.uid).snapshots();
    }
    return Stream.empty();
  }

  Future<bool> canRedeemReward(int rewardPoints) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final userPoints = data['points'] as int? ?? 0;
        return userPoints >= rewardPoints;
      }
    }
    return false;
  }

  Future<bool> redeemReward(String rewardId, int rewardPoints) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (await canRedeemReward(rewardPoints)) {
        final userDoc = _db.collection('users').doc(user.uid);

        await userDoc.update({'points': FieldValue.increment(-rewardPoints)});

        return true;
      }
    }
    return false;
  }

  Future<void> updateTask(
    String taskId,
    String title,
    String description,
    int points,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .update({
            'title': title,
            'description': description,
            'points': points,
          });
    }
  }
}
