// lib/features/admin/devotees/presentation/bloc/devotees_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/features/admin/devotees/models/devotee_model.dart';
import 'package:surabhi/features/admin/devotees/repositories/devotees_repository.dart';

part 'devotees_event.dart';
part 'devotees_state.dart';

class DevoteesBloc extends Bloc<DevoteesEvent, DevoteesState> {
  final DevoteesRepository _devoteesRepository;

  DevoteesBloc(this._devoteesRepository) : super(const DevoteesInitial()) {
    on<GetDevoteesEvent>(_onGetDevotees);
  }

  Future<void> _onGetDevotees(GetDevoteesEvent event, Emitter<DevoteesState> emit) async {
    emit(const DevoteesLoading());
    final result = await _devoteesRepository.getDevotees();
    result.fold(
      (failure) => emit(DevoteesError(message: failure.message)),
      (devotees) => emit(DevoteesLoaded(devotees: devotees)),
    );
  }
}
