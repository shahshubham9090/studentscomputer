import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/error_handler.dart';
// import '../admin/admin_home_screen.dart'; // Removed to decouple
// import '../user/user_home_screen.dart'; // Removed to decouple

class LoginScreen extends StatefulWidget {
  final UserRole targetRole;

  const LoginScreen({
    super.key, 
    this.targetRole = UserRole.user
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _secretKeyController = TextEditingController();

  static const String _adminSecret = "admin123";

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_isLogin) {
        // LOGIN logic
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        // Wait for auth provider to finish loading user data
        // The auth state listener will fetch user details asynchronously
        int waitCount = 0;
        while (authProvider.isLoading && waitCount < 50) {
          await Future.delayed(const Duration(milliseconds: 100));
          waitCount++;
        }
        
        // Post-login check: Is the user actually authorized for this portal?
        final currentUser = authProvider.currentUser;
        if (currentUser == null) {
          throw Exception("Failed to load user data after login");
        }
        
        if (currentUser.role != widget.targetRole) {
           // Mismatch!
           await authProvider.logout();
           throw Exception("Unauthorized: This account is not a ${widget.targetRole.name} account.");
        }

      } else {
        // SIGNUP logic
        if (widget.targetRole == UserRole.admin) {
           if (_secretKeyController.text.trim() != _adminSecret) {
             throw Exception("Invalid Admin Secret Key");
           }
        }

        await authProvider.signup(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          widget.targetRole,
        );
      }
      
      if (mounted) {
        // Success - Navigate directly to the appropriate home screen using named routes
        final routeName = widget.targetRole == UserRole.admin
            ? '/admin-home'
            : widget.targetRole == UserRole.teacher
                ? '/teacher-home'
                : '/user-home';
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
        );
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppErrorHandler.getErrorMessage(e);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();
      
      if (mounted) {
        final routeName = widget.targetRole == UserRole.admin
            ? '/admin-home'
            : widget.targetRole == UserRole.teacher
                ? '/teacher-home'
                : '/user-home';
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppErrorHandler.getErrorMessage(e);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email Address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.resetPassword(emailController.text.trim());
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent! Please check your inbox.'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppErrorHandler.getErrorMessage(e)),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdminPortal = widget.targetRole == UserRole.admin;
    final bool isTeacherPortal = widget.targetRole == UserRole.teacher;
    final backgroundGradient = isAdminPortal
        ? const LinearGradient(
            colors: [Colors.indigo, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : isTeacherPortal
            ? const LinearGradient(
                colors: [Colors.teal, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppGradients.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdminPortal 
            ? "Admin Portal" 
            : isTeacherPortal 
                ? "Teacher Portal" 
                : "Quiz Master"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: backgroundGradient,
            ),
          ),
          
          // 2. Decorative Circles
          Positioned(top: -50, left: -50, child: _bubble(200)),
          Positioned(top: 100, right: -30, child: _bubble(150)),

          // 4. Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const SizedBox(height: 60), // AppBar spacer
                   Icon(
                      isAdminPortal 
                          ? Icons.admin_panel_settings 
                          : isTeacherPortal 
                              ? Icons.assignment_ind 
                              : Icons.school,
                      size: 64, color: Colors.white,
                   ),
                   const SizedBox(height: AppSpacing.m),
                   Text(
                    isAdminPortal 
                        ? "Admin Access" 
                        : isTeacherPortal 
                            ? "Teacher Access" 
                            : "Quiz Master",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                        Shadow(
                          color: AppColors.primary.withOpacity(0.3),
                          offset: const Offset(0, 0),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                   ),

                  const SizedBox(height: AppSpacing.xl),

                  // Auth Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Toggle
                          _buildAuthToggle(),
                          const SizedBox(height: AppSpacing.l),

                          if (!_isLogin) ...[
                             CustomTextField(
                              label: 'Display Name',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v!.isEmpty ? 'Please enter name' : null,
                            ),
                            const SizedBox(height: AppSpacing.m),
                          ],

                          CustomTextField(
                            key: ValueKey(_isLogin ? 'login_email' : 'signup_email'),
                            label: 'Email Address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (v) => v!.isEmpty ? 'Please enter email' : null,
                          ),
                          const SizedBox(height: AppSpacing.m),

                          CustomTextField(
                            key: ValueKey(_isLogin ? 'login_password' : 'signup_password'),
                            label: 'Password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (v) {
                              if (v!.isEmpty) return 'Please enter password';
                              if (!_isLogin && v.length < 6) return 'Password too short (min 6)';
                              return null;
                            },
                          ),

                          // Forgot Password Link (visible in login mode for both students and admins)
                          if (_isLogin) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // ADMIN SECRET KEY Field
                          if (!_isLogin && isAdminPortal) ...[
                            const SizedBox(height: AppSpacing.m),
                            CustomTextField(
                              key: const ValueKey('admin_secret'),
                              label: 'Admin Secret Key',
                              controller: _secretKeyController,
                              obscureText: true,
                              prefixIcon: Icons.vpn_key_outlined,
                              validator: (v) => v!.isEmpty ? 'Required for Admin signup' : null,
                            ),
                          ],

                          // Error Display
                           if (_errorMessage != null || Provider.of<AuthProvider>(context).authError != null) ...[
                            const SizedBox(height: AppSpacing.m),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage ?? Provider.of<AuthProvider>(context).authError!,
                                      style: const TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xl),

                          GradientButton(
                            text: _isLogin ? 'Login' : 'Sign Up',
                            onPressed: _submit,
                            isLoading: _isLoading,
                            gradient: backgroundGradient,
                          ),
                          
                          const SizedBox(height: AppSpacing.m),

                          if (!isAdminPortal) ...[
                            Row(
                              children: [
                                Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text("OR", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.m),
                            
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _googleSignIn,
                              icon: const Icon(Icons.g_mobiledata, size: 24), // Fallback icon or using Image.network
                              label: const Text("Continue with Google", style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.m),
                          ],
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (widget.targetRole != UserRole.user)
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen(targetRole: UserRole.user)),
                                    );
                                  },
                                  child: Text(
                                    "Student Portal",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              if (widget.targetRole != UserRole.teacher)
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen(targetRole: UserRole.teacher)),
                                    );
                                  },
                                  child: Text(
                                    "Teacher Portal",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              if (widget.targetRole != UserRole.admin)
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen(targetRole: UserRole.admin)),
                                    );
                                  },
                                  child: Text(
                                    "Admin Portal",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Stack(
        children: [
          // Animated Pill Background
          AnimatedAlign(
            alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Text Buttons
          Row(
            children: [
              Expanded(child: _buildToggleItem("Login", true)),
              Expanded(child: _buildToggleItem("Sign Up", false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String text, bool isLoginTab) {
    final bool isActive = (_isLogin == isLoginTab);
    
    return GestureDetector(
      onTap: () {
        if (!isActive) _toggleAuthMode();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
