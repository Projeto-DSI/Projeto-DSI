import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/itinerary.dart';

class ItineraryService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('itineraries');

  Future<List<Itinerary>> fetchByUser(String userId) async {
    final snapshot = await _col
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      data['id'] = doc.id;
      return Itinerary.fromMap(data);
    }).toList();
  }

  Future<Itinerary> create(Itinerary itinerary) async {
    final payload = {
      ...itinerary.toMap(),
      'created_at': FieldValue.serverTimestamp(),
    };
    final docRef = await _col.add(payload);
    final doc = await docRef.get();
    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    data['id'] = doc.id;
    return Itinerary.fromMap(data);
  }

  Future<void> update(Itinerary itinerary) async {
    await _col.doc(itinerary.id).update(itinerary.toMap());
  }

  Future<void> delete(String itineraryId) async {
    await _col.doc(itineraryId).delete();
  }
}

final itineraryService = ItineraryService();
