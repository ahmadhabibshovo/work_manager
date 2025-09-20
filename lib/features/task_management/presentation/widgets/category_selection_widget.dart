import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../categories/data/models/category.dart';

class CategorySelectionWidget extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final List<Category> availableCategories;

  const CategorySelectionWidget({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    required this.availableCategories,
  });

  @override
  State<CategorySelectionWidget> createState() => _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeSelectedCategory();
    _filteredCategories = widget.availableCategories;
  }

  @override
  void didUpdateWidget(CategorySelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId ||
        oldWidget.availableCategories != widget.availableCategories) {
      _initializeSelectedCategory();
      _filteredCategories = widget.availableCategories;
    }
  }

  void _initializeSelectedCategory() {
    if (widget.selectedCategoryId != null) {
      final selectedCategory = widget.availableCategories
          .where((cat) => cat.id == widget.selectedCategoryId)
          .firstOrNull;
      if (selectedCategory != null) {
        _controller.text = selectedCategory.name;
      }
    } else {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.availableCategories;
      } else {
        _filteredCategories = widget.availableCategories
            .where((category) =>
                category.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onCategorySelected(Category category) {
    _controller.text = category.name;
    widget.onCategorySelected(category.id);
    setState(() {
      _isDropdownOpen = false;
    });
    _focusNode.unfocus();
  }

  void _onNewCategoryEntered(String categoryName) {
    if (categoryName.trim().isNotEmpty) {
      // Check if category already exists (case insensitive)
      final existingCategory = widget.availableCategories
          .where((cat) => cat.name.toLowerCase() == categoryName.toLowerCase())
          .firstOrNull;

      if (existingCategory != null) {
        // Select existing category
        _onCategorySelected(existingCategory);
      } else {
        // Create new category
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: categoryName.trim(),
          type: CategoryType.other, // Default type for new categories
          description: 'Custom category',
          createdAt: DateTime.now(),
        );

        // Add to available categories (this would normally be handled by repository)
        widget.availableCategories.add(newCategory);
        _onCategorySelected(newCategory);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Select or type category name',
            prefixIcon: const Icon(Icons.category),
            suffixIcon: IconButton(
              icon: Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  _isDropdownOpen = !_isDropdownOpen;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: (value) {
            _filterCategories(value);
            setState(() {
              _isDropdownOpen = true;
            });
          },
          onSubmitted: _onNewCategoryEntered,
          onTap: () {
            setState(() {
              _isDropdownOpen = true;
            });
          },
        ),
        if (_isDropdownOpen && _filteredCategories.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return ListTile(
                  leading: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    category.type.displayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  onTap: () => _onCategorySelected(category),
                  dense: true,
                );
              },
            ),
          ),
        if (_controller.text.isNotEmpty &&
            !_filteredCategories.any((cat) =>
                cat.name.toLowerCase() == _controller.text.toLowerCase()))
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Create new category: "${_controller.text}"',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _onNewCategoryEntered(_controller.text),
                  child: Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}