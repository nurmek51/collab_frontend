import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/utils/resume_file_utils.dart';
import '../../../../shared/widgets/resume_bottom_sheet_viewer.dart';

class FreelancerResumeSection extends StatefulWidget {
  final bool hasResume;
  final String? resumeFilename;
  final VoidCallback? onResumeChanged;

  const FreelancerResumeSection({
    super.key,
    required this.hasResume,
    this.resumeFilename,
    this.onResumeChanged,
  });

  @override
  State<FreelancerResumeSection> createState() => _FreelancerResumeSectionState();
}

class _FreelancerResumeSectionState extends State<FreelancerResumeSection> {
  FreelancerApi? _api;

  bool _isUploading = false;
  bool _isDeleting = false;
  bool _isOpening = false;
  double _uploadProgress = 0;

  FreelancerApi get api {
    _api ??= sl<FreelancerApi>();
    return _api!;
  }

  Future<void> _pickAndUpload() async {
    if (_isUploading) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: kAllowedResumeExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        return;
      }

      final validationError = validateResumeFile(
        fileName: file.name,
        fileSize: bytes.length,
      );
      if (validationError != null) {
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });

      await api.uploadResume(
        fileName: file.name,
        fileBytes: bytes,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress = sent / total);
        },
      );

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
      widget.onResumeChanged?.call();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
    }
  }

  Future<void> _openResume() async {
    if (_isOpening || !widget.hasResume) return;

    setState(() => _isOpening = true);
    try {
      final result = await api.getResumeDownloadUrl();
      if (!mounted) return;
      await ResumeBottomSheetViewer.show(context, result.downloadUrl);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _deleteResume() async {
    if (_isDeleting || !widget.hasResume) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить Портфолио?'),
        content: const Text('Файл Портфолио будет удалён с сервера.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await api.deleteResume();
      if (!mounted) return;
      setState(() => _isDeleting = false);
      widget.onResumeChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return Container(
        width: 354.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Портфолио',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                color: const Color(0xFF353F49),
              ),
            ),
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: _uploadProgress > 0 ? _uploadProgress : null,
              color: AppColors.blueAccent,
              backgroundColor: AppColors.blueAccent.withValues(alpha: 0.2),
            ),
            SizedBox(height: 8.h),
            Text(
              'Загрузка Портфолио...',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 14.sp,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      );
    }

    if (!widget.hasResume) {
      return GestureDetector(
        onTap: _pickAndUpload,
        child: Container(
          width: 354.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 27.w,
                    child: Icon(
                      Icons.description_outlined,
                      size: 22.sp,
                      color: const Color(0xFF353F49),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Портфолио',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: const Color(0xFF353F49),
                    ),
                  ),
                ],
              ),
              Text(
                'загрузить',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  color: AppColors.blueAccent,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 354.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Портфолио',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: const Color(0xFF353F49),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _isOpening ? null : _openResume,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svgs/checkbox_icon.svg',
                  width: 24.w,
                  height: 24.h,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _isOpening
                        ? 'Открытие...'
                        : (widget.resumeFilename ?? 'Портфолио'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: AppColors.blueAccent,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              GestureDetector(
                onTap: _pickAndUpload,
                child: Text(
                  'Заменить',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    color: AppColors.blueAccent,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blueAccent,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _isDeleting ? null : _deleteResume,
                child: Text(
                  _isDeleting ? 'удаление...' : 'удалить',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: const Color(0xFFF15656),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
