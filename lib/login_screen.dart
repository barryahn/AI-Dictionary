import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'theme/beige_colors.dart';
import 'l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: BeigeColors.background,
      appBar: AppBar(
        backgroundColor: BeigeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: BeigeColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 앱 로고/제목
                _buildHeader(loc),
                const SizedBox(height: 48),

                // 이메일 입력 필드
                _buildEmailField(loc),
                const SizedBox(height: 16),

                // 비밀번호 입력 필드
                _buildPasswordField(loc),
                const SizedBox(height: 24),

                // 로그인/회원가입 버튼
                _buildSubmitButton(loc),
                const SizedBox(height: 16),

                // 모드 전환 버튼
                _buildModeToggleButton(loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: BeigeColors.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.translate, size: 40, color: BeigeColors.text),
        ),
        const SizedBox(height: 16),
        Text(
          'AI Dictionary',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BeigeColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoginMode
              ? loc.get('login_subtitle')
              : loc.get('register_subtitle'),
          style: TextStyle(fontSize: 16, color: BeigeColors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations loc) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: loc.get('email'),
        hintText: loc.get('email_hint'),
        prefixIcon: Icon(Icons.email, color: BeigeColors.text),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BeigeColors.dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BeigeColors.dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BeigeColors.accent, width: 2),
        ),
        filled: true,
        fillColor: BeigeColors.light,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return loc.get('email_required');
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return loc.get('email_invalid');
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations loc) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: loc.get('password'),
        hintText: loc.get('password_hint'),
        prefixIcon: Icon(Icons.lock, color: BeigeColors.text),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: BeigeColors.text,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BeigeColors.dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BeigeColors.dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BeigeColors.accent, width: 2),
        ),
        filled: true,
        fillColor: BeigeColors.light,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return loc.get('password_required');
        }
        if (value.length < 6) {
          return loc.get('password_too_short');
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(AppLocalizations loc) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: BeigeColors.accent,
        foregroundColor: BeigeColors.text,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: BeigeColors.text,
              ),
            )
          : Text(
              _isLoginMode ? loc.get('login') : loc.get('register'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildModeToggleButton(AppLocalizations loc) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLoginMode = !_isLoginMode;
        });
      },
      child: Text(
        _isLoginMode
            ? loc.get('no_account_register')
            : loc.get('have_account_login'),
        style: TextStyle(color: BeigeColors.accent, fontSize: 14),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      bool success;

      if (_isLoginMode) {
        success = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authService.register(
          _emailController.text.trim(),
          _passwordController.text,
          _emailController.text.split('@')[0], // 임시 사용자명
        );
      }

      if (success && mounted) {
        // 로그인 성공 시 이전 화면으로 돌아가기
        Navigator.of(context).pop();
      } else if (mounted) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLoginMode
                  ? AppLocalizations.of(context).get('login_failed')
                  : AppLocalizations.of(context).get('register_failed'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).get('error_occurred')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
