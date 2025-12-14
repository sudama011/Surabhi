// lib/features/admin/users/presentation/bloc/users_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/features/admin/users/models/registered_user_model.dart';
import 'package:surabhi/features/admin/users/repositories/users_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository usersRepository;

  static const _pageSize = 20;
  int _currentPage = 1;

  UsersBloc({required this.usersRepository}) : super(const UsersState()) {
    on<GetUsersEvent>(_onGetUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<ResetUserPasswordEvent>(_onResetUserPassword);
    on<RemoveUserEvent>(_onRemoveUser);
    on<ChangeUserRoleEvent>(_onChangeUserRole);
    on<CreateUserRequested>(_onCreateUser);
  }

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UsersState> emit) async {
    if (state.status == UsersStatus.loading) return;

    emit(state.copyWith(status: UsersStatus.loading));
    _currentPage = 1; // Reset page

    final result = await usersRepository.getUsers(page: _currentPage, size: _pageSize);

    result.fold(
      (failure) => emit(state.copyWith(status: UsersStatus.error, errorMessage: failure.message)),
      (users) => emit(state.copyWith(status: UsersStatus.loaded, users: users, hasMoreData: users.length >= _pageSize)),
    );
  }

  Future<void> _onLoadMoreUsers(LoadMoreUsersEvent event, Emitter<UsersState> emit) async {
    if (!state.hasMoreData || state.status != UsersStatus.loaded) return;

    // Optional: Add a specific "loading more" status if you want a footer spinner
    // For now, we just keep it 'loaded' and append data

    final nextPage = _currentPage + 1;
    final result = await usersRepository.getUsers(page: nextPage, size: _pageSize);

    result.fold(
      (failure) => emit(
        state.copyWith(
          // Don't change main status to error, just show snackbar or ignore
          adminOpStatus: AdminOpStatus.failure,
          adminOpMessage: 'Failed to load more: ${failure.message}',
        ),
      ),
      (newUsers) {
        _currentPage = nextPage;
        emit(state.copyWith(users: List.of(state.users)..addAll(newUsers), hasMoreData: newUsers.length >= _pageSize));
      },
    );
  }

  // --- Admin Operations (Preserves List Data) ---

  Future<void> _onResetUserPassword(ResetUserPasswordEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(adminOpStatus: AdminOpStatus.loading));

    final result = await usersRepository.resetUserPassword(event.email, event.newPassword);

    result.fold(
      (failure) => emit(state.copyWith(adminOpStatus: AdminOpStatus.failure, adminOpMessage: failure.message)),
      (_) => emit(state.copyWith(adminOpStatus: AdminOpStatus.success, adminOpMessage: 'Password reset successfully')),
    );
  }

  Future<void> _onRemoveUser(RemoveUserEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(adminOpStatus: AdminOpStatus.loading));

    final result = await usersRepository.removeUser(event.email);

    result.fold(
      (failure) => emit(state.copyWith(adminOpStatus: AdminOpStatus.failure, adminOpMessage: failure.message)),
      (_) {
        // Optimistically remove user from list locally to feel faster
        final updatedUsers = state.users.where((u) => u.email != event.email).toList();

        emit(
          state.copyWith(
            adminOpStatus: AdminOpStatus.success,
            adminOpMessage: 'User removed successfully',
            users: updatedUsers, // Update list
          ),
        );
      },
    );
  }

  Future<void> _onChangeUserRole(ChangeUserRoleEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(adminOpStatus: AdminOpStatus.loading));

    final result = await usersRepository.changeUserRole(event.email, event.newRole);

    result.fold(
      (failure) => emit(state.copyWith(adminOpStatus: AdminOpStatus.failure, adminOpMessage: failure.message)),
      (_) {
        // Optimistically update user role locally
        final updatedUsers = state.users.map((u) {
          return u.email == event.email ? u.copyWith(role: event.newRole) : u;
        });

        emit(
          state.copyWith(
            adminOpStatus: AdminOpStatus.success,
            adminOpMessage: 'Role changed successfully',
            users: updatedUsers as List<RegisteredUserModel>,
          ),
        );
      },
    );
  }

  Future<void> _onCreateUser(CreateUserRequested event, Emitter<UsersState> emit) async {
    emit(state.copyWith(adminOpStatus: AdminOpStatus.loading));

    final result = await usersRepository.createUser(
      email: event.email,
      password: event.password,
      phoneNumber: event.phoneNumber,
      role: event.role,
    );

    result.fold(
      (failure) => emit(state.copyWith(adminOpStatus: AdminOpStatus.failure, adminOpMessage: failure.message)),
      (_) {
        // 1. Emit Success to close the form
        emit(state.copyWith(adminOpStatus: AdminOpStatus.success, adminOpMessage: 'User created successfully'));

        // 2. Refresh the list automatically
        add(const GetUsersEvent());
      },
    );
  }
}
