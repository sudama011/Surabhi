// lib/features/admin/devotees/presentation/bloc/devotees_state.dart

part of 'devotees_bloc.dart';

abstract class DevoteesState extends Equatable {
  const DevoteesState();

  @override
  List<Object?> get props => [];
}

class DevoteesInitial extends DevoteesState {
  const DevoteesInitial();
}

class DevoteesLoading extends DevoteesState {
  const DevoteesLoading();
}

class DevoteesLoaded extends DevoteesState {
  final List<DevoteeModel> devotees;

  const DevoteesLoaded({required this.devotees});

  @override
  List<Object?> get props => [devotees];
}

class DevoteesError extends DevoteesState {
  final String message;

  const DevoteesError({required this.message});

  @override
  List<Object?> get props => [message];
}
