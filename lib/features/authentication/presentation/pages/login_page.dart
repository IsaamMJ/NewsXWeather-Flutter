import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/image_paths.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/login_controller.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _hasAttemptedSubmit = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
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
            obscureText: obscureText && !_isPasswordVisible,
            keyboardType: keyboardType,
            autovalidateMode: _hasAttemptedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            validator: validator,
            onFieldSubmitted: (value) {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              } else if (isLast) {
                _handleLogin();
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
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.getPrimary(context).withOpacity(0.6),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
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

  void _handleLogin() async {
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

    final LoginController controller = Get.find();
    await controller.loginWithEmail();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Smaller, more subtle background
    final backgroundHeight = (height * 0.25).clamp(180.0, 250.0);

    return GetBuilder<LoginController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.getBackground(context),
        body: controller.loading.value
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
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? ImagePaths.loginBackgroundDark
                            : ImagePaths.loginBackground,
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.8),
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
                    // Login Form
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
                                label: "Password",
                                hintText: "Enter your password",
                                icon: Icons.lock_outlined,
                                obscureText: true,
                                isPassword: true,
                                isLast: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Remember Me & Forgot Password Row
                              Row(
                                children: [
                                  // Remember Me
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                            activeColor: AppColors.getPrimary(context),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Remember me",
                                          style: TextStyle(
                                            color: AppColors.getPrimary(context).withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Forgot Password
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implement actual forgot password
                                      Get.snackbar(
                                        "Coming Soon",
                                        "Forgot password feature will be available soon",
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: AppColors.getPrimary(context).withOpacity(0.1),
                                        colorText: AppColors.getPrimary(context),
                                        margin: const EdgeInsets.all(16),
                                        borderRadius: 8,
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: AppColors.getSecondary(context),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Login Button
                              ElevatedButton(
                                onPressed: _handleLogin,
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
                                  "Sign In",
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

                    // Sign Up Link
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: AppColors.getPrimary(context).withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.offNamed(AppRoutes.signup),
                              child: Text(
                                "Sign Up",
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