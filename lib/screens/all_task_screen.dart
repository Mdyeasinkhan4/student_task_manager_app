import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/task_model.dart';
import 'package:student_task_manager_app/data/model/task_status_count_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/screens/add_new_task_screen.dart';
import 'package:student_task_manager_app/utils/app_colors.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/task_card.dart';
import 'package:student_task_manager_app/widget/task_count_by_status.dart';
import 'package:student_task_manager_app/widget/user_header.dart';

class AllTaskScreen extends StatefulWidget {
  const AllTaskScreen({super.key});

  @override
  State<AllTaskScreen> createState() => _AllTaskScreenState();
}

class _AllTaskScreenState extends State<AllTaskScreen> {
  List<TaskStatusCountModel> taskCount = [];
  List<TaskModel> tasks = [];
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    getAllTaskCount();
    getTasks();
  }

  Future<void> getAllTaskCount() async {
    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.getTaskCountURL);

    List<TaskStatusCountModel> taskC = [];

    if (response.isSuccess && response.responseData['data'] != null) {
      for (Map<String, dynamic> jsonData in (response.responseData['data'])) {
        taskC.add(TaskStatusCountModel.fromJson(jsonData));
      }
      taskC.removeWhere((e) => e.sId == null);
    }

    if (mounted) {
      setState(() { taskCount = taskC; });
    }
  }

  Future<void> getTasks() async {
    if (mounted) setState(() { inProgress = true; });

    List<TaskModel> result = [];
    List<String> statuses = ['New', 'Progress', 'Completed', 'Cancelled'];

    List<ApiResponse> responses = await Future.wait(
      statuses.map((s) => ApiCaller.getRequest(url: TMUrls.getTaskByStatusURL(s))),
    );

    for (ApiResponse response in responses) {
      if (response.isSuccess && response.responseData['data'] != null) {
        for (Map<String, dynamic> jsonData in (response.responseData['data'])) {
          result.add(TaskModel.fromJson(jsonData));
        }
      }
    }

    if (mounted) {
      setState(() {
        tasks = result;
        inProgress = false;
      });
    }
  }

  Color colorForStatus(String? status) {
    switch (status) {
      case 'New': return Colors.blue;
      case 'Progress': return Colors.purple;
      case 'Completed': return AppColors.completedTask;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> refreshAll() async {
    await getAllTaskCount();
    await getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const UserHeader(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 4.0),
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ['New', 'Progress', 'Completed', 'Cancelled'].length,
                itemBuilder: (context, index) {
                  final status = ['New', 'Progress', 'Completed', 'Cancelled'][index];
                  final task = taskCount.firstWhere(
                    (e) => e.sId == status,
                    orElse: () => TaskStatusCountModel(sId: status, sum: 0),
                  );
                  return TaskCountByStatus(title: task.sId.toString(), count: task.sum ?? 0);
                },
                separatorBuilder: (context, index) => const SizedBox(width: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: inProgress
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: refreshAll,
                    child: tasks.isEmpty
                        ? const Center(child: Text("No tasks found"))
                        : ListView.builder(
                            itemCount: tasks.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                taskModel: task,
                                CardColor: colorForStatus(task.status),
                                refreshParent: () async { await refreshAll(); },
                              );
                            },
                          ),
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewTaskScreen()));
          refreshAll();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
