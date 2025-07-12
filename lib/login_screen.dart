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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 72,
            bottom: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 앱 로고/제목
                _buildHeader(loc),
                const SizedBox(height: 60),

                // 이메일 입력 필드
                _buildEmailField(loc),
                const SizedBox(height: 16),

                // 비밀번호 입력 필드
                _buildPasswordField(loc),
                const SizedBox(height: 24),

                // 로그인/회원가입 버튼
                _buildSubmitButton(loc),
                const SizedBox(height: 16),

                // 구분선
                _buildDivider(loc),
                const SizedBox(height: 16),

                // Google 로그인 버튼
                _buildGoogleLoginButton(loc),
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
          loc.get('app_title'),
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
        hintText: loc.get('abc@gmail.com'),
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
        hintText: loc.get(''),
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
      onPressed: _isLoading ? null : () => _handleSubmit(loc),
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
        style: TextStyle(color: BeigeColors.text, fontSize: 14),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: BeigeColors.dark.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            loc.get('or') ?? '또는',
            style: TextStyle(color: BeigeColors.textLight, fontSize: 14),
          ),
        ),
        Expanded(
          child: Divider(
            color: BeigeColors.dark.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton(AppLocalizations loc) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () => _handleGoogleLogin(loc),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: BeigeColors.text,
        side: BorderSide(color: BeigeColors.dark),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.asset(
        'assets/google_logo_new.png',
        height: 20,
        width: 20,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.g_mobiledata, size: 20, color: BeigeColors.text);
        },
      ),
      label: Text(
        loc.get('google_login') ?? 'Google로 로그인',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _handleGoogleLogin(AppLocalizations loc) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await authService.value.googleLogin();

      if (success && mounted) {
        // 로그인 성공 시 이전 화면으로 돌아가기
        Navigator.of(context).pop();
      } else if (mounted) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.get('google_login_failed') ?? 'Google 로그인에 실패했습니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: BeigeColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (loc.get('error_occurred') ?? '오류가 발생했습니다: ') + e.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: BeigeColors.error,
          ),
        );
        print(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSubmit(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginMode) {
        success = await authService.value.login(email, password);
      } else {
        success = await authService.value.register(
          email,
          password,
          _emailController.text.split('@')[0],
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
                  ? loc.get('login_failed')
                  : loc.get('register_failed'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: BeigeColors.error,
          ),
        );

        // 비밀번호 입력칸 초기화
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.get('error_occurred') + e.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: BeigeColors.error,
          ),
        );
        print(e);
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
