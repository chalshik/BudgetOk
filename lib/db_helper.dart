import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        section TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');

    // Create history table
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_category_id INTEGER,
        to_category_id INTEGER,
        amount INTEGER NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY(from_category_id) REFERENCES categories(id),
        FOREIGN KEY(to_category_id) REFERENCES categories(id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Insert default Income categories
    await db.insert('categories', {
      'name': 'Salary',
      'section': 'Income',
      'icon': 0xe8dd, // Icons.monetization_on
      'color': 0xFF4CAF50, // Colors.green
    });
    await db.insert('categories', {
      'name': 'Freelance',
      'section': 'Income',
      'icon': 0xe9e8, // Icons.work
      'color': 0xFF2196F3, // Colors.blue
    });

    // Insert default Accounts categories
    await db.insert('categories', {
      'name': 'MBANK',
      'section': 'Accounts',
      'icon': 0xe870, // Icons.credit_card
      'color': 0xFFF44336, // Colors.red
    });
    await db.insert('categories', {
      'name': 'Cash',
      'section': 'Accounts',
      'icon': 0xe8b0, // Icons.money
      'color': 0xFF4CAF50, // Colors.green
    });

    // Insert default Expenses categories
    await db.insert('categories', {
      'name': 'Transport',
      'section': 'Expenses',
      'icon': 0xe98e, // Icons.local_taxi
      'color': 0xFFFFC107, // Colors.amber
    });
    await db.insert('categories', {
      'name': 'Food',
      'section': 'Expenses',
      'icon': 0xe23f, // Icons.fastfood
      'color': 0xFFFF9800, // Colors.orange
    });

    // Set initial values for accounts
    await db.insert('accounts', {
      'category_id': 3, // MBANK
      'amount': 286,
    });
    await db.insert('accounts', {
      'category_id': 4, // Cash
      'amount': 10,
    });
  }

  // CRUD operations for categories
  Future<int> insertCategory(Map<String, dynamic> category) async {
    Database db = await instance.database;
    int id = await db.insert('categories', category);

    // If it's an account, initialize with 0 balance
    if (category['section'] == 'Accounts') {
      await db.insert('accounts', {'category_id': id, 'amount': 0});
    }

    return id;
  }

  Future<List<Map<String, dynamic>>> getCategories(String section) async {
    Database db = await instance.database;
    return await db.query(
      'categories',
      where: 'section = ?',
      whereArgs: [section],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    Database db = await instance.database;
    return await db.query('categories');
  }

  Future<Map<String, dynamic>?> getCategory(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    Database db = await instance.database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await instance.database;

    // Check if this is the last account
    if (await _isCategoryAccount(id)) {
      int accountCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM categories WHERE section = ?',
              ['Accounts'],
            ),
          ) ??
          0;

      if (accountCount <= 1) {
        throw Exception('Cannot delete the last account');
      }

      await db.delete('accounts', where: 'category_id = ?', whereArgs: [id]);
    }

    // Check for dependencies in transactions
    int transactionCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE from_category_id = ? OR to_category_id = ?',
            [id, id],
          ),
        ) ??
        0;

    if (transactionCount > 0) {
      // Option 1: Throw an exception
      // throw Exception('Category has transactions and cannot be deleted');

      // Option 2: Delete related transactions
      await db.delete(
        'transactions',
        where: 'from_category_id = ? OR to_category_id = ?',
        whereArgs: [id, id],
      );
    }

    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> _isCategoryAccount(int categoryId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'categories',
      where: 'id = ? AND section = ?',
      whereArgs: [categoryId, 'Accounts'],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Account operations
  Future<int> getAccountBalance(int categoryId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'accounts',
      columns: ['amount'],
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['amount'] : 0;
  }

  Future<void> updateAccountBalance(int categoryId, int amount) async {
    Database db = await instance.database;

    // Fetch the current balance
    int currentBalance = await getAccountBalance(categoryId);

    // Calculate the new balance
    int newBalance = currentBalance + amount;

    // Ensure the balance does not go negative (for accounts)
    if (newBalance < 0) {
      throw Exception('Insufficient funds in account');
    }

    // Update the balance
    await db.update(
      'accounts',
      {'amount': newBalance},
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  // Transaction operations
  Future<int> recordTransaction({
    int? fromCategoryId,
    int? toCategoryId,
    required int amount,
    String? description,
    DateTime? date,
  }) async {
    if (amount <= 0) {
      throw Exception('Transaction amount must be positive');
    }

    if (fromCategoryId == null && toCategoryId == null) {
      throw Exception('At least one category must be specified');
    }

    Database db = await instance.database;
    String now = (date ?? DateTime.now()).toIso8601String();

    return await db.insert('history', {
      'from_category_id': fromCategoryId,
      'to_category_id': toCategoryId,
      'amount': amount,
      'description': description ?? '',
      'date': now,
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    String? categorySection,
    int? categoryId,
  }) async {
    Database db = await instance.database;
    String query = '''
      SELECT 
        h.id, 
        h.amount, 
        h.date, 
        h.description,
        h.from_category_id,
        h.to_category_id,
        fc.name as from_name,
        fc.section as from_section,
        fc.icon as from_icon,
        fc.color as from_color,
        tc.name as to_name,
        tc.section as to_section,
        tc.icon as to_icon,
        tc.color as to_color
      FROM history h
      LEFT JOIN categories fc ON h.from_category_id = fc.id
      LEFT JOIN categories tc ON h.to_category_id = tc.id
    ''';

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereConditions.add('h.date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('h.date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (categorySection != null) {
      whereConditions.add('(fc.section = ? OR tc.section = ?)');
      whereArgs.add(categorySection);
      whereArgs.add(categorySection);
    }

    if (categoryId != null) {
      whereConditions.add('(h.from_category_id = ? OR h.to_category_id = ?)');
      whereArgs.add(categoryId);
      whereArgs.add(categoryId);
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ' + whereConditions.join(' AND ');
    }

    query += ' ORDER BY h.date DESC';

    if (limit != null) {
      query += ' LIMIT ?';
      whereArgs.add(limit);

      if (offset != null) {
        query += ' OFFSET ?';
        whereArgs.add(offset);
      }
    }

    return await db.rawQuery(query, whereArgs);
  }

  Future<int> transfer({
    int? fromCategoryId,
    int? toCategoryId,
    required int amount,
    String? description,
  }) async {
    if (amount <= 0) {
      throw Exception('Transaction amount must be positive');
    }

    if (fromCategoryId == null && toCategoryId == null) {
      throw Exception('At least one category must be specified');
    }

    Database db = await instance.database;

    // Fetch category details
    Map<String, dynamic>? fromCategory = await getCategory(fromCategoryId!);
    Map<String, dynamic>? toCategory = await getCategory(toCategoryId!);

    if (fromCategory == null || toCategory == null) {
      throw Exception('Invalid category IDs');
    }

    String fromSection = fromCategory['section'];
    String toSection = toCategory['section'];

    // Validate transfer rules
    bool isValid = false;

    // Account -> Account: Valid (e.g., Cash → Bank)
    if (fromSection == 'Accounts' && toSection == 'Accounts') {
      isValid = true;
    }
    // Account -> Expense: Valid (e.g., Bank → Food)
    else if (fromSection == 'Accounts' && toSection == 'Expenses') {
      isValid = true;
    }
    // Income -> Account: Valid (e.g., Salary → Bank)
    else if (fromSection == 'Income' && toSection == 'Accounts') {
      isValid = true;
    }

    if (!isValid) {
      throw Exception(
        'Invalid transfer between ${fromSection} and ${toSection}',
      );
    }

    // Check if account has sufficient balance
    if (fromSection == 'Accounts') {
      int balance = await getAccountBalance(fromCategoryId);
      if (balance < amount) {
        throw Exception('Insufficient funds in account');
      }
    }

    // Record the transaction
    int transactionId = await recordTransaction(
      fromCategoryId: fromCategoryId,
      toCategoryId: toCategoryId,
      amount: amount,
      description: description,
    );

    // Update account balances
    if (fromSection == 'Accounts') {
      await updateAccountBalance(fromCategoryId, -amount);
    }
    if (toSection == 'Accounts') {
      await updateAccountBalance(toCategoryId, amount);
    }

    return transactionId;
  }

  // Get total amount for a section
  Future<int> getSectionTotal(String section) async {
    Database db = await instance.database;

    if (section == 'Accounts') {
      // Calculate the total balance for all accounts
      var result = await db.rawQuery(
        '''
      SELECT SUM(a.amount) as total
      FROM accounts a
      JOIN categories c ON a.category_id = c.id
      WHERE c.section = ?
      ''',
        [section],
      );
      return result.first['total'] as int? ?? 0;
    } else if (section == 'Income') {
      // Calculate the total income from transactions
      var result = await db.rawQuery('''
      SELECT SUM(t.amount) as total
      FROM history t
      JOIN categories c ON t.from_category_id = c.id
      WHERE c.section = 'Income'
      ''');
      return result.first['total'] as int? ?? 0;
    } else if (section == 'Expenses') {
      // Calculate the total expenses from transactions
      var result = await db.rawQuery('''
      SELECT SUM(t.amount) as total
      FROM history t
      JOIN categories c ON t.to_category_id = c.id
      WHERE c.section = 'Expenses'
      ''');
      return result.first['total'] as int? ?? 0;
    }

    return 0; // Default return value if the section is not recognized
  }
}
