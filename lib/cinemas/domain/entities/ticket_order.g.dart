// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TicketOrderAdapter extends TypeAdapter<TicketOrder> {
  @override
  final int typeId = 8;

  @override
  TicketOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketOrder(
      orderId: fields[0] as String,
      cinema: fields[1] as Cinema,
      movieShowtime: fields[2] as MovieShowtime,
      selectedTime: fields[3] as String,
      selectedSeats: (fields[4] as List).cast<Seat>(),
      totalPrice: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TicketOrder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.cinema)
      ..writeByte(2)
      ..write(obj.movieShowtime)
      ..writeByte(3)
      ..write(obj.selectedTime)
      ..writeByte(4)
      ..write(obj.selectedSeats)
      ..writeByte(5)
      ..write(obj.totalPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
