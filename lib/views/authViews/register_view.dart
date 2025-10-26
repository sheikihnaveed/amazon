import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/color_themes.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';

class RegisterView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> showPassword = ValueNotifier<bool>(false);

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Amazon Logo
                Center(child: Image.network(amazonLogo, height: 40)),
                const SizedBox(height: 10),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create account",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password
                ValueListenableBuilder<bool>(
                  valueListenable: showPassword,
                  builder: (context, value, _) {
                    return TextFormField(
                      controller: passwordController,
                      obscureText: !value,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 15),

                // Confirm Password
                ValueListenableBuilder<bool>(
                  valueListenable: showPassword,
                  builder: (context, value, _) {
                    return TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !value,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value.trim() != passwordController.text.trim()) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    );
                  },
                ),

                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: showPassword,
                      builder: (context, value, _) {
                        return Checkbox(
                          value: value,
                          activeColor: activeCyanColor,
                          onChanged: (v) => showPassword.value = v!,
                        );
                      },
                    ),
                    const Text("Show password"),
                  ],
                ),

                const SizedBox(height: 10),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await authProvider.register(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            context,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text("Registration failed: $e")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                      "Create your Amazon account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Already have an account?"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 15),

                // Sign in Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Footer
                Column(
                  children: [
                    Text(
                      "Conditions of Use  Privacy Notice",
                      style: TextStyle(color: Colors.blue[800], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "© 1996-2025, Amazon.com, Inc. or its affiliates",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
