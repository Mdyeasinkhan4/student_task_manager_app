import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_task_manager_app/providers/auth_provider.dart';
import 'package:student_task_manager_app/screens/login_screen.dart';
import 'package:student_task_manager_app/utils/app_colors.dart';
import 'package:student_task_manager_app/widget/screen_bg.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  void onTapSignIn() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool inProgress = false;

  Future<void> signUp() async {
    setState(() { inProgress = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      email: emailController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      mobile: mobileController.text.trim(),
      password: passwordController.text,
    );

    setState(() { inProgress = false; });

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up success....!')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBG(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Text('Join with us', style: Theme.of(context).textTheme.titleLarge),
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(hintText: 'First name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter firstName';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(hintText: 'Last name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter lastName';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Mobile'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile';
                    } else if (value.length < 11) {
                      return 'Please enter valid mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: !inProgress,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: FilledButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        signUp();
                      }
                    },
                    child: const Icon(Icons.arrow_circle_right_outlined, size: 25),
                  ),
                ),
                const SizedBox(height: 35),
                Center(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Already have account? ",
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: const TextStyle(
                                color: AppColors.PColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = onTapSignIn,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
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
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
