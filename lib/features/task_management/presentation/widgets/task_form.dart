import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../data/models/priority.dart';
import '../../../categories/data/models/category.dart';
import 'priority_badge.dart';
import 'category_selection_widget.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final List<Category> availableCategories;
  final Function(Task) onSave;

  const TaskForm({
    super.key,
    this.task,
    required this.availableCategories,
    required this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Priority _selectedPriority;
  late DateTime? _selectedDueDate;
  late String? _selectedCategoryId;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedPriority = widget.task?.priority ?? Priority.medium;
    _selectedDueDate = widget.task?.dueDate;
    _isCompleted = widget.task?.isCompleted ?? false;
    _selectedCategoryId = widget.task?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter task title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter task description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Priority',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: Priority.values.map((priority) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = priority),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _selectedPriority == priority
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: _selectedPriority == priority
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: PriorityBadge(
                      priority: priority,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          // Text(
          //   'Category',
          //   style: TextStyle(
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.w600,
          //     color: Theme.of(context).colorScheme.onSurface,
          //   ),
          // ),
          // SizedBox(height: 8.h),
          CategorySelectionWidget(
            availableCategories: widget.availableCategories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (categoryId) {
              setState(() => _selectedCategoryId = categoryId);
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDueDate != null
                      ? 'Due: ${_formatDate(_selectedDueDate!)}'
                      : 'No due date',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _selectDueDate,
                icon: Icon(
                  Icons.calendar_today,
                  size: 20.sp,
                ),
                label: Text(
                  _selectedDueDate != null ? 'Change' : 'Set Due Date',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              if (_selectedDueDate != null)
                IconButton(
                  onPressed: () => setState(() => _selectedDueDate = null),
                  icon: Icon(
                    Icons.clear,
                    size: 20.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          CheckboxListTile(
            title: Text(
              'Mark as completed',
              style: TextStyle(fontSize: 14.sp),
            ),
            value: _isCompleted,
            onChanged: (value) => setState(() => _isCompleted = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                widget.task != null ? 'Update Task' : 'Create Task',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedDueDate = pickedDate);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      isCompleted: _isCompleted,
      dueDate: _selectedDueDate,
      categoryId: _selectedCategoryId,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(task);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}