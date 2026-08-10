import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/screens/main_nav_screen.dart';
import 'package:student_task_manager_app/utils/app_colors.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/screen_bg.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key});

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedPriority = 'Low';
  bool inProgress = false;

  Future<void> createTask() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() { inProgress = true; });

    final ApiResponse response = await ApiCaller.PostRequest(
      url: TMUrls.CreateTaskURL,
      body: {
        "title": titleController.text.trim(),
        "description": "${descriptionController.text.trim()} [[P:$selectedPriority]]",
        "status": "New",
      },
    );

    setState(() { inProgress = false; });

    if (response.isSuccess) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.responseData?['data']?.toString() ?? response.errorMessage ?? 'Failed to create task')),
        );
      }
    }
  }

  Widget _priorityChip(String priority) {
    bool isSelected = selectedPriority == priority;
    return ChoiceChip(
      label: Text(priority),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedPriority = priority;
          });
        }
      },
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
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
              const SizedBox(height: 100),
              Text('Add New Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 25),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 16),
              const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _priorityChip('Low'),
                  const SizedBox(width: 8),
                  _priorityChip('Medium'),
                  const SizedBox(width: 8),
                  _priorityChip('High'),
                ],
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: !inProgress,
                replacement: const Center(child: CircularProgressIndicator()),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.PColor,
                    fixedSize: const Size.fromWidth(double.maxFinite),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    createTask();
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
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
