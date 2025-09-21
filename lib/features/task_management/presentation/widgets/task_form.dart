import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/task.dart';
import '../../data/models/priority.dart';
import '../../data/models/task_attachment.dart';
import '../../../categories/data/models/category.dart';
import 'priority_badge.dart';
import 'category_selection_widget.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final List<Category> availableCategories;
  final Function(Task) onSave;
  @override
  final GlobalKey<TaskFormState> key;
  final Priority? defaultPriority;
  final String? defaultCategoryId;

  const TaskForm({
    required this.key,
    this.task,
    required this.availableCategories,
    required this.onSave,
    this.defaultPriority,
    this.defaultCategoryId,
  }) : super(key: key);

  @override
  State<TaskForm> createState() => TaskFormState();
}

class TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late Priority _selectedPriority;
  late DateTime? _selectedDueDate;
  late String? _selectedCategoryId;
  late bool _isCompleted;
  late List<TaskAttachment> _attachments;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _urlController = TextEditingController();
    _selectedPriority = widget.task?.priority ?? widget.defaultPriority ?? Priority.medium;
    _selectedDueDate = widget.task?.dueDate;
    _isCompleted = widget.task?.isCompleted ?? false;
    _selectedCategoryId = widget.task?.categoryId ?? widget.defaultCategoryId;
    _attachments = List.from(widget.task?.attachments ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // Public method to trigger save from external callers (like AppBar save button)
  void save() {
    _saveTask();
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
          Text(
            'Attachments',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          // URL input section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Enter URL...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  onSubmitted: (_) => _addUrlAttachment(),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _addUrlAttachment,
                icon: Icon(Icons.add_link),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Image picker button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addImageAttachment,
              icon: Icon(Icons.image),
              label: Text('Add Image'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Attachments list
          if (_attachments.isNotEmpty) ...[
            Container(
              constraints: BoxConstraints(maxHeight: 150.h),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  final attachment = _attachments[index];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      attachment.type.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20.sp,
                    ),
                    title: Text(
                      attachment.displayName ?? attachment.url,
                      style: TextStyle(fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close, size: 16.sp),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                      onPressed: () => _removeAttachment(attachment),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
          ],
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

  void _addUrlAttachment() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      final attachment = TaskAttachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AttachmentType.url,
        url: url,
        displayName: _extractUrlDisplayName(url),
        createdAt: DateTime.now(),
      );
      setState(() {
        _attachments.add(attachment);
        _urlController.clear();
      });
    }
  }

  Future<void> _addImageAttachment() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final attachment = TaskAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AttachmentType.image,
          url: pickedFile.path,
          displayName: pickedFile.name,
          createdAt: DateTime.now(),
        );
        setState(() {
          _attachments.add(attachment);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _removeAttachment(TaskAttachment attachment) {
    setState(() {
      _attachments.remove(attachment);
    });
  }

  String _extractUrlDisplayName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (e) {
      // If URL parsing fails, return the URL as is
    }
    return url;
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Automatically add any URL in the text field as an attachment
    final urlText = _urlController.text.trim();
    if (urlText.isNotEmpty) {
      _addUrlAttachment();
    }

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
      attachments: _attachments,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(task);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}