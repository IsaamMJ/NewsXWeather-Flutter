import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/regex_patterns.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/image_paths.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/sign_up_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/background_section.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode reEnterPasswordFocusNode = FocusNode();

  bool _hasAttemptedSubmit = false;
  bool _isPasswordVisible = false;
  bool _isReEnterPasswordVisible = false;
  bool _isLoading = false;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    reEnterPasswordFocusNode.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      _hasDigit = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  Widget _buildPasswordStrengthIndicator() {
    final SignUpController controller = Get.find();
    if (controller.passwordController.text.isEmpty && !passwordFocusNode.hasFocus) {
      return const SizedBox.shrink();
    }

    final requirements = [
      {'text': 'At least 8 characters', 'met': _hasMinLength},
      {'text': 'One uppercase letter', 'met': _hasUppercase},
      {'text': 'One lowercase letter', 'met': _hasLowercase},
      {'text': 'One number', 'met': _hasDigit},
      {'text': 'One special character', 'met': _hasSpecialChar},
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.getSecondary(context).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.getPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((req) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    req['met'] as bool ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: req['met'] as bool
                        ? Colors.green
                        : AppColors.getPrimary(context).withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  req['text'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: req['met'] as bool
                        ? Colors.green
                        : AppColors.getPrimary(context).withOpacity(0.7),
                    decoration: req['met'] as bool
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool isLast = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focusNode.hasFocus
                ? AppColors.getPrimary(context)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText && !isPasswordVisible,
          autovalidateMode: _hasAttemptedSubmit
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: (value) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else if (isLast) {
              _handleSignUp();
            }
          },
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          style: TextStyle(
            color: AppColors.getPrimary(context),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.getPrimary(context).withOpacity(0.5),
              fontSize: 16,
            ),
            prefixIcon: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: focusNode.hasFocus
                      ? AppColors.getPrimary(context)
                      : AppColors.getPrimary(context).withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.getPrimary(context).withOpacity(0.7),
                size: 20,
              ),
              onPressed: onVisibilityToggle,
            )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
              maxWidth: 50,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            errorStyle: const TextStyle(
              fontSize: 12,
              height: 1.2,
            ),
            errorMaxLines: 3,
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    setState(() {
      _hasAttemptedSubmit = true;
      _isLoading = true;
    });

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });

      // Haptic feedback for error
      // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback

      // Show a helpful message
      Get.snackbar(
        'Please check your inputs',
        'Make sure all fields are filled correctly',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    try {
      final SignUpController controller = Get.find();
      await controller.signUpWithEmail();

      // Success feedback
      Get.snackbar(
        'Account Created!',
        'Welcome! Your account has been successfully created.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.find();
    final primaryColor = AppColors.getPrimary(context);
    final lightPurpleColor = AppColors.getSecondary(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Background Section
              BackgroundSection(),

              // Form Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Text(
                        Strings.signUpTitle,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Box
                    FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Form(
                        key: formKey,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.getCardColor(context),
                            border: Border.all(
                                color: lightPurpleColor.withOpacity(.2)),
                            boxShadow: [
                              BoxShadow(
                                color: lightPurpleColor.withOpacity(.15),
                                blurRadius: 25,
                                offset: const Offset(0, 15),
                              )
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              // Email Field
                              _buildFormField(
                                controller: controller.emailController,
                                focusNode: emailFocusNode,
                                nextFocusNode: passwordFocusNode,
                                hintText: Strings.emailHint,
                                icon: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Strings.emailRequired;
                                  }
                                  if (!RegexPatterns.emailRegex.hasMatch(value)) {
                                    return Strings.invalidEmail;
                                  }
                                  return null;
                                },
                              ),

                              // Divider
                              Divider(
                                height: 1,
                                color: lightPurpleColor.withOpacity(.15),
                                indent: 16,
                                endIndent: 16,
                              ),

                              // Password Field
                              _buildFormField(
                                controller: controller.passwordController,
                                focusNode: passwordFocusNode,
                                nextFocusNode: reEnterPasswordFocusNode,
                                hintText: Strings.passwordHint,
                                icon: Icons.lock_outlined,
                                obscureText: true,
                                isPassword: true,
                                isPasswordVisible: _isPasswordVisible,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                onChanged: _checkPasswordStrength,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Strings.passwordRequired;
                                  }
                                  if (!RegexPatterns.passwordRegex.hasMatch(value)) {
                                    return Strings.passwordStrength;
                                  }
                                  return null;
                                },
                              ),

                              // Divider
                              Divider(
                                height: 1,
                                color: lightPurpleColor.withOpacity(.15),
                                indent: 16,
                                endIndent: 16,
                              ),

                              // Re-enter Password Field
                              _buildFormField(
                                controller: controller.reEnterPasswordController,
                                focusNode: reEnterPasswordFocusNode,
                                hintText: Strings.reEnterPasswordHint,
                                icon: Icons.lock_outline,
                                obscureText: true,
                                isPassword: true,
                                isPasswordVisible: _isReEnterPasswordVisible,
                                isLast: true,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _isReEnterPasswordVisible = !_isReEnterPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Strings.passwordRequired;
                                  }
                                  if (value != controller.passwordController.text) {
                                    return Strings.passwordMismatch;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Password Strength Indicator
                    FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: _buildPasswordStrengthIndicator(),
                    ),

                    const SizedBox(height: 15),

                    // Sign Up Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: AnimatedBuilder(
                        animation: _buttonScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScaleAnimation.value,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: primaryColor,
                                  elevation: _isLoading ? 0 : 4,
                                  shadowColor: primaryColor.withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                    : const Text(
                                  Strings.signUpButtonText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login Link
                    FadeInUp(
                      duration: const Duration(milliseconds: 2000),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.login, preventDuplicates: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              Strings.alreadyUserText,
                              style: TextStyle(
                                color: primaryColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}