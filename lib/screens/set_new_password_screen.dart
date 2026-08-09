import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/screens/login_screen.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/screen_bg.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const SetNewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool inProgress = false;

  Future<void> resetPassword() async {
    setState(() { inProgress = true; });

    final ApiResponse response = await ApiCaller.PostRequest(
      url: TMUrls.recoverResetPassURL,
      body: {
        "email": widget.email,
        "OTP": widget.otp,
        "password": passwordController.text,
      },
    );

    setState(() { inProgress = false; });

    if (response.isSuccess && response.responseData['status'] == 'success') {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset success, please sign in')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.responseData?['data']?.toString() ?? 'Password reset failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBG(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                Text('Set Password', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                const Text('Enter your new password to proceed with your account.'),
                const SizedBox(height: 25),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Confirm Password'),
                  validator: (value) {
                    if (value != passwordController.text) return 'Password does not match';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: !inProgress,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        resetPassword();
                      }
                    },
                    child: const Icon(Icons.arrow_circle_right_outlined, size: 25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
