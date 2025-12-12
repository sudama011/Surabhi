// lib/features/admin/users/presentation/cubit/create_user_state.dart

part of 'create_user_cubit.dart';

abstract class CreateUserState extends Equatable {
  const CreateUserState();

  @override
  List<Object?> get props => [];
}

class CreateUserInitial extends CreateUserState {
  const CreateUserInitial();
}

class CreateUserLoading extends CreateUserState {
  const CreateUserLoading();
}

class CreateUserSuccess extends CreateUserState {
  const CreateUserSuccess();
}

class CreateUserError extends CreateUserState {
  final String message;

  const CreateUserError({required this.message});

  @override
  List<Object?> get props => [message];
}
