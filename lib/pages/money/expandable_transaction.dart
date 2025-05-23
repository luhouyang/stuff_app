import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/entities/finance/balance_entity.dart';
import 'package:stuff_app/entities/finance/transaction_entity.dart'; // NEW IMPORT
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class ExpandableTransactionCard extends StatefulWidget {
  final TransactionEntity transaction;
  final BalanceEntity balanceEntity;

  const ExpandableTransactionCard({
    super.key,
    required this.transaction,
    required this.balanceEntity,
  });

  @override
  State<ExpandableTransactionCard> createState() => _ExpandableTransactionCardState();
}

class _ExpandableTransactionCardState extends State<ExpandableTransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final transactionId = transaction.id;
    final date = transaction.createdAt;
    final type = transaction.type;
    final category = transaction.category;
    final amount = transaction.amount;
    final description = transaction.description;

    // Determine color based on transaction type
    final Color amountColor = type == 'income' ? UIColor().springGreen : UIColor().scarlet;
    final IconData typeIcon = type == 'income' ? Icons.arrow_circle_up : Icons.arrow_circle_down;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(typeIcon, color: amountColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${type.toUpperCase()} - $category',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            Text(
                              DateFormat('MM-dd HH:mm').format(date.toDate()),
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${type == 'income' ? '+' : '-'} \$${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: amountColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: UIColor().scarlet,
                        onPressed: () async {
                          final bool confirmDelete =
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: UIColor().whiteSmoke,
                                    title: Text(
                                      'Confirm Deletion',
                                      style: TextStyle(color: UIColor().darkGray),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this transaction? This action cannot be undone.',
                                      style: TextStyle(color: UIColor().darkGray),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: UIColor().scarlet,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (confirmDelete) {
                            final userId = FirebaseAuth.instance.currentUser?.uid;
                            if (userId != null && context.mounted) {
                              await FBStore().deleteTransaction(
                                context,
                                userId,
                                transactionId,
                                widget.balanceEntity,
                              );
                            } else {
                              debugPrint('User not logged in, cannot delete transaction.');
                              if (context.mounted) {
                                SnackBarText().showBanner(
                                  msg: 'You must be logged in to delete transactions.',
                                  context: context,
                                );
                              }
                            }
                          }
                        },
                      ),
                      Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    ],
                  ),
                  if (_isExpanded && description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(description, style: const TextStyle(fontSize: 14.0)),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded && description.isEmpty) const SizedBox(height: 8.0),
      ],
    );
  }
}
