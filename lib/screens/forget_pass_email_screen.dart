import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/screens/otp_verification_screen.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/screen_bg.dart';

class ForgetPassEmailScreen extends StatefulWidget {
  const ForgetPassEmailScreen({super.key});

  @override
  State<ForgetPassEmailScreen> createState() => _ForgetPassEmailScreenState();
}

class _ForgetPassEmailScreenState extends State<ForgetPassEmailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool inProgress = false;

  Future<void> sendOtpToEmail() async {
    setState(() { inProgress = true; });

    final String email = emailController.text.trim();
    final ApiResponse response = await ApiCaller.getRequest(
      url: TMUrls.recoverVerifyEmailURL(email),
    );

    setState(() { inProgress = false; });

    if (response.isSuccess) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.responseData?['data']?.toString() ?? 'Failed to send OTP verification email')),
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
                Text(
                  'Your Email Address',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                const Text('A 6 digit verification pin will be sent to your email address.'),
                const SizedBox(height: 25),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
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
                        sendOtpToEmail();
                      }
                    },
                    child: const Icon(
                      Icons.arrow_circle_right_outlined,
                      size: 25,
                    ),
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
    emailController.dispose();
    super.dispose();
  }
}
