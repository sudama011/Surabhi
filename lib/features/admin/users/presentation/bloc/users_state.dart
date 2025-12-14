// lib/features/admin/users/presentation/bloc/users_state.dart

part of 'users_bloc.dart';

enum UsersStatus { initial, loading, loaded, error }

enum AdminOpStatus { initial, loading, success, failure }

class UsersState extends Equatable {
  // Data State
  final UsersStatus status;
  final List<RegisteredUserModel> users;
  final bool hasMoreData;
  final String errorMessage;

  // Admin Operation State (Reset Pass, Delete, Change Role)
  final AdminOpStatus adminOpStatus;
  final String? adminOpMessage; // Holds success or error message for SnackBar

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.hasMoreData = true,
    this.errorMessage = '',
    this.adminOpStatus = AdminOpStatus.initial,
    this.adminOpMessage,
  });

  /// Helper to update state without losing existing data
  UsersState copyWith({
    UsersStatus? status,
    List<RegisteredUserModel>? users,
    bool? hasMoreData,
    String? errorMessage,
    AdminOpStatus? adminOpStatus,
    String? adminOpMessage,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      errorMessage: errorMessage ?? this.errorMessage,
      adminOpStatus: adminOpStatus ?? this.adminOpStatus,
      adminOpMessage: adminOpMessage ?? this.adminOpMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, hasMoreData, errorMessage, adminOpStatus, adminOpMessage];
}
