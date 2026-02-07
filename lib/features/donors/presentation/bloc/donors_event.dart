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

/// Load next page (infinite scroll)
class LoadMoreDonorsEvent extends DonorsEvent {
  const LoadMoreDonorsEvent();
}

/// Toggle patron mode on/off
class TogglePatronModeEvent extends DonorsEvent {
  const TogglePatronModeEvent();
}
