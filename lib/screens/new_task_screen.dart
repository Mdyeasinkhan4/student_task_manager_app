import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/task_model.dart';
import 'package:student_task_manager_app/data/model/task_status_count_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/screens/add_new_task_screen.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/task_card.dart';
import 'package:student_task_manager_app/widget/task_count_by_status.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  List<TaskStatusCountModel> taskCount = [];
  List<TaskModel> tasks = [];
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    getAllTaskCount();
    getAllTask();
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
      setState(() {
        taskCount = taskC;
      });
    }
  }

  Future<void> getAllTask() async {
    if (mounted) setState(() { inProgress = true; });

    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.getTaskByStatusURL('New'));

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

  Future<void> refreshAll() async {
    await getAllTaskCount();
    await getAllTask();
  }

  @override
  Widget build(BuildContext context) {
    List<String> statusOrder = ['New', 'Progress', 'Completed', 'Cancelled'];

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statusOrder.length,
                itemBuilder: (context, index) {
                  final status = statusOrder[index];
                  final task = taskCount.firstWhere(
                    (e) => e.sId == status,
                    orElse: () => TaskStatusCountModel(sId: status, sum: 0),
                  );
                  return TaskCountByStatus(title: task.sId.toString(), count: task.sum ?? 0);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 20);
                },
              ),
            ),
          ),
          Expanded(
            child: inProgress
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: refreshAll,
                    child: tasks.isEmpty
                        ? const Center(child: Text("No new tasks"))
                        : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                taskModel: task,
                                CardColor: Colors.blue,
                                refreshParent: () async {
                                  await refreshAll();
                                },
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
