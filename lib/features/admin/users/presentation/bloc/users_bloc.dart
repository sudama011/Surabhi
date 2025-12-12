// lib/features/admin/users/presentation/bloc/users_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/features/admin/users/domain/entities/register_user_entity.dart';
import 'package:surabhi/features/auth/domain/entities/user_entity.dart';
import 'package:surabhi/features/admin/users/domain/usecases/get_users_usecase.dart';
import 'package:surabhi/features/admin/users/domain/usecases/reset_user_password_usecase.dart';
import 'package:surabhi/features/admin/users/domain/usecases/remove_user_usecase.dart';
import 'package:surabhi/features/admin/users/domain/usecases/change_user_role_usecase.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;
  final ResetUserPasswordUseCase resetUserPasswordUseCase;
  final RemoveUserUseCase removeUserUseCase;
  final ChangeUserRoleUseCase changeUserRoleUseCase;

  DateTime? _lastRequestTime;
  static const _debounceDelay = Duration(milliseconds: 500);
  static const _pageSize = 20; // Items per request for infinite scroll

  int _currentOffset = 0; // Track offset for infinite scroll
  List<RegisterUserEntity> _allUsers = []; // Accumulate all loaded users
  bool _hasMoreData = true; // Track if there are more users to load

  UsersBloc({
    required this.getUsersUseCase,
    required this.resetUserPasswordUseCase,
    required this.removeUserUseCase,
    required this.changeUserRoleUseCase,
  }) : super(UsersInitial()) {
    on<GetUsersEvent>(_onGetUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<ChangePageSizeEvent>(_onChangePageSize);
    on<ResetUserPasswordEvent>(_onResetUserPassword);
    on<RemoveUserEvent>(_onRemoveUser);
    on<ChangeUserRoleEvent>(_onChangeUserRole);
  }

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UsersState> emit) async {
    // Debouncing: Prevent rapid successive calls
    final now = DateTime.now();
    if (_lastRequestTime != null && now.difference(_lastRequestTime!) < _debounceDelay) {
      print('🚫 Debouncing: Ignoring rapid successive GetUsersEvent');
      return;
    }
    _lastRequestTime = now;

    // Prevent multiple simultaneous requests
    if (state is UsersLoading) {
      print('🚫 Already loading: Ignoring GetUsersEvent');
      return;
    }

    print('📥 Processing GetUsersEvent: Fetching first batch of users');
    emit(UsersLoading());

    // Reset for new fetch
    _currentOffset = 0;
    _allUsers = [];
    _hasMoreData = true;

    final result = await getUsersUseCase(page: 1, size: _pageSize);
    result.fold(
      (failure) {
        print('❌ GetUsers failed: ${failure.message}');
        emit(UsersError(failure.message));
      },
      (users) {
        print('✅ GetUsers success: ${users.length} users loaded');
        _allUsers = users;
        _currentOffset = users.length;
        _hasMoreData = users.length >= _pageSize;
        emit(UsersLoaded(users: _allUsers, hasMoreData: _hasMoreData));
      },
    );
  }

  Future<void> _onLoadMoreUsers(LoadMoreUsersEvent event, Emitter<UsersState> emit) async {
    final currentState = state;

    // Prevent multiple simultaneous load more requests
    if (currentState is UsersLoadingMore) {
      print('🚫 Already loading more: Ignoring LoadMoreUsersEvent');
      return;
    }

    if (currentState is UsersLoaded && _hasMoreData) {
      print('📥 Processing LoadMoreUsersEvent: offset=$_currentOffset');
      emit(UsersLoadingMore(users: _allUsers, hasMoreData: _hasMoreData));

      final result = await getUsersUseCase(page: (_currentOffset ~/ _pageSize) + 1, size: _pageSize);

      result.fold(
        (failure) {
          print('❌ LoadMoreUsers failed: ${failure.message}');
          // On error, revert to the previous loaded state
          emit(UsersLoaded(users: _allUsers, hasMoreData: _hasMoreData));
        },
        (newUsers) {
          print('✅ LoadMoreUsers success: ${newUsers.length} more users loaded');
          _allUsers.addAll(newUsers);
          _currentOffset = _allUsers.length;
          _hasMoreData = newUsers.length >= _pageSize;
          emit(UsersLoaded(users: _allUsers, hasMoreData: _hasMoreData));
        },
      );
    } else {
      print('🚫 Cannot load more: No more data available');
    }
  }

  Future<void> _onChangePageSize(ChangePageSizeEvent event, Emitter<UsersState> emit) async {
    // For infinite scroll, page size changes don't apply
    // Just reload the first batch
    print('📏 Reloading users (page size changes not applicable for infinite scroll)');
    add(const GetUsersEvent());
  }

  Future<void> _onResetUserPassword(ResetUserPasswordEvent event, Emitter<UsersState> emit) async {
    emit(AdminOperationLoading());
    final result = await resetUserPasswordUseCase(
      ResetUserPasswordParams(email: event.email, newPassword: event.newPassword),
    );
    result.fold(
      (failure) => emit(AdminOperationError(failure.message)),
      (_) => emit(AdminOperationSuccess('Password reset successfully for ${event.email}')),
    );
  }

  Future<void> _onRemoveUser(RemoveUserEvent event, Emitter<UsersState> emit) async {
    emit(AdminOperationLoading());
    final result = await removeUserUseCase(RemoveUserParams(email: event.email));
    result.fold(
      (failure) => emit(AdminOperationError(failure.message)),
      (_) => emit(AdminOperationSuccess('User ${event.email} removed successfully')),
    );
  }

  Future<void> _onChangeUserRole(ChangeUserRoleEvent event, Emitter<UsersState> emit) async {
    emit(AdminOperationLoading());
    final result = await changeUserRoleUseCase(ChangeUserRoleParams(email: event.email, newRole: event.newRole));
    result.fold(
      (failure) => emit(AdminOperationError(failure.message)),
      (_) => emit(AdminOperationSuccess('Role changed to ${event.newRole} for ${event.email}')),
    );
  }
}
