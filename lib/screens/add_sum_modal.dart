// lib/widgets/expense_input_modal.dart
import 'package:flutter/material.dart';
import '../models/category.dart';

class ExpenseInputModal extends StatefulWidget {
  final CategoryModel categoryItem;
  final Function(int) onSave;

  const ExpenseInputModal({
    Key? key,
    required this.categoryItem,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ExpenseInputModal> createState() => _ExpenseInputModalState();
}

class _ExpenseInputModalState extends State<ExpenseInputModal> {
  int _amount = 0;
  String _displayAmount = '0';
  int _selectedDate = 22; // Default to 22nd as in the image

  // Dummy data for the calendar
  final List<int> _dates = [20, 21, 22, 23, 24];

  // Controllers for the calculator

  @override
  void initState() {
    super.initState();
    _amount = widget.categoryItem.amount;
    _displayAmount = _amount.toString();
  }

  void _updateAmount(String value) {
    if (value.isEmpty) {
      value = '0';
    }
    setState(() {
      _displayAmount = value;
      _amount = int.tryParse(value) ?? 0;
    });
  }

  void _handleNumberPress(String value) {
    if (_displayAmount == '0') {
      _updateAmount(value);
    } else {
      _updateAmount(_displayAmount + value);
    }
  }

  void _handleOperator(String operator) {
    // This would implement calculator operations
    // For simplicity, we're just handling number input for now
  }

  void _handleEquals() {
    // This would calculate the result
    // For simplicity, we're just using direct input
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Close button and title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expense',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.blue),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Amount display
                  Column(
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'COM $_displayAmount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Account and Category section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Account
                      Column(
                        children: [
                          const Text(
                            'Account',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MBANK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'com 2 896',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Arrows
                      const Icon(Icons.double_arrow, color: Colors.grey),

                      // Category
                      Column(
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.categoryItem.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.categoryItem.color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.categoryItem.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Subcategory
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subcategory',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Question mark button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'no',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Add button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Date selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            _dates.map((date) {
                              final bool isSelected = date == _selectedDate;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.blue
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        isSelected
                                            ? null
                                            : Border.all(
                                              color: Colors.grey.shade700,
                                            ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.toString(),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.grey,
                                        fontSize: 18,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Save button
          InkWell(
            onTap: () {
              widget.onSave(_amount);
              Navigator.pop(context);
              // Example comment: // TODO: Store transaction in SQLite database
            },
            child: Container(
              width: double.infinity,
              height: 50,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Calculator
          Container(
            height: 220,
            color: const Color(0xFF0F0F0F),
            child: Column(
              children: [
                // Calculator header with controls
                Container(
                  height: 40,
                  color: const Color(0xFF1A1A1A),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.refresh, color: Colors.blue),
                      Icon(Icons.backspace_outlined, color: Colors.blue),
                      Icon(Icons.calculate_outlined, color: Colors.blue),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                // Calculator buttons
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCalcButton('1'),
                      _buildCalcButton('2'),
                      _buildCalcButton('3'),
                      _buildCalcButton('×', isOperator: true),
                      _buildCalcButton('4'),
                      _buildCalcButton('5'),
                      _buildCalcButton('6'),
                      _buildCalcButton('-', isOperator: true),
                      _buildCalcButton('7'),
                      _buildCalcButton('8'),
                      _buildCalcButton('9'),
                      _buildCalcButton('+', isOperator: true),
                      _buildCalcButton('.'),
                      _buildCalcButton('0'),
                      _buildCalcButton('=', isOperator: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcButton(String text, {bool isOperator = false}) {
    return InkWell(
      onTap: () {
        if (text == '=') {
          _handleEquals();
        } else if (isOperator) {
          _handleOperator(text);
        } else if (text == '.') {
          // Handle decimal point
        } else {
          _handleNumberPress(text);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade800, width: 0.5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isOperator ? Colors.blue : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
