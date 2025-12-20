import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/core/services/storage_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final BiometricService _biometricService;
  final StorageService _storageService;

  SettingsCubit(this._biometricService, this._storageService) : super(const SettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final isSupported = await _biometricService.isBiometricAvailable;
      final isEnabled = await _biometricService.isBiometricEnabled;

      emit(
        state.copyWith(
          status: SettingsStatus.success,
          isBiometricSupported: isSupported,
          isBiometricEnabled: isEnabled,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: 'Failed to load settings: $e'));
    }
  }

  Future<void> toggleBiometric(bool newValue) async {
    // Optimistic update or waiting? Let's wait to ensure safety.
    // We don't emit 'loading' here to avoid full page spinner,
    // but we could emit a specific 'toggling' state if needed.

    try {
      if (newValue) {
        // --- ENABLING ---

        // 1. Check Session
        final token = await _storageService.getRefreshToken();
        if (token == null) {
          emit(
            state.copyWith(status: SettingsStatus.failure, errorMessage: 'You must be logged in to enable biometrics.'),
          );
          // Reset status to success to clear error after usage if needed,
          // or handle in UI listener.
          return;
        }
        // 2. Verify Ownership (Security)
        // FIX: Pass checkSettings: false because it is not enabled yet!
        final didAuth = await _biometricService.authenticate(checkSettings: false);

        if (!didAuth) {
          emit(
            state.copyWith(
              status: SettingsStatus.failure,
              errorMessage: 'Authentication failed. Cannot enable biometrics.',
            ),
          );
          // Ensure switch stays off
          emit(state.copyWith(isBiometricEnabled: false));
          return;
        }

        // 3. Enable
        await _biometricService.enableBiometric();
        emit(state.copyWith(status: SettingsStatus.success, isBiometricEnabled: true));
      } else {
        // --- DISABLING ---
        await _biometricService.disableBiometric();
        emit(state.copyWith(status: SettingsStatus.success, isBiometricEnabled: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: 'Error updating setting: $e',
          // Revert toggle visually on error
          isBiometricEnabled: !newValue,
        ),
      );
    }
  }
}
