import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/api/auth_api.dart';

class AdminVerifyPage extends StatefulWidget {
  const AdminVerifyPage({super.key});

  @override
  State<AdminVerifyPage> createState() => _AdminVerifyPageState();
}

class _AdminVerifyPageState extends State<AdminVerifyPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  late final AuthApi _authApi;
  String? _phone;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _authApi = sl<AuthApi>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Try to read phone passed via extra
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        _phone = extra['phone'] as String?;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_phone == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authApi.verifyOtp(phoneNumber: _phone!, code: _codeController.text.trim());
      if (!mounted) return;
      // Navigate to admin root
      context.go('/admin');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Verify OTP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(_phone ?? 'No phone provided', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Code')),
              const SizedBox(height: 12),
              if (_error != null) ...[Text(_error!, style: const TextStyle(color: Colors.red)), const SizedBox(height: 12)],
              ElevatedButton(onPressed: _isLoading ? null : _verify, child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Verify')),
            ],
          ),
        ),
      ),
    );
  }
}