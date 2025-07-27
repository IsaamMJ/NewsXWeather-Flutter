import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GetBuilder<LoginController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.getBackground(context),
        body: controller.loading.value
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background Image Area
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40,
                        height: 400,
                        width: width,
                        child: Image.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/images/background_dark.png'
                              : 'assets/images/background.png',
                          fit: BoxFit.cover,
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
                    children: [
                      // Title
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: AppColors.getPrimary(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Form Box
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.getCardColor(context),
                            border: Border.all(
                              color: AppColors.getPrimary(context)
                                  .withOpacity(.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getAccent(context)
                                    .withOpacity(.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                // Email
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Color(0x339C27B0)),
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: controller.emailController,
                                    keyboardType:
                                    TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email",
                                      hintStyle: TextStyle(
                                        color: AppColors.getTextSecondary(
                                            context),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email address is required';
                                      }
                                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Password
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: controller.passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                        color: AppColors.getTextSecondary(
                                            context),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
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
                      const SizedBox(height: 10),

                      // Forgot Password
                      FadeInUp(
                        duration: const Duration(milliseconds: 900),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Coming Soon"),
                                  content: const Text(
                                    "Forgot Password functionality will be available in a future update.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppColors.getSecondary(context),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Login Button
                      FadeIn(
                        duration: const Duration(milliseconds: 1100),
                        child: MaterialButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              controller.loginWithEmail();
                            }
                          },
                          color: AppColors.getPrimary(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 50,
                          minWidth: double.infinity,
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Create Account
                      FadeInUp(
                        duration: const Duration(milliseconds: 1300),
                        child: Center(
                          child: TextButton(
                            onPressed: () => Get.offNamed(AppRoutes.signup),
                            child: Text(
                              "New User? Create Account",
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context)
                                    .withOpacity(0.7),
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
    });
  }
}
