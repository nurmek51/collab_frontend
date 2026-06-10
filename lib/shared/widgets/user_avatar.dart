import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../di/service_locator.dart';
import '../services/avatar_url_cache.dart';
import '../utils/avatar_file_utils.dart';
import 'avatar_full_screen_viewer.dart';

class UserAvatar extends StatefulWidget {
  final String? userId;
  final bool hasAvatar;
  final String? name;
  final String? surname;
  final String? fallbackName;
  final double size;
  final bool enableFullScreenOnTap;
  final int? cacheVersion;

  const UserAvatar({
    super.key,
    this.userId,
    required this.hasAvatar,
    this.name,
    this.surname,
    this.fallbackName,
    this.size = 48,
    this.enableFullScreenOnTap = true,
    this.cacheVersion = 0,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasAvatar != widget.hasAvatar ||
        oldWidget.userId != widget.userId ||
        oldWidget.cacheVersion != widget.cacheVersion) {
      _loadAvatar();
    }
  }

  Future<void> _loadAvatar() async {
    if (!widget.hasAvatar) {
      if (mounted) {
        setState(() {
          _imageUrl = null;
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final url = await sl<AvatarUrlCache>().resolveUrl(
        userId: widget.userId,
        hasAvatar: widget.hasAvatar,
      );
      if (!mounted) return;
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imageUrl = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _openFullScreen() async {
    if (!widget.enableFullScreenOnTap || _imageUrl == null) return;
    await AvatarFullScreenViewer.show(context, imageUrl: _imageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(
      name: widget.name,
      surname: widget.surname,
      fallback: widget.fallbackName,
    );

    Widget avatarContent;
    if (_isLoading) {
      avatarContent = Center(
        child: SizedBox(
          width: widget.size * 0.35,
          height: widget.size * 0.35,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (_imageUrl != null) {
      avatarContent = Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) => _placeholder(initials),
      );
    } else {
      avatarContent = _placeholder(initials);
    }

    return GestureDetector(
      onTap: widget.enableFullScreenOnTap && _imageUrl != null
          ? _openFullScreen
          : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGrayBackground,
        ),
        clipBehavior: Clip.antiAlias,
        child: avatarContent,
      ),
    );
  }

  Widget _placeholder(String initials) {
    return Container(
      color: const Color(0xFFD9D9D9),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w600,
          fontSize: widget.size * 0.34,
          color: const Color(0xFF96A4B3),
        ),
      ),
    );
  }
}
