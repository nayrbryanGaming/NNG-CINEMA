import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/cinemas/domain/usecases/get_cinemas_usecase.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_event.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_state.dart';

class CinemasBloc extends Bloc<CinemasEvent, CinemasState> {
  final GetCinemasUseCase getCinemasUseCase;

  CinemasBloc(this.getCinemasUseCase) : super(CinemasInitial()) {
    on<GetCinemasEvent>((event, emit) async {
      emit(CinemasLoading());
      final result = await getCinemasUseCase();
      result.fold(
        (failure) => emit(CinemasError(failure.message)),
        (cinemas) => emit(CinemasLoaded(cinemas)),
      );
    });
  }
}
