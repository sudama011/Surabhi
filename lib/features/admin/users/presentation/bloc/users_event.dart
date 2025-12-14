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
  final Role newRole;

  const ChangeUserRoleEvent({required this.email, required this.newRole});

  @override
  List<Object> get props => [email, newRole];
}

class CreateUserRequested extends UsersEvent {
  final String email;
  final String password;
  final String phoneNumber;
  final Role role;

  const CreateUserRequested({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, phoneNumber, role];
}
