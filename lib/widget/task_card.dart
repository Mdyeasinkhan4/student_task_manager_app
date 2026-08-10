import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/task_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/utils/app_colors.dart';
import 'package:student_task_manager_app/utils/urls.dart';

class TaskCard extends StatefulWidget {
  final TaskModel taskModel;
  final Color CardColor;
  final VoidCallback refreshParent;

  const TaskCard({
    super.key,
    required this.taskModel,
    required this.CardColor,
    required this.refreshParent,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool deleting = false;
  bool updating = false;

  String get formattedDate {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(widget.taskModel.createdDate!));
    } catch (_) {
      return widget.taskModel.createdDate ?? "";
    }
  }

  Future<void> deleteTask() async {
    setState(() => deleting = true);

    ApiResponse response = await ApiCaller.getRequest(
      url: TMUrls.deleteTaskURL(widget.taskModel.sId!),
    );

    setState(() => deleting = false);

    if (response.isSuccess) {
      widget.refreshParent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task Deleted"),
          ),
        );
      }
    }
  }

  Future<void> changeStatus(String status) async {
    Navigator.pop(context);

    setState(() => updating = true);

    ApiResponse response = await ApiCaller.getRequest(
      url: TMUrls.updateTaskStatusURL(
        widget.taskModel.sId!,
        status,
      ),
    );

    setState(() => updating = false);

    if (response.isSuccess) {
      widget.refreshParent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task Updated"),
          ),
        );
      }
    }
  }

  Color chipColor() {
    switch (widget.taskModel.status) {
      case "New":
        return AppColors.newTask;
      case "Progress":
        return AppColors.progressTask;
      case "Completed":
        return const Color.fromARGB(255, 58, 237, 147);
      case "Cancelled":
        return AppColors.cancelledTask;
      default:
        return Colors.grey;
    }
  }

  Color priorityColor() {
    switch (widget.taskModel.priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  void showStatusDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Update Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              statusTile("New"),
              statusTile("Progress"),
              statusTile("Completed"),
              statusTile("Cancelled"),
            ],
          ),
        );
      },
    );
  }

  Widget statusTile(String status) {
    bool selected = widget.taskModel.status == status;

    return Card(
      elevation: selected ? 2 : 0,
      color: selected ? AppColors.primaryColor : Colors.grey.shade100,
      child: ListTile(
        onTap: () => changeStatus(status),
        title: Text(
          status,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.check_circle,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskModel.title ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.taskModel.description ?? '',
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor(),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    widget.taskModel.status ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.taskModel.priority != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: priorityColor()),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, size: 12, color: priorityColor()),
                        const SizedBox(width: 4),
                        Text(
                          widget.taskModel.priority!,
                          style: TextStyle(
                            color: priorityColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                updating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        onPressed: showStatusDialog,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.orange,
                        ),
                      ),
                deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        onPressed: deleteTask,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
