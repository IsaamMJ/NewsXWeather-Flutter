import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/regex_patterns.dart';
import '../../../../core/constants/strings.dart'; // Import the centralized strings file
import '../../../../core/theme/image_paths.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/sign_up_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/background_section.dart';
import '../widgets/form_fields.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode reEnterPasswordFocusNode = FocusNode();  // Define FocusNode for re-enter password

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    reEnterPasswordFocusNode.dispose(); // Dispose of the re-enter password FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.find();
    final primaryColor = AppColors.getPrimary(context); // Primary color based on theme
    final lightPurpleColor = AppColors.getSecondary(context); // Secondary color

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
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.getCardColor(context),
                            border: Border.all(
                                color: lightPurpleColor.withOpacity(.2)),
                            boxShadow: [
                              BoxShadow(
                                color: lightPurpleColor.withOpacity(.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              // Email Field
                              FormFieldWidget(
                                controller: controller.emailController,
                                focusNode: emailFocusNode,  // Pass the focusNode here
                                hintText: Strings.emailHint,
                                icon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Strings.emailRequired;
                                  }
                                  if (!RegexPatterns.emailRegex.hasMatch(value)) {
                                    return Strings.invalidEmail;
                                  }
                                  return null;
                                },
                                nextFocusNode: passwordFocusNode, // Next focus after email
                              ),

                              // Password Field
                              FormFieldWidget(
                                controller: controller.passwordController,
                                focusNode: passwordFocusNode,  // Pass the focusNode here
                                obscureText: true,
                                hintText: Strings.passwordHint,
                                icon: Icons.lock,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Strings.passwordRequired;
                                  }
                                  if (!RegexPatterns.passwordRegex.hasMatch(value)) {
                                    return Strings.passwordStrength;
                                  }
                                  return null;
                                },
                                nextFocusNode: reEnterPasswordFocusNode,  // Move to re-enter password after password
                              ),

                              // Re-enter Password Field
                              FormFieldWidget(
                                controller: controller.reEnterPasswordController,
                                focusNode: reEnterPasswordFocusNode,  // Pass the focusNode here
                                obscureText: true,
                                hintText: Strings.reEnterPasswordHint,
                                icon: Icons.lock_outline,
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

                    const SizedBox(height: 15),

                    // Sign Up Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final isValid = formKey.currentState?.validate() ?? false;
                            if (!isValid) return;
                            controller.signUpWithEmail();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            backgroundColor: primaryColor,
                          ),
                          child: const Text(
                            Strings.signUpButtonText,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login Link
                    FadeInUp(
                      duration: const Duration(milliseconds: 2000),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.login, preventDuplicates: false),
                          child: Text(
                            Strings.alreadyUserText,
                            style: TextStyle(
                              color: primaryColor.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
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
