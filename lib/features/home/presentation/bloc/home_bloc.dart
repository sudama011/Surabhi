// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/features/home/models/home_summary_model.dart';
import 'package:surabhi/features/home/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc(this._homeRepository) : super(const HomeInitial()) {
    on<GetHomeSummaryEvent>(_onGetHomeSummary);
  }

  Future<void> _onGetHomeSummary(GetHomeSummaryEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final result = await _homeRepository.getHomeSummary();
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (summary) => emit(HomeLoaded(summary: summary)),
    );
  }
}
