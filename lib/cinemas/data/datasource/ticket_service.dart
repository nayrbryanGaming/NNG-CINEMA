import 'package:hive/hive.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';
import 'dart:math';
import 'package:movies_app/utils/notification_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class TicketService {
  static const String _boxName = 'tickets';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get box safely with error recovery
  Future<Box<TicketOrder>> _getBox() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box<TicketOrder>(_boxName);
      }
      return await Hive.openBox<TicketOrder>(_boxName);
    } catch (e) {
      print('[TicketService] Error opening box, recovering: $e');
      await Hive.deleteBoxFromDisk(_boxName);
      return await Hive.openBox<TicketOrder>(_boxName);
    }
  }

  // Get all tickets from the Hive box
  Future<List<TicketOrder>> getTickets() async {
    try {
      final box = await _getBox();
      final tickets = box.values.toList();
      print('[TicketService] Loaded ${tickets.length} tickets');
      for (final t in tickets) {
        print('[TicketService] ticket: id=${t.orderId}, title=${t.movieShowtime.title}, time=${t.selectedTime}, seats=${t.selectedSeats.map((s)=>s.seatNumber).join(",")}');
      }
      return tickets;
    } catch (e) {
      print('[TicketService] Error getting tickets: $e');
      return [];
    }
  }

  // Helper to clone MovieShowtime into a fresh instance
  MovieShowtime _cloneShowtime(MovieShowtime s) {
    return MovieShowtime(
      movieId: s.movieId,
      title: s.title,
      posterUrl: s.posterUrl,
      showtimes: List<String>.from(s.showtimes),
    );
  }

  // Save a ticket to the Hive box
  Future<void> saveTicket(TicketOrder order) async {
    try {
      final box = await _getBox();
      String key = order.orderId;

      // Create a copy of the order with a cloned showtime to avoid any shared const instances
      final clonedOrder = TicketOrder(
        orderId: order.orderId,
        cinema: order.cinema,
        movieShowtime: _cloneShowtime(order.movieShowtime),
        selectedTime: order.selectedTime,
        selectedSeats: order.selectedSeats,
        totalPrice: order.totalPrice,
      );

      // Upload ticket order to Firebase Storage as JSON
      try {
        final jsonData = jsonEncode(clonedOrder.toJson());
        final ref = _storage.ref().child('tickets/${order.orderId}.json');
        await ref.putString(jsonData, format: PutStringFormat.raw, metadata: SettableMetadata(contentType: 'application/json'));
      } catch (e) {
        print('[TicketService] Failed to upload ticket to Firebase Storage: $e');
      }

      // If key already exists, create a fallback unique id and a new TicketOrder instance
      if (box.containsKey(key)) {
        final suffix = '-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9000)+1000}';
        final newOrderId = '${order.orderId}$suffix';
        final newOrder = TicketOrder(
          orderId: newOrderId,
          cinema: clonedOrder.cinema,
          movieShowtime: clonedOrder.movieShowtime,
          selectedTime: clonedOrder.selectedTime,
          selectedSeats: clonedOrder.selectedSeats,
          totalPrice: clonedOrder.totalPrice,
        );
        print('[TicketService] Collision for key=$key, saving with new id=$newOrderId');
        await box.put(newOrderId, newOrder);
        await NotificationService.addTicketBookedNotification();
        await _scheduleReminders(newOrder);
        return;
      }

      print('[TicketService] Saving ticket: id=${clonedOrder.orderId}, title=${clonedOrder.movieShowtime.title}, time=${clonedOrder.selectedTime}, seats=${clonedOrder.selectedSeats.map((s)=>s.seatNumber).join(",")}');
      await box.put(clonedOrder.orderId, clonedOrder);
      await NotificationService.addTicketBookedNotification();
      await _scheduleReminders(clonedOrder);
    } catch (e) {
      print('[TicketService] Error saving ticket: $e');
      // Don't throw, just log the error so the app doesn't crash
    }
  }

  Future<void> _scheduleReminders(TicketOrder order) async {
    // selectedTime format diasumsikan "HH:mm" (misal: "19:30")
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeParts = order.selectedTime.split(":");
    if (timeParts.length == 2) {
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final showTime = today.add(Duration(hours: hour, minutes: minute));
      await NotificationService.addReminderNotification(showTime, before: const Duration(hours: 1));
      await NotificationService.addReminderNotification(showTime, before: const Duration(minutes: 30));
    }
  }

  // This can be used to clear all tickets for testing purposes
  Future<void> clearAllTickets() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      print('[TicketService] Error clearing tickets: $e');
    }
  }
}
