// lib/features/admin/users/presentation/cubit/create_user_cubit.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/admin/users/domain/usecases/create_user_usecase.dart';

part 'create_user_state.dart';

class CreateUserCubit extends Cubit<CreateUserState> {
  final CreateUserUseCase createUserUseCase;

  CreateUserCubit({required this.createUserUseCase}) : super(const CreateUserInitial());

  Future<void> createUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    emit(const CreateUserLoading());

    final result = await createUserUseCase(
      CreateUserParams(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        role: role,
      ),
    );

    result.fold(
      (failure) => emit(CreateUserError(message: failure.message)),
      (_) => emit(const CreateUserSuccess()),
    );
  }

  void reset() => emit(const CreateUserInitial());
}
