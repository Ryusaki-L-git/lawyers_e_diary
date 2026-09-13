import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'ld_logo.dart';
import 'templates/animations/staggered_entry.dart';
import 'templates/transactions/auth_transactions.dart';
import 'templates/utils/app_snackbar.dart';
import 'templates/widgets/app_button.dart';
import 'templates/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
  with SingleTickerProviderStateMixin {
  bool isEmailLoading = false;
  bool isGoogleLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authTransactions = AuthTransactions();
  late final StaggeredEntryController _entryController;

  bool get isLoading => isEmailLoading || isGoogleLoading;

  Widget _entry(int index, Widget child) {
    return StaggeredEntry(
      animation: _entryController.animations[index],
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _entryController = StaggeredEntryController(
      vsync: this,
      itemCount: 7,
    );
    _entryController.controller.forward();
  }

  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);

    try {
      final userCredential = await _authTransactions.signInWithGoogle();
      if (userCredential == null) {
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        'Google Sign-In Firebase error: code=${e.code}, '
        'message=${e.message}\n$stackTrace',
      );

      if (!mounted) return;

      _showSnackBar('Google Sign-In failed: ${e.message ?? e.code}');
    } on PlatformException catch (e, stackTrace) {
      debugPrint(
        'Google Sign-In platform error: code=${e.code}, '
        'message=${e.message}\n$stackTrace',
      );

      if (!mounted) return;

      _showSnackBar('Google Sign-In failed: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Google Sign-In error: $e');

      if (!mounted) return;

      _showSnackBar('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final emailFormat = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    if (!emailFormat.hasMatch(email)) {
      _showSnackBar('Invalid email format');
      return;
    }

    if (password.length < 8) {
      _showSnackBar('Password must be at least 8 characters');
      return;
    }

    setState(() => isEmailLoading = true);

    try {
      await _authTransactions.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        'Email login Firebase error: code=${e.code}, '
        'message=${e.message}\n$stackTrace',
      );

      if (!mounted) return;

      final String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found. Please sign up';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection';
          break;
        default:
          message = 'Login failed. Try again';
      }

      _showSnackBar(message);
    } catch (_) {
      if (mounted) _showSnackBar('Login failed. Try again');
    } finally {
      if (mounted) setState(() => isEmailLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) AppSnackbar.show(context, message);
  }

  void showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Login Help',
            style: TextStyle(color: Colors.black87),
          ),
          content: const Text(
            'Use the email address and password linked to your account. '
            'If you do not have an account yet, select Sign Up or continue '
            'with your Google account.',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  _entry(0, const Center(child: LawFirmMark(width: 120))),
                  const SizedBox(height: 24),
                  _entry(
                    1,
                    const Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to manage your cases and diary.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _entry(
                    2,
                    AppTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _entry(
                    3,
                    AppTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _entry(
                    4,
                    AppButton(
                      label: 'Login',
                      onPressed: login,
                      isLoading: isEmailLoading,
                      loadingColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black12)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.black12)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _entry(
                    5,
                    AppButton(
                      label: 'Continue with Google',
                      onPressed: signInWithGoogle,
                      isLoading: isGoogleLoading,
                      outlined: true,
                      loadingColor: const Color(0xFFD4AF37),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GoogleLogo(size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _entry(
                    6,
                    Column(
                      children: [
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                          child: Text(
                            'Don\'t have an account? Sign Up',
                            style: TextStyle(
                              color: isLoading
                                  ? Colors.black54.withValues(alpha: 0.45)
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : showHelpDialog,
                          child: Text(
                            'Need help?',
                            style: TextStyle(
                              color: isLoading
                                  ? Colors.black54.withValues(alpha: 0.45)
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}