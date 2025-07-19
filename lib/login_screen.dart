import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
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
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // 키보드가 이미 올라와있는지 확인
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // 키보드가 이미 올라와있으면 딜레이 없이, 아니면 딜레이 후 스크롤
    final delay = keyboardVisible ? 0 : 600;

    Future.delayed(Duration(milliseconds: delay), () {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 64,
            bottom: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 앱 로고/제목
                _buildHeader(loc, colors),
                const SizedBox(height: 60),

                // 이메일 입력 필드
                _buildEmailField(loc, colors),
                const SizedBox(height: 16),

                // 비밀번호 입력 필드
                _buildPasswordField(loc, colors),
                const SizedBox(height: 24),

                // 로그인/회원가입 버튼
                _buildSubmitButton(loc, colors),
                const SizedBox(height: 16),

                // 구분선
                _buildDivider(loc, colors),
                const SizedBox(height: 16),

                // Google 로그인 버튼
                _buildGoogleLoginButton(loc, colors),
                const SizedBox(height: 16),

                // 모드 전환 버튼
                _buildModeToggleButton(loc, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc, CustomColors colors) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.translate, size: 40, color: colors.text),
        ),
        const SizedBox(height: 16),
        Text(
          loc.get('app_title'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoginMode
              ? loc.get('login_subtitle')
              : loc.get('register_subtitle'),
          style: TextStyle(fontSize: 16, color: colors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations loc, CustomColors colors) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onTap: _scrollToBottom,
      decoration: InputDecoration(
        labelText: loc.get('email'),
        hintText: loc.get('abc@gmail.com'),
        prefixIcon: Icon(Icons.email, color: colors.text),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
        filled: true,
        fillColor: colors.light,
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

  Widget _buildPasswordField(AppLocalizations loc, CustomColors colors) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      onTap: _scrollToBottom,
      decoration: InputDecoration(
        labelText: loc.get('password'),
        hintText: loc.get(''),
        prefixIcon: Icon(Icons.lock, color: colors.text),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: colors.text,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
        filled: true,
        fillColor: colors.light,
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

  Widget _buildSubmitButton(AppLocalizations loc, CustomColors colors) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleSubmit(loc),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.text,
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
                color: colors.text,
              ),
            )
          : Text(
              _isLoginMode ? loc.get('login') : loc.get('register'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildModeToggleButton(AppLocalizations loc, CustomColors colors) {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () {
              setState(() {
                _isLoginMode = !_isLoginMode;
              });
            },
      child: Text(
        _isLoginMode
            ? loc.get('no_account_register')
            : loc.get('have_account_login'),
        style: TextStyle(color: colors.text, fontSize: 14),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations loc, CustomColors colors) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: colors.dark.withOpacity(0.3), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            loc.get('or') ?? '또는',
            style: TextStyle(color: colors.textLight, fontSize: 14),
          ),
        ),
        Expanded(
          child: Divider(color: colors.dark.withOpacity(0.3), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton(AppLocalizations loc, CustomColors colors) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () => _handleGoogleLogin(loc),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: colors.text,
        side: BorderSide(color: colors.dark),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.asset(
        'assets/google_logo_new.png',
        height: 20,
        width: 20,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.g_mobiledata, size: 20, color: colors.text);
        },
      ),
      label: Text(
        loc.get('google_login') ?? 'Google로 로그인',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _handleGoogleLogin(AppLocalizations loc) async {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;

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
            backgroundColor: colors.error,
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
            backgroundColor: colors.error,
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
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;

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
            backgroundColor: colors.error,
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
            backgroundColor: colors.error,
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
