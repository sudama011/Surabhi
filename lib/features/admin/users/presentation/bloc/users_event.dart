// lib/features/admin/users/presentation/bloc/users_event.dart

part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

class GetUsersEvent extends UsersEvent {
  final int page;
  final int size;

  const GetUsersEvent({this.page = 1, this.size = 10});

  @override
  List<Object> get props => [page, size];
}

class LoadMoreUsersEvent extends UsersEvent {
  final int size;

  const LoadMoreUsersEvent({this.size = 10});

  @override
  List<Object> get props => [size];
}
