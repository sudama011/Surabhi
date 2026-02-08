// lib/features/donors/presentation/bloc/donors_state.dart

part of 'donors_bloc.dart';

enum DonorsStatus { initial, loading, loaded, error }

class DonorsState extends Equatable {
  final DonorsStatus status;
  final List<DonorModel> donors;
  final int currentPage;
  final int totalRecordsCount;
  final bool isPatronMode;
  final String searchText;
  final int pageSize;
  final String errorMessage;

  const DonorsState({
    this.status = DonorsStatus.initial,
    this.donors = const [],
    this.currentPage = 1,
    this.totalRecordsCount = 0,
    this.isPatronMode = false,
    this.searchText = '',
    this.pageSize = 20,
    this.errorMessage = '',
  });

  DonorsState copyWith({
    DonorsStatus? status,
    List<DonorModel>? donors,
    int? currentPage,
    int? totalRecordsCount,
    bool? isPatronMode,
    String? searchText,
    int? pageSize,
    String? errorMessage,
  }) {
    return DonorsState(
      status: status ?? this.status,
      donors: donors ?? this.donors,
      currentPage: currentPage ?? this.currentPage,
      totalRecordsCount: totalRecordsCount ?? this.totalRecordsCount,
      isPatronMode: isPatronMode ?? this.isPatronMode,
      searchText: searchText ?? this.searchText,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    donors,
    currentPage,
    totalRecordsCount,
    isPatronMode,
    searchText,
    pageSize,
    errorMessage,
  ];
}
