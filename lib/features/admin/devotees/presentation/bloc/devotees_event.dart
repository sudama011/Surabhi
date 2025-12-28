// lib/features/admin/devotees/presentation/bloc/devotees_event.dart

part of 'devotees_bloc.dart';

abstract class DevoteesEvent extends Equatable {
  const DevoteesEvent();

  @override
  List<Object?> get props => [];
}

class GetDevoteesEvent extends DevoteesEvent {
  const GetDevoteesEvent();
}
