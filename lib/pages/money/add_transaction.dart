import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/entities/finance/transaction_entity.dart'; // NEW IMPORT
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/widgets/fields/text_input.dart';
import 'package:stuff_app/widgets/loading/loading_widget.dart';
import 'package:stuff_app/widgets/texts/h1_text.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TextInputs textInputs = TextInputs();
  SnackBarText snackBarText = SnackBarText();

  final _transactionForm = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Transaction-specific variables
  List<String> transactionTypes = ['Income', 'Expense'];
  String _selectedType = 'Expense'; // Default to Expense

  List<String> incomeCategories = ['Salary', 'Freelance', 'Gift', 'Investment', 'Other Income'];
  List<String> expenseCategories = [
    'Food',
    'Transport',
    'Rent',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Healthcare',
    'Education',
    'Travel',
    'Other Expenses',
  ];
  String _selectedCategory = 'Food'; // Default expense category

  DateTime _selectedDate = DateTime.now();
  final String _filterType = 'Day'; // Used for date formatting consistency

  @override
  void initState() {
    super.initState();
    // Set initial category based on default type
    _selectedCategory = expenseCategories.first;
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
    return ElevatedButton(
      style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(12))),
      onPressed: () => _selectDate(context),
      child: Row(
        children: [
          Text(
            DateFormat(
              _filterType == 'Day'
                  ? 'yyyy-MM-dd'
                  : _filterType == 'Month'
                  ? 'yyyy-MM'
                  : 'yyyy',
            ).format(_selectedDate),
            style: TextStyle(color: UIColor().darkGray, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.calendar_month_outlined),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _transactionForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H1Text(text: "New Transaction"),
                const SizedBox(height: 16),
                textInputs.inputTextWidget(
                  hint: 'Amount (e.g., 50.00)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  controller: amountController,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField2<String>(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  hint: const Text('Select Type'),
                  value: _selectedType,
                  items:
                      transactionTypes
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? 'Expense';
                      // Reset category when type changes
                      _selectedCategory =
                          _selectedType == 'Income'
                              ? incomeCategories.first
                              : expenseCategories.first;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a type';
                    }
                    return null;
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
                const SizedBox(height: 16),
                DropdownButtonFormField2<String>(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  hint: const Text('Select Category'),
                  value: _selectedCategory,
                  items:
                      (_selectedType == 'Income' ? incomeCategories : expenseCategories)
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'Uncategorized';
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
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
                const SizedBox(height: 16),
                textInputs.inputTextWidget(
                  hint: 'Description (optional)',
                  validator: textInputs.textVerify,
                  controller: descriptionController,
                ),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: _buildDatePickerButton()),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_transactionForm.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return LoadingWidget().circularLoadingWidget(context);
                          },
                        );

                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        final double amount = double.parse(amountController.text);
                        final String type = _selectedType.toLowerCase();
                        final String category = _selectedCategory;
                        final String description = descriptionController.text;

                        final newTransaction = TransactionEntity(
                          id: '', // Firestore will generate this
                          userId: userId,
                          amount: amount,
                          type: type,
                          category: category,
                          description: description,
                          createdAt: Timestamp.fromDate(_selectedDate),
                          year: _selectedDate.year,
                          month: _selectedDate.month,
                          day: _selectedDate.day,
                        );

                        await FBStore().addTransaction(context, newTransaction, userId);

                        if (context.mounted) {
                          Navigator.of(context).pop(); // Dismiss loading dialog
                          snackBarText.showBanner(msg: "Transaction added", context: context);
                          Navigator.of(context).pop(); // Go back to previous page
                        }
                      }
                    },
                    child: Text(
                      "ADD TRANSACTION",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(color: UIColor().darkGray),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
