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
    on<GoToPageEvent>(_onGoToPage);
    on<ChangePageSizeEvent>(_onChangePageSize);
    on<TogglePatronModeEvent>(_onTogglePatronMode);
  }

  Future<void> _onSearchDonors(SearchDonorsEvent event, Emitter<DonorsState> emit) async {
    emit(state.copyWith(status: DonorsStatus.loading, searchText: event.searchText, currentPage: 1, donors: []));

    final result = await _donorsRepository.searchDonors(
      pageNumber: 1,
      pageSize: state.pageSize,
      searchText: event.searchText,
      isPatron: state.isPatronMode,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: DonorsStatus.error, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: response.donors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: 1,
        ),
      ),
    );
  }

  Future<void> _onGoToPage(GoToPageEvent event, Emitter<DonorsState> emit) async {
    emit(state.copyWith(status: DonorsStatus.loading, currentPage: event.pageNumber, donors: []));

    final result = await _donorsRepository.searchDonors(
      pageNumber: event.pageNumber,
      pageSize: state.pageSize,
      searchText: state.searchText,
      isPatron: state.isPatronMode,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: DonorsStatus.error, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: response.donors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: event.pageNumber,
        ),
      ),
    );
  }

  Future<void> _onChangePageSize(ChangePageSizeEvent event, Emitter<DonorsState> emit) async {
    emit(state.copyWith(status: DonorsStatus.loading, pageSize: event.newPageSize, currentPage: 1, donors: []));

    final result = await _donorsRepository.searchDonors(
      pageNumber: 1,
      pageSize: event.newPageSize,
      searchText: state.searchText,
      isPatron: state.isPatronMode,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: DonorsStatus.error, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: response.donors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: 1,
        ),
      ),
    );
  }

  Future<void> _onTogglePatronMode(TogglePatronModeEvent event, Emitter<DonorsState> emit) async {
    final newPatronMode = !state.isPatronMode;
    emit(state.copyWith(isPatronMode: newPatronMode, status: DonorsStatus.loading, currentPage: 1, donors: []));

    final result = await _donorsRepository.searchDonors(
      pageNumber: 1,
      pageSize: state.pageSize,
      searchText: state.searchText,
      isPatron: newPatronMode,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: DonorsStatus.error, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          status: DonorsStatus.loaded,
          donors: response.donors,
          totalRecordsCount: response.totalRecordsCount,
          currentPage: 1,
        ),
      ),
    );
  }
}
