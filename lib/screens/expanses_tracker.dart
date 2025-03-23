// lib/screens/expense_screen.dart
import 'package:budgetok/db_helper.dart';
import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'history.dart'; // Ensure this import is correct

class CategoryItem {
  final int? id;
  final String name;
  final int amount;
  final IconData icon;
  final Color color;

  CategoryItem({
    this.id,
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'section': '', // Will be set by the caller
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  static CategoryItem fromMap(Map<String, dynamic> map, {int amount = 0}) {
    return CategoryItem(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
      amount: amount,
    );
  }
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final dbHelper = DatabaseHelper.instance;

  Map<String, List<CategoryItem>> sections = {
    'Income': [],
    'Accounts': [],
    'Expenses': [],
  };

  CategoryItem? _selectedSourceCategory;
  String? _selectedSourceSection;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    sections.forEach((key, value) => value.clear());

    for (String section in sections.keys) {
      List<Map<String, dynamic>> categoriesMap = await dbHelper.getCategories(
        section,
      );

      for (var categoryMap in categoriesMap) {
        int amount = 0;
        if (section == 'Accounts') {
          amount = await dbHelper.getAccountBalance(categoryMap['id']);
        } else if (section == 'Income' || section == 'Expenses') {
          // Calculate the total amount for Income and Expenses from the history table
          amount = await dbHelper.getSectionTotal(section);
        }

        sections[section]!.add(
          CategoryItem(
            id: categoryMap['id'],
            name: categoryMap['name'],
            icon: IconData(categoryMap['icon'], fontFamily: 'MaterialIcons'),
            color: Color(categoryMap['color']),
            amount: amount,
          ),
        );
      }
    }
    setState(() {});
  }

  Future<int> getSectionTotal(String section) async {
    if (section == 'Accounts') {
      return await dbHelper.getSectionTotal(section);
    } else {
      // For Income and Expenses, calculate from loaded categories
      int total = 0;
      for (var item in sections[section]!) {
        total += item.amount;
      }
      return total;
    }
  }

  void _showAddCategoryDialog(String sectionName) async {
    print('Showing Add Category Dialog for section: $sectionName'); // Debug

    List<Map<String, dynamic>> allCategories = await dbHelper.getCategories(
      sectionName,
    );

    print('All Categories: $allCategories'); // Debug

    // Define default icons and colors
    List<IconData> commonIcons = [
      Icons.category,
      Icons.monetization_on,
      Icons.credit_card,
      Icons.restaurant,
      Icons.shopping_cart,
      Icons.local_taxi,
      Icons.home,
      Icons.flight_takeoff,
      Icons.fitness_center,
      Icons.medical_services,
      Icons.school,
      Icons.movie,
    ];

    List<Color> commonColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
    ];

    // Create a list of available categories (default icons and colors)
    List<CategoryItem> availableCategories = [];

    for (int i = 0; i < commonIcons.length; i++) {
      // Check if the icon is already used in the database
      bool isIconUsed = allCategories.any(
        (cat) => cat['icon'] == commonIcons[i].codePoint,
      );

      if (!isIconUsed) {
        availableCategories.add(
          CategoryItem(
            id: null, // New category, no ID yet
            name: '', // Name will be set by the user
            amount: 0,
            icon: commonIcons[i],
            color: commonColors[i],
          ),
        );
      }
    }

    print('Available Categories: ${availableCategories.length}'); // Debug

    if (availableCategories.isEmpty) {
      print('No available categories, showing create dialog'); // Debug
      _showCreateCategoryDialog(
        sectionName,
        Icons.category, // Provide a default icon
        Colors.grey, // Provide a default color
      );
      return;
    }

    print('Showing Add Category Bottom Sheet'); // Debug

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
                  'Add Category',
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
                  itemCount: availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = availableCategories[index];
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        _showCreateCategoryDialog(
                          sectionName,
                          category.icon,
                          category.color,
                        );
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
                            'New Category',
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

  void _showCreateCategoryDialog(
    String sectionName,
    IconData selectedIcon,
    Color selectedColor,
  ) {
    print('Showing Create Category Dialog for section: $sectionName'); // Debug

    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Create New Category',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Selected Icon',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(selectedIcon, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Create', style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    Navigator.pop(context);

                    Map<String, dynamic> categoryMap = {
                      'name': nameController.text.trim(),
                      'section': sectionName,
                      'icon': selectedIcon.codePoint,
                      'color': selectedColor.value,
                    };

                    print('Inserting category: $categoryMap'); // Debug

                    try {
                      await dbHelper.insertCategory(categoryMap);
                      await _loadCategories();
                    } catch (e) {
                      print('Error inserting category: $e'); // Debug
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create category.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  void _handleCategorySelection(CategoryItem item, String sectionName) {
    if (_selectedSourceCategory == null) {
      setState(() {
        _selectedSourceCategory = item;
        _selectedSourceSection = sectionName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: ${item.name}. Now select destination.'),
          duration: Duration(seconds: 2),
          backgroundColor: item.color,
        ),
      );
    } else {
      if (_selectedSourceCategory?.id == item.id &&
          _selectedSourceSection == sectionName) {
        setState(() {
          _selectedSourceCategory = null;
          _selectedSourceSection = null;
        });
        return;
      }

      _showTransferDialog(
        _selectedSourceCategory!,
        _selectedSourceSection!,
        item,
        sectionName,
      );
    }
  }

  void _showTransferDialog(
    CategoryItem sourceCategory,
    String sourceSection,
    CategoryItem targetCategory,
    String targetSection,
  ) {
    // Prevent transfers between the same section unless it's Accounts
    if (sourceSection == targetSection && sourceSection != 'Accounts') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot transfer between the same section.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prevent invalid transfers (e.g., Accounts to Income)
    if (sourceSection == 'Accounts' && targetSection == 'Income') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot transfer from Accounts to Income.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Transfer', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'From: ${sourceCategory.name} (${sourceSection})',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'To: ${targetCategory.name} (${targetSection})',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Transfer', style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  if (amountController.text.trim().isNotEmpty) {
                    try {
                      int amount = int.parse(amountController.text.trim());

                      await dbHelper.transfer(
                        fromCategoryId: sourceCategory.id,
                        toCategoryId: targetCategory.id,
                        amount: amount,
                        description: descriptionController.text,
                      );

                      await _loadCategories();

                      Navigator.pop(context);
                      setState(() {
                        _selectedSourceCategory = null;
                        _selectedSourceSection = null;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transfer successful!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
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
              _buildSection('Income', Icons.arrow_downward),
              _buildSection('Accounts', null),
              _buildSection('Expenses', Icons.menu),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSection(String title, IconData? actionIcon) {
    return FutureBuilder<int>(
      future: getSectionTotal(title),
      builder: (context, snapshot) {
        int total = snapshot.data ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                          'COM $total',
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
      },
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
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _buildAddButton(sectionTitle);
        }
        return _buildCategoryItem(items[index], sectionTitle);
      },
    );
  }

  Widget _buildCategoryItem(CategoryItem item, String sectionTitle) {
    final isSelected =
        _selectedSourceCategory?.id == item.id &&
        _selectedSourceSection == sectionTitle;

    return GestureDetector(
      onTap: () => _handleCategorySelection(item, sectionTitle),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              border:
                  isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
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
      ),
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
          _buildNavItem(0, 'Dashboard', Icons.dashboard, true),
          _buildNavItem(
            1,
            'History',
            Icons.history,
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          _buildNavItem(2, 'Chart', Icons.pie_chart, false),
          _buildNavItem(3, 'Report', Icons.insert_chart, false),
          _buildNavItem(4, 'Settings', Icons.settings, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
