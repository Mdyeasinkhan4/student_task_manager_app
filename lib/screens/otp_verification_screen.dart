import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/screens/set_new_password_screen.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/screen_bg.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  bool inProgress = false;

  Future<void> verifyOtp() async {
    setState(() { inProgress = true; });

    final ApiResponse response = await ApiCaller.getRequest(
      url: TMUrls.recoverVerifyOTPURL(widget.email, otpController.text.trim()),
    );

    setState(() { inProgress = false; });

    if (response.isSuccess && response.responseData['status'] == 'success') {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetNewPasswordScreen(
              email: widget.email,
              otp: otpController.text.trim(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.responseData?['data']?.toString() ?? 'Invalid PIN, please try again')),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 250),
              Text('PIN Verification', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              const Text('A 6 digit verification pin was sent to your email address.'),
              const SizedBox(height: 25),
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'PIN'),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: !inProgress,
                replacement: const Center(child: CircularProgressIndicator()),
                child: FilledButton(
                  onPressed: () {
                    verifyOtp();
                  },
                  child: const Icon(Icons.arrow_circle_right_outlined, size: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
