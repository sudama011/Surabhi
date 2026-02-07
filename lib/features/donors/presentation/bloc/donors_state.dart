// lib/features/donors/presentation/bloc/donors_state.dart

part of 'donors_bloc.dart';

enum DonorsStatus { initial, loading, loaded, loadingMore, error }

class DonorsState extends Equatable {
  final DonorsStatus status;
  final List<DonorModel> donors;
  final int currentPage;
  final int totalRecordsCount;
  final bool isPatronMode;
  final String searchText;
  final bool hasReachedMax;
  final bool hasReachedLimit;
  final String errorMessage;

  const DonorsState({
    this.status = DonorsStatus.initial,
    this.donors = const [],
    this.currentPage = 1,
    this.totalRecordsCount = 0,
    this.isPatronMode = false,
    this.searchText = '',
    this.hasReachedMax = false,
    this.hasReachedLimit = false,
    this.errorMessage = '',
  });

  /// Maximum number of elements to load via infinite scroll
  static const int maxElements = 100;

  /// Page size for each API call
  static const int pageSize = 20;

  DonorsState copyWith({
    DonorsStatus? status,
    List<DonorModel>? donors,
    int? currentPage,
    int? totalRecordsCount,
    bool? isPatronMode,
    String? searchText,
    bool? hasReachedMax,
    bool? hasReachedLimit,
    String? errorMessage,
  }) {
    return DonorsState(
      status: status ?? this.status,
      donors: donors ?? this.donors,
      currentPage: currentPage ?? this.currentPage,
      totalRecordsCount: totalRecordsCount ?? this.totalRecordsCount,
      isPatronMode: isPatronMode ?? this.isPatronMode,
      searchText: searchText ?? this.searchText,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      hasReachedLimit: hasReachedLimit ?? this.hasReachedLimit,
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
    hasReachedMax,
    hasReachedLimit,
    errorMessage,
  ];
}
