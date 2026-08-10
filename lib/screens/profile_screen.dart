import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_task_manager_app/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  XFile? _pickedImage;
  String? _base64Image;
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    emailController.text = user?.email ?? '';
    firstNameController.text = user?.firstName ?? '';
    lastNameController.text = user?.lastName ?? '';
    mobileController.text = user?.mobile ?? '';
    _base64Image = user?.photo;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
      maxHeight: 150,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> updateProfile() async {
    setState(() { inProgress = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      email: emailController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      mobile: mobileController.text,
      photo: _base64Image,
      password: passwordController.text.isNotEmpty ? passwordController.text : null,
    );

    setState(() { inProgress = false; });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update failed. Image might be too large or API error.')),
        );
      }
    }
  }

  Widget labeledField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (_base64Image != null && _base64Image!.isNotEmpty)
                            ? MemoryImage(base64Decode(_base64Image!.split(',').last)) as ImageProvider
                            : null,
                    child: (_pickedImage == null && (_base64Image == null || _base64Image!.isEmpty))
                        ? Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${firstNameController.text} ${lastNameController.text}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        emailController.text,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            labeledField(label: 'Email', controller: emailController),
            labeledField(label: 'First Name', controller: firstNameController),
            labeledField(label: 'Last Name', controller: lastNameController),
            labeledField(label: 'Mobile', controller: mobileController),
            labeledField(label: 'Password (leave empty to keep current)', controller: passwordController, obscureText: true),
            const SizedBox(height: 10),
            Visibility(
              visible: !inProgress,
              replacement: const Center(child: CircularProgressIndicator()),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  updateProfile();
                },
                child: const Text('Update Profile'),
              ),
            ),
          ],
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
