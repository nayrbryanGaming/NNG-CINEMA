import 'package:cloud_firestore/cloud_firestore.dart';
import 'cinema_model.dart';

class CinemaRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('cinemas');

  Future<List<CinemaModel>> list({int limit = 50}) async {
    final snap = await _col.orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((d) => CinemaModel.fromSnapshot(d)).toList();
  }

  Future<String> create(CinemaModel c) async {
    final now = DateTime.now();
    final ref = await _col.add({
      ...c.toJson(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return ref.id;
  }

  Future<void> update(CinemaModel c) async {
    await _col.doc(c.id).update({...c.toJson(), 'updatedAt': Timestamp.fromDate(DateTime.now())});
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}

