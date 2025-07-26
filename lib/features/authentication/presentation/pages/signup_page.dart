import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/sign_up_controller.dart';
import '../../../../core/theme/app_colors.dart'; // Make sure this path is correct

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

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    reEnterPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.find();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Define colors dynamically
    final primaryColor = AppColors.getPrimary(context); // Primary color based on theme
    final lightPurpleColor = AppColors.getSecondary(context); // Secondary color

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the layout resizes when the keyboard appears
      backgroundColor: AppColors.getBackground(context), // Background color based on theme
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Handles bottom inset when keyboard appears
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Background Section
              SizedBox(
                height: 400,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: -40,
                      height: 400,
                      width: width,
                      child: FadeInUp(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/s1.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      height: 400,
                      width: width + 20,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/s2.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                        "Let's Get You Started",
                        style: TextStyle(
                          color: primaryColor, // Use the same deep purple as login screen
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
                            color: AppColors.getCardColor(context), // Use dynamic card color
                            border: Border.all(
                                color: lightPurpleColor.withOpacity(.2)), // Light Purple border
                            boxShadow: [
                              BoxShadow(
                                color: lightPurpleColor.withOpacity(.2), // Light Purple shadow
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              // Email
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(196, 135, 198, .3)),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: controller.emailController,
                                  focusNode: emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Email Address",
                                    hintStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: Icon(Icons.email, color: primaryColor), // Purple icon
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email address is required';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).requestFocus(passwordFocusNode);
                                  },
                                ),
                              ),

                              // Password
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(196, 135, 198, .3)),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: controller.passwordController,
                                  focusNode: passwordFocusNode,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: Icon(Icons.lock, color: primaryColor), // Purple icon
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).requestFocus(reEnterPasswordFocusNode);
                                  },
                                ),
                              ),

                              // Re-enter Password
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextFormField(
                                  obscureText: true,
                                  focusNode: reEnterPasswordFocusNode,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Re-enter Password",
                                    hintStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: Icon(Icons.lock_outline, color: primaryColor), // Purple icon
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please re-enter your password';
                                    }
                                    if (value != controller.passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
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
                            backgroundColor: primaryColor, // Use same deep purple color
                          ),
                          child: const Text(
                            'Sign Up',
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
                            "Already a user? Login",
                            style: TextStyle(
                              color: primaryColor.withOpacity(0.7), // Same purple tone
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
