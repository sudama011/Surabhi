// lib/features/admin/devotees/presentation/cubit/devotees_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/admin/devotees/domain/entities/devotee_entity.dart';
import 'package:surabhi/features/admin/devotees/domain/usecases/get_devotees_usecase.dart';

part 'devotees_state.dart';

class DevoteesCubit extends Cubit<DevoteesState> {
  final GetDevoteesUseCase getDevoteesUseCase;

  DevoteesCubit({required this.getDevoteesUseCase}) : super(const DevoteesInitial());

  Future<void> fetchDevotees() async {
    emit(const DevoteesLoading());
    final result = await getDevoteesUseCase(const NoParams());
    result.fold(
      (failure) => emit(DevoteesError(message: failure.message)),
      (devotees) => emit(DevoteesLoaded(devotees: devotees)),
    );
  }
}
