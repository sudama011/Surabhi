import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/features/profile/datasources/profile_remote_datasource.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getProfile();
  Future<Either<Failure, void>> uploadAvatar(XFile file);
  Future<Either<Failure, void>> changePassword(String oldPassword, String newPassword);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadAvatar(XFile file) async {
    try {
      // 1. Validate File Type (JPG, JPEG, PNG)
      final extension = file.name.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png'];

      if (!allowedExtensions.contains(extension)) {
        return const Left(ValidationFailure(message: 'Invalid file type. Only JPG, JPEG, and PNG are allowed.'));
      }

      // 2. Validate File Size (Max 2MB)
      final bytes = await file.readAsBytes();
      final sizeInMB = bytes.lengthInBytes / (1024 * 1024);

      if (sizeInMB > 2) {
        return const Left(ValidationFailure(message: 'File size exceeds the 2MB limit.'));
      }

      // 3. Proceed to Upload if valid
      await remoteDataSource.uploadAvatar(bytes, file.name);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String oldPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(oldPassword, newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }
}
