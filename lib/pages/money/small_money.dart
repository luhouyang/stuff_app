import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:stuff_app/entities/finance/balance_entity.dart';
import 'package:stuff_app/entities/finance/transaction_entity.dart';
import 'package:stuff_app/pages/money/add_transaction.dart';
import 'package:stuff_app/pages/money/balance_line_chart.dart';
import 'package:stuff_app/pages/money/expandable_transaction.dart';
import 'package:stuff_app/pages/money/expense_pie_chart.dart';
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/widgets/loading/loading_widget_large.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class SmallMoneyPage extends StatefulWidget {
  const SmallMoneyPage({super.key});

  @override
  State<SmallMoneyPage> createState() => _SmallMoneyPageState();
}

class _SmallMoneyPageState extends State<SmallMoneyPage> {
  String _filterType = 'Day';
  DateTime _selectedDate = DateTime.now();
  final List<TransactionEntity> _fetchedTransactions = [];

  final List<String> _filterOptions = ['Day', 'Month', 'Year'];

  Query<Map<String, dynamic>> _buildQuery() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions'); // Changed collection name

    if (_filterType == 'Day') {
      query = query
          .where('year', isEqualTo: _selectedDate.year)
          .where('month', isEqualTo: _selectedDate.month)
          .where('day', isEqualTo: _selectedDate.day);
    } else if (_filterType == 'Month') {
      query = query
          .where('year', isEqualTo: _selectedDate.year)
          .where('month', isEqualTo: _selectedDate.month);
    } else if (_filterType == 'Year') {
      query = query.where('year', isEqualTo: _selectedDate.year);
    }
    return query;
  }

  Future<void> _selectDate(BuildContext context) async {
    ThemeData theme = Theme.of(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardTheme.color,
              headerForegroundColor: theme.primaryColor,
              dayForegroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.cardTheme.color,
                ~WidgetState.disabled: theme.primaryColor,
              }),
              dayBackgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.primaryColor,
              }),
              dayOverlayColor: WidgetStatePropertyAll(theme.primaryColor),
              todayBackgroundColor: WidgetStatePropertyAll(theme.cardTheme.color),
              todayForegroundColor: WidgetStatePropertyAll(theme.primaryColor),
              surfaceTintColor: theme.primaryColor,
              yearForegroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.cardTheme.color,
                ~WidgetState.disabled: theme.primaryColor,
              }),
              yearBackgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.primaryColor,
              }),
              yearOverlayColor: WidgetStatePropertyAll(theme.primaryColor),
              yearStyle: TextStyle(color: theme.primaryColor),
              weekdayStyle: TextStyle(color: theme.primaryColor),
              dayStyle: TextStyle(color: theme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              cancelButtonStyle: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(UIColor().scarlet),
              ),
              inputDecorationTheme: theme.inputDecorationTheme,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildDatePickerButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: ElevatedButton(
          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(12))),
          onPressed: () => _selectDate(context),
          child: Text(
            DateFormat(
              _filterType == 'Day'
                  ? 'yyyy-MM-dd'
                  : _filterType == 'Month'
                  ? 'yyyy-MM'
                  : 'yyyy',
            ).format(_selectedDate),
            style: TextStyle(color: UIColor().darkGray, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  BalanceEntity balanceEntity = BalanceEntity(id: "noid", amount: 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField2<String>(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      hint: const Text('Filter by'),
                      value: _filterType,
                      items:
                          _filterOptions
                              .map(
                                (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _filterType = value ?? 'Day';
                          _selectedDate = DateTime.now();
                        });
                      },
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  _buildDatePickerButton(),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('StreamBuilder Error: ${snapshot.error}');
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidgetLarge();
                }

                _fetchedTransactions.clear();
                double totalIncome = 0;
                double totalExpenses = 0;
                Map<String, double> expenseCategories = {}; // For pie chart
                Set<String> uniqueDays = {}; // For averaging balance over period

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (final doc in snapshot.data!.docs) {
                    final transactionData = doc.data();
                    final transactionEntity = TransactionEntity.fromMap(transactionData);
                    _fetchedTransactions.add(transactionEntity);

                    if (transactionEntity.type == 'income') {
                      totalIncome += transactionEntity.amount;
                    } else {
                      totalExpenses += transactionEntity.amount;
                      expenseCategories.update(
                        transactionEntity.category,
                        (value) => value + transactionEntity.amount,
                        ifAbsent: () => transactionEntity.amount,
                      );
                    }

                    if (_filterType == 'Month' || _filterType == 'Year') {
                      final dayString =
                          '${transactionEntity.year}-${transactionEntity.month}-${transactionEntity.day}';
                      uniqueDays.add(dayString);
                    }
                  }
                  // No specific client-side sorting needed beyond Firestore orderBy('createdAt')
                }

                final double netBalance = totalIncome - totalExpenses;

                // Prepare data for the line chart (Balance Trend)
                List<FlSpot> dailyBalanceData = [];
                DateTime chartStartDate = _selectedDate;
                DateTime chartEndDate = _selectedDate;

                if (_filterType == 'Day') {
                  // Add the starting point at 00:00 with 0 balance
                  dailyBalanceData.add(const FlSpot(0, 0));

                  // For a single day, plot individual transaction balances relative to start of day
                  double currentBalance = 0;
                  _fetchedTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  for (var transaction in _fetchedTransactions) {
                    currentBalance +=
                        (transaction.type == 'income' ? transaction.amount : -transaction.amount);
                    dailyBalanceData.add(
                      FlSpot(
                        transaction.createdAt
                            .toDate()
                            .difference(
                              DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
                            )
                            .inMinutes
                            .toDouble(), // Use minutes for intra-day
                        currentBalance,
                      ),
                    );
                  }
                  if (_fetchedTransactions.isNotEmpty) {
                    chartStartDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                    );
                    chartEndDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      23,
                      59,
                      59,
                    );
                    dailyBalanceData.add(FlSpot(1440.0, currentBalance));
                  }
                } else {
                  // Group by day and calculate daily net balance for Month/Year views
                  Map<String, double> dailyNetBalances = {};
                  if (_fetchedTransactions.isNotEmpty) {
                    _fetchedTransactions.sort(
                      (a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()),
                    );

                    // Determine the actual start and end dates of the period for the chart
                    if (_filterType == 'Month') {
                      chartStartDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
                      chartEndDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
                    } else if (_filterType == 'Year') {
                      chartStartDate = DateTime(_selectedDate.year, 1, 1);
                      chartEndDate = DateTime(_selectedDate.year, 12, 31);
                    }

                    // Initialize daily balances with 0 for all days in the range
                    for (int i = 0; i <= chartEndDate.difference(chartStartDate).inDays; i++) {
                      final date = chartStartDate.add(Duration(days: i));
                      dailyNetBalances[DateFormat('yyyy-MM-dd').format(date)] = 0.0;
                    }

                    // Accumulate balances day by day
                    double runningBalance = 0;
                    for (int i = 0; i <= chartEndDate.difference(chartStartDate).inDays; i++) {
                      final currentDate = chartStartDate.add(Duration(days: i));
                      double dayNet = 0;
                      for (var transaction in _fetchedTransactions) {
                        if (transaction.year == currentDate.year &&
                            transaction.month == currentDate.month &&
                            transaction.day == currentDate.day) {
                          dayNet +=
                              (transaction.type == 'income'
                                  ? transaction.amount
                                  : -transaction.amount);
                        }
                      }
                      runningBalance += dayNet;
                      dailyNetBalances[DateFormat('yyyy-MM-dd').format(currentDate)] =
                          runningBalance;
                    }

                    // Create FlSpots for all days with data
                    dailyBalanceData =
                        dailyNetBalances.entries.map((e) {
                          final date = DateTime.parse(e.key);
                          return FlSpot(date.difference(chartStartDate).inDays.toDouble(), e.value);
                        }).toList();
                    dailyBalanceData.sort((a, b) => a.x.compareTo(b.x)); // Ensure sorted by date
                  }
                }

                return FutureBuilder(
                  future: FBStore().getBalance(context, FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LoadingWidgetLarge();
                    }

                    balanceEntity = snapshot.data!;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Table(
                            columnWidths: const <int, TableColumnWidth>{
                              1: IntrinsicColumnWidth(), // Width based on Label content
                              2: FlexColumnWidth(), // Value takes remaining space
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: <TableRow>[
                              // --- Balance ---
                              TableRow(
                                children: <Widget>[
                                  // Label Cell
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ), // Space between label and value
                                    child: Text(
                                      'Balance:',
                                      style:
                                          Theme.of(context)
                                              .textTheme
                                              .displayMedium, // Use a slightly smaller style for table rows if needed
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  // Value Cell
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '\$${balanceEntity.amount.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium // Match label style or keep displayMedium if preferred
                                          ?.copyWith(color: UIColor().springGreen), // Apply color
                                      textAlign: TextAlign.right, // Right-align currency values
                                    ),
                                  ),
                                ],
                              ),
                              // --- Income Row ---
                              TableRow(
                                children: <Widget>[
                                  // Label Cell
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ), // Space between label and value
                                    child: Text(
                                      '$_filterType Income:',
                                      style:
                                          Theme.of(context)
                                              .textTheme
                                              .displayMedium, // Use a slightly smaller style for table rows if needed
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  // Value Cell
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '\$${totalIncome.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium // Match label style or keep displayMedium if preferred
                                          ?.copyWith(color: UIColor().springGreen), // Apply color
                                      textAlign: TextAlign.right, // Right-align currency values
                                    ),
                                  ),
                                ],
                              ),
                              // --- Expenses Row ---
                              TableRow(
                                children: <Widget>[
                                  // Label Cell
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      '$_filterType Expenses:',
                                      style: Theme.of(context).textTheme.displayMedium,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  // Value Cell
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '\$${totalExpenses.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        color: UIColor().scarlet,
                                      ), // Apply color
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              // --- Spacer Row (Optional) ---
                              const TableRow(
                                children: <Widget>[
                                  SizedBox(height: 8.0), // Add vertical space before Net Balance
                                  SizedBox(height: 8.0),
                                ],
                              ),
                              // --- Net Balance Row ---
                              TableRow(
                                children: <Widget>[
                                  // Label Cell
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      // Construct the dynamic label text
                                      'Net Balance (${_filterType == 'Day'
                                          ? DateFormat('yyyy-MM-dd').format(_selectedDate)
                                          : _filterType == 'Month'
                                          ? DateFormat('yyyy-MM').format(_selectedDate)
                                          : DateFormat('yyyy').format(_selectedDate)}):',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ), // Make Net Balance bold
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  // Value Cell
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '\$${netBalance.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ), // Make Net Balance bold
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ExpensePieChart(categoryAmounts: expenseCategories),
                        if (dailyBalanceData.isNotEmpty && _filterType != "Day")
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                            child: BalanceLineChart(
                              dailyBalance: dailyBalanceData,
                              startDate: chartStartDate,
                              endDate: chartEndDate,
                              mode: _filterType,
                            ),
                          ),
                        if (_fetchedTransactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No transactions added for this period.'),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _fetchedTransactions.length,
                              itemBuilder: (context, index) {
                                final transactionEntity = _fetchedTransactions[index];
                                return ExpandableTransactionCard(
                                  transaction: transactionEntity,
                                  balanceEntity: balanceEntity,
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  AddTransactionPage(balanceEntity: balanceEntity),
                                        ),
                                      ),
                                  child: Text(
                                    'Add Transaction',
                                    style: TextStyle(
                                      color: UIColor().darkGray,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
