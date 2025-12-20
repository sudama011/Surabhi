part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final bool isBiometricEnabled;
  final bool isBiometricSupported;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.isBiometricEnabled = false,
    this.isBiometricSupported = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    bool? isBiometricEnabled,
    bool? isBiometricSupported,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricSupported: isBiometricSupported ?? this.isBiometricSupported,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isBiometricEnabled, isBiometricSupported, errorMessage];
}
