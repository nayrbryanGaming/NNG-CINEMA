// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cinema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CinemaAdapter extends TypeAdapter<Cinema> {
  @override
  final int typeId = 7;

  @override
  Cinema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cinema(
      id: fields[0] as int,
      name: fields[1] as String,
      location: fields[2] as String,
      movieShowtimes: (fields[3] as List).cast<MovieShowtime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Cinema obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.movieShowtimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CinemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
