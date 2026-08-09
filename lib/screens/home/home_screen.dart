import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:student_task_manager_app/utils/app_colors.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';
import '../task/add_edit_task_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _filterPriority = 'All';
  String _filterStatus = 'All';

  // Mock Data
  final List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'Complete Flutter Assignment',
      description: 'Finish the Student Task Manager App UI',
      subject: 'Mobile App Dev',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: 'High',
    ),
    TaskModel(
      id: '2',
      title: 'Study for Math Quiz',
      description: 'Chapter 4 and 5',
      subject: 'Mathematics',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: 'Medium',
    ),
    TaskModel(
      id: '3',
      title: 'Read Physics Paper',
      description: 'Read the assigned paper on Quantum Mechanics',
      subject: 'Physics',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: 'Low',
      isCompleted: true,
    ),
  ];

  int get pendingTasks => _tasks.where((t) => !t.isCompleted).length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesPriority = _filterPriority == 'All' || task.priority == _filterPriority;
      final matchesStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Completed' && task.isCompleted) ||
          (_filterStatus == 'Pending' && !task.isCompleted);
      return matchesSearch && matchesPriority && matchesStatus;
    }).toList();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  void _toggleTaskComplete(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final task = _tasks[index];
        _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () async {
                            final updatedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTaskScreen(task: task),
                              ),
                            );
                            if (updatedTask != null) {
                              setState(() {
                                final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
                                if (index != -1) _tasks[index] = updatedTask;
                              });
                            }
                          },
                          onToggleComplete: () => _toggleTaskComplete(task.id),
                          onDelete: () => _deleteTask(task.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              _tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Student! 👋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Pending',
                  pendingTasks.toString(),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Completed',
                  completedTasks.toString(),
                  AppColors.completedTask,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterPriority,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: ['All', 'High', 'Medium', 'Low']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => _filterPriority = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterStatus,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: ['All', 'Pending', 'Completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _filterStatus = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using a placeholder Lottie URL or fallback to an Icon if lottie fails.
          SizedBox(
            height: 150,
            child: Lottie.network(
              'https://lottie.host/80dc687c-21a4-46f9-a29d-ee1375d8d85f/793D8cZz7O.json',
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.task, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks found!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a new task or change your filters.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
