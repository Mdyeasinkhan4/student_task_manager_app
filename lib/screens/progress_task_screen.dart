import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/task_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/task_card.dart';

class ProgressTaskScreen extends StatefulWidget {
  const ProgressTaskScreen({super.key});

  @override
  State<ProgressTaskScreen> createState() => _ProgressTaskScreenState();
}

class _ProgressTaskScreenState extends State<ProgressTaskScreen> {
  List<TaskModel> tasks = [];
  bool inProgress = false;

  Future<void> getAllTask() async {
    if (mounted) setState(() { inProgress = true; });

    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.getTaskByStatusURL('Progress'));
    List<TaskModel> task = [];

    if (response.isSuccess && response.responseData['data'] != null) {
      for (Map<String, dynamic> jsonData in (response.responseData['data'])) {
        task.add(TaskModel.fromJson(jsonData));
      }
    }

    if (mounted) {
      setState(() {
        tasks = task;
        inProgress = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: inProgress
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getAllTask,
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks in progress"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          taskModel: task,
                          CardColor: Colors.purple,
                          refreshParent: () async {
                            await getAllTask();
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
