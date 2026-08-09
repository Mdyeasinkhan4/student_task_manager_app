import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subjectController;
  
  DateTime? _selectedDate;
  String _selectedPriority = 'Medium';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _subjectController = TextEditingController(text: widget.task?.subject ?? '');
    _selectedDate = widget.task?.dueDate;
    _selectedPriority = widget.task?.priority ?? 'Medium';
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
        );
        return;
      }

      final task = TaskModel(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        subject: _subjectController.text,
        dueDate: _selectedDate!,
        priority: _selectedPriority,
        isCompleted: _isCompleted,
      );

      Navigator.pop(context, task);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Task Title',
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a title';
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _subjectController,
                  labelText: 'Subject',
                  prefixIcon: Icons.book,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a subject';
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _descController,
                  labelText: 'Description',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a description';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                
                // Date Picker
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Priority Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: ['Low', 'Medium', 'High']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                ),
                const SizedBox(height: 16),

                if (isEditing)
                  SwitchListTile(
                    title: const Text('Mark as Completed'),
                    value: _isCompleted,
                    onChanged: (val) => setState(() => _isCompleted = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save Task',
                  onPressed: _saveTask,
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
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
