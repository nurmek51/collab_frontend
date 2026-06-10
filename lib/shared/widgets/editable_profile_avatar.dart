import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../api/auth_api.dart';
import '../di/service_locator.dart';
import '../services/avatar_url_cache.dart';
import '../utils/avatar_file_utils.dart';
import 'user_avatar.dart';

class EditableProfileAvatar extends StatefulWidget {
  final bool hasAvatar;
  final String? name;
  final String? surname;
  final double size;
  final VoidCallback? onAvatarChanged;

  const EditableProfileAvatar({
    super.key,
    required this.hasAvatar,
    this.name,
    this.surname,
    this.size = 120,
    this.onAvatarChanged,
  });

  @override
  State<EditableProfileAvatar> createState() => _EditableProfileAvatarState();
}

class _EditableProfileAvatarState extends State<EditableProfileAvatar> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _hasAvatar = false;
  bool _isUploading = false;
  int _cacheVersion = 0;

  AuthApi get _authApi => sl<AuthApi>();

  @override
  void initState() {
    super.initState();
    _hasAvatar = widget.hasAvatar;
  }

  @override
  void didUpdateWidget(covariant EditableProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasAvatar != widget.hasAvatar) {
      _hasAvatar = widget.hasAvatar;
    }
  }

  Future<void> _pickAndUpload() async {
    if (_isUploading) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final fileName = image.name.isNotEmpty ? image.name : 'avatar.jpg';

      final validationError = validateAvatarFile(
        fileName: fileName,
        fileSize: bytes.length,
      );
      if (validationError != null) {
        return;
      }

      setState(() => _isUploading = true);

      await _authApi.uploadAvatar(fileName: fileName, fileBytes: bytes);
      sl<AvatarUrlCache>().invalidate();

      if (!mounted) return;
      setState(() {
        _hasAvatar = true;
        _isUploading = false;
        _cacheVersion++;
      });
      widget.onAvatarChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _isUploading
            ? Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGrayBackground,
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            : UserAvatar(
                hasAvatar: _hasAvatar,
                name: widget.name,
                surname: widget.surname,
                size: widget.size,
                cacheVersion: _cacheVersion,
              ),
        Positioned(
          right: 0,
          bottom: widget.size * 0.08,
          child: GestureDetector(
            onTap: _pickAndUpload,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCADDE1)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/edit_icon_profile.svg',
                  width: 14.17.w,
                  height: 14.17.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
