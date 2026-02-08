// lib/features/donors/presentation/bloc/donors_event.dart

part of 'donors_bloc.dart';

abstract class DonorsEvent extends Equatable {
  const DonorsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load or search with new text
class SearchDonorsEvent extends DonorsEvent {
  final String searchText;

  const SearchDonorsEvent({this.searchText = ''});

  @override
  List<Object?> get props => [searchText];
}

/// Navigate to a specific page
class GoToPageEvent extends DonorsEvent {
  final int pageNumber;

  const GoToPageEvent(this.pageNumber);

  @override
  List<Object?> get props => [pageNumber];
}

/// Change the page size (resets to page 1)
class ChangePageSizeEvent extends DonorsEvent {
  final int newPageSize;

  const ChangePageSizeEvent(this.newPageSize);

  @override
  List<Object?> get props => [newPageSize];
}

/// Toggle patron mode on/off
class TogglePatronModeEvent extends DonorsEvent {
  const TogglePatronModeEvent();
}
