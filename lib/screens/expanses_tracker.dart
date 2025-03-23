// lib/screens/expense_screen.dart
import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final int amount;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Initial category items with just one default icon per section
  Map<String, List<CategoryItem>> sections = {
    'Income': [
      CategoryItem(
        name: 'Salary',
        amount: 0,
        icon: Icons.monetization_on,
        color: Colors.green,
      ),
    ],
    'Accounts': [
      CategoryItem(
        name: 'MBANK',
        amount: 2896,
        icon: Icons.credit_card,
        color: Colors.red,
      ),
    ],
    'Expenses': [
      CategoryItem(
        name: 'Transport',
        amount: 1306,
        icon: Icons.local_taxi,
        color: Colors.amber,
      ),
    ],
  };

  // Predefined category options for each section
  final Map<String, List<CategoryItem>> categoryOptions = {
    'Income': [
      CategoryItem(
        name: 'Salary',
        icon: Icons.monetization_on,
        color: Colors.green,
        amount: 0,
      ),
      CategoryItem(
        name: 'Freelance',
        icon: Icons.work,
        color: Colors.blue,
        amount: 0,
      ),
    ],
    'Accounts': [
      CategoryItem(
        name: 'MBANK',
        icon: Icons.credit_card,
        color: Colors.red,
        amount: 0,
      ),
      CategoryItem(
        name: 'Cash',
        icon: Icons.money,
        color: Colors.green,
        amount: 0,
      ),
    ],
    'Expenses': [
      CategoryItem(
        name: 'Transport',
        icon: Icons.local_taxi,
        color: Colors.amber,
        amount: 0,
      ),
      CategoryItem(
        name: 'Food',
        icon: Icons.fastfood,
        color: Colors.orange,
        amount: 0,
      ),
    ],
  };

  int getTotalAmount(String section) {
    return sections[section]?.fold(0, (sum, item) => sum! + item.amount) ?? 0;
  }

  void _showAddCategoryDialog(String sectionName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: categoryOptions[sectionName]!.length,
                  itemBuilder: (context, index) {
                    final category = categoryOptions[sectionName]![index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          sections[sectionName]!.add(category);
                        });
                        Navigator.pop(context); // Close the modal
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: category.color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.name,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showExpenseInputModal(CategoryItem item, String sectionName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  onSubmitted: (value) {
                    final amount = int.tryParse(value) ?? 0;
                    setState(() {
                      final index = sections[sectionName]!.indexWhere(
                        (element) =>
                            element.name == item.name &&
                            element.color == item.color,
                      );
                      if (index != -1) {
                        final updatedItem = CategoryItem(
                          name: item.name,
                          amount: amount,
                          icon: item.icon,
                          color: item.color,
                        );
                        sections[sectionName]![index] = updatedItem;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Income Section
              _buildSection('Income', Icons.arrow_downward),

              // Accounts Section
              _buildSection('Accounts', null),

              // Expenses Section
              _buildSection('Expenses', Icons.menu),

              const SizedBox(height: 80), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSection(String title, IconData? actionIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    if (actionIcon != null)
                      Icon(actionIcon, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'COM ${getTotalAmount(title).toString()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCategoryGrid(title),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(String sectionTitle) {
    final items = sections[sectionTitle] ?? [];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length + 1, // +1 for the "add" button
      itemBuilder: (context, index) {
        if (index == items.length) {
          // Last item - "Add" button
          return _buildAddButton(sectionTitle);
        }
        return _buildDraggableCategoryItem(items[index], sectionTitle);
      },
    );
  }

  Widget _buildDraggableCategoryItem(CategoryItem item, String sourceSection) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: {'item': item, 'sourceSection': sourceSection},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
          child: Icon(item.icon, color: Colors.white, size: 24),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCategoryItemContent(item),
      ),
      child: GestureDetector(
        onTap: () => _showExpenseInputModal(item, sourceSection),
        child: DragTarget<Map<String, dynamic>>(
          onAccept: (data) {
            CategoryItem draggedItem = data['item'];
            String sourceSectionName = data['sourceSection'];

            if (sourceSection != sourceSectionName) {
              setState(() {
                // Remove from source section
                sections[sourceSectionName]?.removeWhere(
                  (element) =>
                      element.name == draggedItem.name &&
                      element.amount == draggedItem.amount,
                );

                // Add to target section (current category's section)
                sections[sourceSection]?.add(draggedItem);
              });
            }
          },
          builder: (context, candidateData, rejectedData) {
            return _buildCategoryItemContent(item);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItemContent(CategoryItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
          child: Icon(item.icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 2),
        Text(
          item.name,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        Text(
          'com ${item.amount}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(String sectionTitle) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(sectionTitle),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 2),
          const Text(
            'Add',
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Dashboard', Icons.dashboard),
          _buildNavItem(1, 'History', Icons.history),
          _buildNavItem(2, 'Chart', Icons.pie_chart),
          _buildNavItem(3, 'Report', Icons.insert_chart),
          _buildNavItem(4, 'Settings', Icons.settings),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final bool isSelected = index == 0; // Assume dashboard is selected

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 22),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
