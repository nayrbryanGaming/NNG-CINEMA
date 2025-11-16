// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeatStatusAdapter extends TypeAdapter<SeatStatus> {
  @override
  final int typeId = 4;

  @override
  SeatStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SeatStatus.available;
      case 1:
        return SeatStatus.occupied;
      case 2:
        return SeatStatus.selected;
      default:
        return SeatStatus.available;
    }
  }

  @override
  void write(BinaryWriter writer, SeatStatus obj) {
    switch (obj) {
      case SeatStatus.available:
        writer.writeByte(0);
        break;
      case SeatStatus.occupied:
        writer.writeByte(1);
        break;
      case SeatStatus.selected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
