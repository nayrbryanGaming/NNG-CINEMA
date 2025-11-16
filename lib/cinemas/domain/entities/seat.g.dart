// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeatAdapter extends TypeAdapter<Seat> {
  @override
  final int typeId = 5;

  @override
  Seat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Seat(
      id: fields[0] as String,
      seatNumber: fields[1] as String,
      status: fields[2] as SeatStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Seat obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.seatNumber)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
