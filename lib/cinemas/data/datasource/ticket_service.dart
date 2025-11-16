import 'package:hive/hive.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';

class TicketService {
  static const String _boxName = 'tickets';

  // Get all tickets from the Hive box
  Future<List<TicketOrder>> getTickets() async {
    final box = await Hive.openBox<TicketOrder>(_boxName);
    return box.values.toList();
  }

  // Save a ticket to the Hive box
  Future<void> saveTicket(TicketOrder order) async {
    final box = await Hive.openBox<TicketOrder>(_boxName);
    await box.put(order.orderId, order);
  }

  // This can be used to clear all tickets for testing purposes
  Future<void> clearAllTickets() async {
    final box = await Hive.openBox<TicketOrder>(_boxName);
    await box.clear();
  }
}
