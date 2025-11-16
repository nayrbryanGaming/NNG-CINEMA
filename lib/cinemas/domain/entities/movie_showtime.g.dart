// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_showtime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieShowtimeAdapter extends TypeAdapter<MovieShowtime> {
  @override
  final int typeId = 6;

  @override
  MovieShowtime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieShowtime(
      movieId: fields[0] as int,
      title: fields[1] as String,
      posterUrl: fields[2] as String,
      showtimes: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MovieShowtime obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.movieId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterUrl)
      ..writeByte(3)
      ..write(obj.showtimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieShowtimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
