// lib/features/admin/users/presentation/bloc/users_state.dart

part of 'users_bloc.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoadingMore extends UsersState {
  final List<UserEntity> users;
  final bool hasMoreData;

  const UsersLoadingMore({required this.users, required this.hasMoreData});

  @override
  List<Object> get props => [users, hasMoreData];
}

class UsersLoaded extends UsersState {
  final List<UserEntity> users;
  final bool hasMoreData;

  const UsersLoaded({required this.users, required this.hasMoreData});

  @override
  List<Object> get props => [users, hasMoreData];
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object> get props => [message];
}

// Admin operation states
class AdminOperationLoading extends UsersState {}

class AdminOperationSuccess extends UsersState {
  final String message;

  const AdminOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AdminOperationError extends UsersState {
  final String message;

  const AdminOperationError(this.message);

  @override
  List<Object> get props => [message];
}
