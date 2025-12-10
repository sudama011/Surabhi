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

class ChangePageSizeEvent extends UsersEvent {
  final int newSize;

  const ChangePageSizeEvent({required this.newSize});

  @override
  List<Object> get props => [newSize];
}

class ResetUserPasswordEvent extends UsersEvent {
  final String email;
  final String newPassword;

  const ResetUserPasswordEvent({required this.email, required this.newPassword});

  @override
  List<Object> get props => [email, newPassword];
}

class RemoveUserEvent extends UsersEvent {
  final String email;

  const RemoveUserEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class ChangeUserRoleEvent extends UsersEvent {
  final String email;
  final String newRole;

  const ChangeUserRoleEvent({required this.email, required this.newRole});

  @override
  List<Object> get props => [email, newRole];
}
