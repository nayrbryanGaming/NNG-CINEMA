import 'package:equatable/equatable.dart';

abstract class CinemasEvent extends Equatable {
  const CinemasEvent();

  @override
  List<Object> get props => [];
}

class GetCinemasEvent extends CinemasEvent {}
