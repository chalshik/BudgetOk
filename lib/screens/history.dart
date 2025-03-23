// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> transactionsMap =
        await dbHelper.getTransactionHistory();
    transactions =
        transactionsMap.map((map) => TransactionModel.fromMap(map)).toList();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Transaction History',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : transactions.isEmpty
              ? Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    String transactionType = '';
    Color cardColor = Colors.grey.shade900;
    IconData icon = Icons.swap_horiz;
    String description =
        transaction.description.isEmpty
            ? 'No description'
            : transaction.description;

    // Format date
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    String formattedDate = dateFormat.format(transaction.date);

    // Determine transaction type
    if (transaction.fromSection == 'Accounts' &&
        transaction.toSection == 'Expenses') {
      transactionType = 'Expense';
      cardColor = Colors.red.shade900.withOpacity(0.6);
      icon = Icons.arrow_forward;
    } else if (transaction.fromSection == null &&
        transaction.toSection == 'Accounts') {
      transactionType = 'Income';
      cardColor = Colors.green.shade900.withOpacity(0.6);
      icon = Icons.arrow_downward;
    } else if (transaction.fromSection == 'Income' &&
        transaction.toSection == 'Accounts') {
      transactionType = 'Income';
      cardColor = Colors.green.shade900.withOpacity(0.6);
      icon = Icons.arrow_downward;
    } else if (transaction.fromSection == 'Accounts' &&
        transaction.toSection == 'Accounts') {
      transactionType = 'Transfer';
      cardColor = Colors.blue.shade900.withOpacity(0.6);
      icon = Icons.swap_horiz;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      transactionType,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  'COM ${transaction.amount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (transaction.fromName != null)
                        Text(
                          'From: ${transaction.fromName}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      if (transaction.toName != null)
                        Text(
                          'To: ${transaction.toName}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
