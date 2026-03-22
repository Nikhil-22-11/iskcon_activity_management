import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';

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
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // FirestoreService.signIn handles Firebase Auth with automatic fallback
      // to mock credentials when Firebase is not yet configured.
      final user = await FirestoreService().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      final String route;
      if (user.isGuard) {
        route = AppRoutes.guardDashboard;
      } else if (user.isTeacher) {
        route = AppRoutes.teacherDashboard;
      } else if (user.isPrincipal) {
        route = AppRoutes.principalDashboard;
      } else {
        route = AppRoutes.guardDashboard;
      }
      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.deepBlue, AppColors.krishnaBlue],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.krishnaOrange.withAlpha(180), width: 2),
          ),
          child: const Center(
            child: Text('🕉', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.hareKrishna,
          style: TextStyle(
            color: AppColors.krishnaOrange.withAlpha(230),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.login,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! Please sign in to continue.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: AppStrings.email,
                prefixIcon:
                    Icon(Icons.email_outlined, color: AppColors.krishnaBlue),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: AppStrings.password,
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.krishnaBlue),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(AppStrings.loginButton),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'guard@iskcon.org  |  Guard123',
                    style: TextStyle(
                      color: AppColors.textSecondary.withAlpha(160),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'teacher@iskcon.org  |  Teacher123',
                    style: TextStyle(
                      color: AppColors.textSecondary.withAlpha(160),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'principal@iskcon.org  |  Principal123',
                    style: TextStyle(
                      color: AppColors.textSecondary.withAlpha(160),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
