import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_model.dart';

class ScheduleRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('schedules');

  Future<List<ScheduleModel>> listForCinema(String cinemaId, {int limit = 50}) async {
    final snap = await _col.where('cinemaId', isEqualTo: cinemaId).orderBy('startAt').limit(limit).get();
    return snap.docs.map((d) => ScheduleModel.fromSnapshot(d)).toList();
  }

  Future<String> create(ScheduleModel s) async {
    // Basic overlap check: ensure no existing schedule in same hall that overlaps
    final overlap = await _col.where('cinemaId', isEqualTo: s.cinemaId).where('hallId', isEqualTo: s.hallId).where('startAt', isLessThan: Timestamp.fromDate(s.endAt)).where('endAt', isGreaterThan: Timestamp.fromDate(s.startAt)).get();
    if (overlap.docs.isNotEmpty) throw Exception('Conflict with existing schedule');

    final ref = await _col.add(s.toJson());
    return ref.id;
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}

