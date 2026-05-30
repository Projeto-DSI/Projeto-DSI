import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_quest.dart';

class QuestService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('user_quests');

  Future<List<UserQuest>> fetchByUser(String userId) async {
    final snapshot = await _collection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      data['id'] = doc.id;
      return UserQuest.fromMap(data);
    }).toList();
  }

  Future<UserQuest> create(UserQuest quest) async {
    final payload = {...quest.toMap(), 'created_at': FieldValue.serverTimestamp()};
    final docRef = await _collection.add(payload);
    final doc = await docRef.get();
    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    data['id'] = doc.id;
    return UserQuest.fromMap(data);
  }

  Future<void> update(UserQuest quest) async {
    await _collection.doc(quest.id).update(quest.toMap());
  }

  Future<void> delete(String questId) async {
    await _collection.doc(questId).delete();
  }
}

final questService = QuestService();
