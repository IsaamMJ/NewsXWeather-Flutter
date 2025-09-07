import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/regex_patterns.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/image_paths.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/sign_up_controller.dart';
import '../../../../core/theme/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode reEnterPasswordFocusNode = FocusNode();

  bool _hasAttemptedSubmit = false;
  bool _isPasswordVisible = false;
  bool _isReEnterPasswordVisible = false;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    reEnterPasswordFocusNode.dispose();
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
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.getPrimary(context).withOpacity(0.2),
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
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool isLast = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.getPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus
                  ? AppColors.getPrimary(context)
                  : AppColors.getPrimary(context).withOpacity(0.2),
              width: 1.5,
            ),
            color: AppColors.getCardColor(context),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText && !isPasswordVisible,
            keyboardType: keyboardType,
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
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: focusNode.hasFocus
                      ? AppColors.getPrimary(context)
                      : AppColors.getPrimary(context).withOpacity(0.6),
                  size: 20,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.getPrimary(context).withOpacity(0.6),
                  size: 20,
                ),
                onPressed: onVisibilityToggle,
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: const TextStyle(
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSignUp() async {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Focus on first invalid field
      if (emailFocusNode.canRequestFocus) {
        FocusScope.of(context).requestFocus(emailFocusNode);
      }
      return;
    }

    final SignUpController controller = Get.find();
    await controller.signUpWithEmail();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Smaller, more subtle background
    final backgroundHeight = (height * 0.25).clamp(180.0, 250.0);

    return Obx(() {
      final controller = Get.find<SignUpController>();
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.getBackground(context),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Background Header
            Container(
              height: backgroundHeight,
              width: width,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, 40), // Reduced offset
                        child: Transform.scale(
                          scale: 1.1, // Slightly scale up to fill edges
                          child: Image.asset(
                            Theme.of(context).brightness == Brightness.dark
                                ? ImagePaths.signUpBackground1
                                : ImagePaths.signUpBackground2,
                            fit: BoxFit.cover,
                            opacity: const AlwaysStoppedAnimation(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Welcome overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Join us today and start your journey",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content - Scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                ),
                child: Column(
                  children: [
                    // SignUp Form
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.getCardColor(context),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getPrimary(context).withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Field
                              _buildFormField(
                                controller: controller.emailController,
                                focusNode: emailFocusNode,
                                nextFocusNode: passwordFocusNode,
                                label: "Email Address",
                                hintText: "Enter your email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              _buildFormField(
                                controller: controller.passwordController,
                                focusNode: passwordFocusNode,
                                nextFocusNode: reEnterPasswordFocusNode,
                                label: "Password",
                                hintText: "Enter your password",
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
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$')
                                      .hasMatch(value)) {
                                    return 'Password must contain uppercase, lowercase, number and special character';
                                  }
                                  return null;
                                },
                              ),

                              // Password Strength Indicator
                              _buildPasswordStrengthIndicator(),

                              const SizedBox(height: 20),

                              // Confirm Password Field
                              _buildFormField(
                                controller: controller.reEnterPasswordController,
                                focusNode: reEnterPasswordFocusNode,
                                label: "Confirm Password",
                                hintText: "Re-enter your password",
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
                                    return 'Please confirm your password';
                                  }
                                  if (value != controller.passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // SignUp Button
                              ElevatedButton(
                                onPressed: _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.getPrimary(context),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: AppColors.getPrimary(context).withOpacity(0.3),
                                ),
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Link
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: AppColors.getPrimary(context).withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.offNamed(AppRoutes.login),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  color: AppColors.getSecondary(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.getSecondary(context),
                                ),
                              ),
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
    });
  }
}