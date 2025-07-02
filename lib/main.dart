import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const TodoListApp(),
    );
  }
}

class Task {
  String title;
  DateTime dateTime;
  bool isDone;

  Task({required this.title, required this.dateTime, this.isDone = false});
}

class TodoListApp extends StatefulWidget {
  const TodoListApp({super.key});
  @override
  State<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  final List<Task> _tasks = [];

  void _addOrEditTask({Task? existingTask, int? index}) {
    final TextEditingController titleCtrl = TextEditingController(
      text: existingTask != null ? existingTask.title : '',
    );
    String selectedDay = 'Today';
    TimeOfDay? selectedTime = existingTask != null
        ? TimeOfDay.fromDateTime(existingTask.dateTime)
        : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existingTask == null ? 'Add Task' : 'Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedDay,
                    onChanged: (value) =>
                        setStateDialog(() => selectedDay = value!),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                      DropdownMenuItem(
                        value: 'Tomorrow',
                        child: Text('Tomorrow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      selectedTime = await showTimePicker(
                        context: context,
                        initialTime:
                            selectedTime ??
                            TimeOfDay.fromDateTime(DateTime.now()),
                      );
                      setStateDialog(() {});
                    },
                    child: Text(
                      selectedTime == null
                          ? 'Select Time'
                          : selectedTime!.format(context),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty || selectedTime == null)
                      return;

                    final now = DateTime.now();
                    final date = selectedDay == 'Today'
                        ? now
                        : now.add(const Duration(days: 1));
                    final taskTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    setState(() {
                      if (existingTask == null) {
                        _tasks.add(
                          Task(
                            title: titleCtrl.text.trim(),
                            dateTime: taskTime,
                          ),
                        );
                      } else if (index != null) {
                        _tasks[index] = Task(
                          title: titleCtrl.text.trim(),
                          dateTime: taskTime,
                          isDone: existingTask.isDone,
                        );
                      }
                    });

                    Navigator.of(ctx).pop();
                  },
                  child: Text(existingTask == null ? 'Add' : 'Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTask(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _tasks.removeAt(index));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        color: task.isDone ? Colors.tealAccent.shade100 : Colors.tealAccent,
        child: ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => setState(() => task.isDone = !task.isDone),
            shape: const CircleBorder(),
            activeColor: Colors.green,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isDone ? Colors.grey : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            DateFormat.yMd().add_jm().format(task.dateTime),
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: Wrap(
            spacing: 4,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () =>
                    _addOrEditTask(existingTask: task, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _confirmDeleteTask(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To‑Do List'), centerTitle: true),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet!'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) =>
                  _buildTaskTile(_tasks[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
