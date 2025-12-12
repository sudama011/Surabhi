// lib/features/admin/roles/presentation/cubit/roles_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/admin/roles/domain/entities/role_entity.dart';
import 'package:surabhi/features/admin/roles/domain/usecases/get_roles_usecase.dart';

part 'roles_state.dart';

class RolesCubit extends Cubit<RolesState> {
  final GetRolesUseCase getRolesUseCase;

  RolesCubit({required this.getRolesUseCase}) : super(RolesInitial());

  Future<void> fetchRoles() async {
    emit(const RolesLoading());
    final result = await getRolesUseCase(const NoParams());
    result.fold((failure) => emit(RolesError(message: failure.message)), (roles) => emit(RolesLoaded(roles: roles)));
  }
}
