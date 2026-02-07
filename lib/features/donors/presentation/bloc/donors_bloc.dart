// lib/features/donors/presentation/bloc/donors_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/features/donors/models/donor_model.dart';
import 'package:surabhi/features/donors/repositories/donors_repository.dart';

part 'donors_event.dart';
part 'donors_state.dart';

class DonorsBloc extends Bloc<DonorsEvent, DonorsState> {
  final DonorsRepository _donorsRepository;

  DonorsBloc(this._donorsRepository) : super(const DonorsState()) {
    on<SearchDonorsEvent>(_onSearchDonors);
    on<LoadMoreDonorsEvent>(_onLoadMoreDonors);
    on<TogglePatronModeEvent>(_onTogglePatronMode);
  }

  Future<void> _onSearchDonors(SearchDonorsEvent event, Emitter<DonorsState> emit) async {
    emit(
      state.copyWith(
        status: DonorsStatus.loading,
        searchText: event.searchText,
        currentPage: 1,
        donors: [],
        hasReachedMax: false,
        hasReachedLimit: false,
      ),
    );

    final result = await _donorsRepository.searchDonors(
      pageNumber: 1,
      pageSize: DonorsState.pageSize,
      searchText: event.searchText,
      isPatron: state.isPatronMode,
    );

    result.fold((failure) => emit(state.copyWith(status: DonorsStatus.error, errorMessage: failure.message)), (
      response,
    ) {
      final hasReachedMax = response.donors.length >= response.totalRecordsCount;
      final hasReachedLimit = response.donors.length >= DonorsState.maxElements;
      emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: response.donors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: 1,
          hasReachedMax: hasReachedMax,
          hasReachedLimit: hasReachedLimit,
        ),
      );
    });
  }

  Future<void> _onLoadMoreDonors(LoadMoreDonorsEvent event, Emitter<DonorsState> emit) async {
    if (state.hasReachedMax || state.hasReachedLimit || state.status == DonorsStatus.loadingMore) {
      return;
    }

    // Check if loading more would exceed the limit
    if (state.donors.length >= DonorsState.maxElements) {
      emit(state.copyWith(hasReachedLimit: true));
      return;
    }

    emit(state.copyWith(status: DonorsStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await _donorsRepository.searchDonors(
      pageNumber: nextPage,
      pageSize: DonorsState.pageSize,
      searchText: state.searchText,
      isPatron: state.isPatronMode,
    );

    result.fold((failure) => emit(state.copyWith(status: DonorsStatus.loaded, errorMessage: failure.message)), (
      response,
    ) {
      final allDonors = [...state.donors, ...response.donors];
      final hasReachedMax = allDonors.length >= response.totalRecordsCount;
      final hasReachedLimit = allDonors.length >= DonorsState.maxElements;

      // Trim to max elements if exceeded
      final trimmedDonors = hasReachedLimit ? allDonors.take(DonorsState.maxElements).toList() : allDonors;

      emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: trimmedDonors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: nextPage,
          hasReachedMax: hasReachedMax,
          hasReachedLimit: hasReachedLimit,
        ),
      );
    });
  }

  Future<void> _onTogglePatronMode(TogglePatronModeEvent event, Emitter<DonorsState> emit) async {
    final newPatronMode = !state.isPatronMode;
    emit(
      state.copyWith(
        isPatronMode: newPatronMode,
        status: DonorsStatus.loading,
        currentPage: 1,
        donors: [],
        hasReachedMax: false,
        hasReachedLimit: false,
      ),
    );

    final result = await _donorsRepository.searchDonors(
      pageNumber: 1,
      pageSize: DonorsState.pageSize,
      searchText: state.searchText,
      isPatron: newPatronMode,
    );

    result.fold((failure) => emit(state.copyWith(status: DonorsStatus.error, errorMessage: failure.message)), (
      response,
    ) {
      final hasReachedMax = response.donors.length >= response.totalRecordsCount;
      final hasReachedLimit = response.donors.length >= DonorsState.maxElements;
      emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: response.donors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: 1,
          hasReachedMax: hasReachedMax,
          hasReachedLimit: hasReachedLimit,
        ),
      );
    });
  }
}
