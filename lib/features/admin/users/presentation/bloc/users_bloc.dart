// lib/features/admin/users/presentation/bloc/users_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/features/admin/users/domain/usecases/get_users_usecase.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;

  UsersBloc({required this.getUsersUseCase}) : super(UsersInitial()) {
    on<GetUsersEvent>(_onGetUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
  }

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final result = await getUsersUseCase(page: event.page, size: event.size);
    result.fold((failure) => emit(UsersError(failure.message)), (paginatedUsers) => emit(UsersLoaded(paginatedUsers)));
  }

  Future<void> _onLoadMoreUsers(LoadMoreUsersEvent event, Emitter<UsersState> emit) async {
    final currentState = state;
    if (currentState is UsersLoaded && currentState.paginatedUsers.meta.hasNext) {
      emit(UsersLoadingMore(currentState.paginatedUsers));

      final result = await getUsersUseCase(page: currentState.paginatedUsers.meta.page + 1, size: event.size);

      result.fold(
        (failure) {
          // On error, revert to the previous loaded state instead of showing error
          emit(UsersLoaded(currentState.paginatedUsers));
          // You could also emit a specific error state if needed
        },
        (newPaginatedUsers) {
          final allUsers = [...currentState.paginatedUsers.items, ...newPaginatedUsers.items];
          emit(UsersLoaded(PaginatedResponse(items: allUsers, meta: newPaginatedUsers.meta)));
        },
      );
    }
  }
}
