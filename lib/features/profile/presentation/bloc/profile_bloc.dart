import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surabhi/features/profile/repositories/profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final XFile file;
  const ProfileAvatarUploadRequested(this.file);
  @override
  List<Object> get props => [file];
}

class ChangePasswordRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  const ChangePasswordRequested({required this.oldPassword, required this.newPassword});
  @override
  List<Object> get props => [oldPassword, newPassword];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileAvatarUploadSuccess extends ProfileState {}

class ProfileAvatarUploadFailure extends ProfileState {
  final String message;
  const ProfileAvatarUploadFailure(this.message);
  @override
  List<Object> get props => [message];
}

class ProfilePasswordChangeSuccess extends ProfileState {}

class ProfilePasswordChangeFailure extends ProfileState {
  final String message;
  const ProfilePasswordChangeFailure(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onAvatarUploadRequested(ProfileAvatarUploadRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await profileRepository.uploadAvatar(event.file);

    result.fold(
      (failure) => emit(ProfileAvatarUploadFailure(failure.message)),
      (_) => emit(ProfileAvatarUploadSuccess()),
    );
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await profileRepository.changePassword(event.oldPassword, event.newPassword);

    result.fold(
      (failure) => emit(ProfilePasswordChangeFailure(failure.message)),
      (_) => emit(ProfilePasswordChangeSuccess()),
    );
  }
}
