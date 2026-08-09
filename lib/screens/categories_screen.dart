import 'package:flutter/material.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/task_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/utils/app_colors.dart';
import 'package:student_task_manager_app/utils/urls.dart';
import 'package:student_task_manager_app/widget/task_card.dart';
import 'package:student_task_manager_app/widget/user_header.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<String> filters = ['All', 'New', 'Progress', 'Completed', 'Cancelled'];
  String selectedFilter = 'All';
  List<TaskModel> tasks = [];
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future<void> getTasks() async {
    if (mounted) setState(() { inProgress = true; });
    List<TaskModel> result = [];

    if (selectedFilter == 'All') {
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
    } else {
      final ApiResponse response = await ApiCaller.getRequest(
        url: TMUrls.getTaskByStatusURL(selectedFilter),
      );

      if (response.isSuccess && response.responseData['data'] != null) {
        for (Map<String, dynamic> jsonData in (response.responseData['data'])) {
          result.add(TaskModel.fromJson(jsonData));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.errorMessage ?? 'Failed to load tasks')),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const UserHeader(),
          const SizedBox(height: 12),
          SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = filter == selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() { selectedFilter = filter; });
                    getTasks();
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: inProgress
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: getTasks,
                    child: tasks.isEmpty
                        ? const Center(child: Text("No tasks in this category"))
                        : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                taskModel: task,
                                CardColor: colorForStatus(task.status),
                                refreshParent: () async { await getTasks(); },
                              );
                            },
                          ),
                  ),
          )
        ],
      ),
    );
  }
}
