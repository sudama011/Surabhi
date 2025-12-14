import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/string_extensions.dart';
import 'package:surabhi/features/profile/presentation/bloc/profile_bloc.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    // NOTE: If you add 'image_cropper' package later, invoke it here
    // final croppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path...);

    if (pickedFile != null && context.mounted) {
      context.read<ProfileBloc>().add(ProfileAvatarUploadRequested(pickedFile));
    }
  }

  void _zoomAvatar(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image(image: image),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (user.avatar != null && user.avatarContentType != null) {
      try {
        final bytes = base64Decode(user.avatar!);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error loading avatar: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _getAvatarImage();
    // Only allow editing if ID > 0
    final canEdit = user.id > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // 1. Avatar (Clickable if exists)
              GestureDetector(
                onTap: avatarImage != null ? () => _zoomAvatar(context, avatarImage) : null,
                child: Hero(
                  tag: 'profile_avatar',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryColor,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(
                            user.avatarInitial,
                            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              ),

              // 2. Edit Button (Only if user.id > 0)
              if (canEdit)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isUploading = state is ProfileLoading;

                      return GestureDetector(
                        onTap: isUploading ? null : () => _pickAndUploadAvatar(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName.toTitleCase,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(20)),
            child: Text(
              user.role.name.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
