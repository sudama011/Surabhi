// lib/features/admin/roles/presentation/cubit/roles_state.dart

part of 'roles_cubit.dart';

abstract class RolesState extends Equatable {
  const RolesState();

  @override
  List<Object?> get props => [];
}

class RolesInitial extends RolesState {
  const RolesInitial();
}

class RolesLoading extends RolesState {
  const RolesLoading();
}

class RolesLoaded extends RolesState {
  final List<RoleEntity> roles;

  const RolesLoaded({required this.roles});

  @override
  List<Object?> get props => [roles];
}

class RolesError extends RolesState {
  final String message;

  const RolesError({required this.message});

  @override
  List<Object?> get props => [message];
}
