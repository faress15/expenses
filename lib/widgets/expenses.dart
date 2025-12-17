import 'package:flutter/material.dart';
import 'package:untitled1/model/expense.dart';
import 'package:untitled1/new_expense.dart';
import 'package:untitled1/servises/db_helper.dart';
import 'package:untitled1/widgets/chart/chart.dart';
import 'package:untitled1/widgets/expenses_list/expenses_list.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [
    // Expense(
    //   title: 'flutter course',
    //   amount: 20,
    //   date: DateTime.now(),
    //   category: Category.work,
    // ),
    // Expense(
    //   title: 'burger',
    //   amount: 15,
    //   date: DateTime.now(),
    //   category: Category.food,
    // ),
  ];

  void _openAddExpensesPage() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (cntx) => NewExpense(
        addExpense: _addExpense,
      ),
    );
  }

  void _addExpense(Expense newExpense) {
    setState(() {
      _registeredExpenses.add(newExpense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() async {
      _registeredExpenses.remove(expense);
      await DbHelper.deleteExpense(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense deleted'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() async {
              _registeredExpenses.insert(expenseIndex, expense);
              await DbHelper.addExpense(expense);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(onPressed: _openAddExpensesPage, icon: Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: DbHelper.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final expenses = snapshot.data ?? [];

          _registeredExpenses = expenses;

          return Column(
            children: [
              Chart(expenses: _registeredExpenses),
              Expanded(
                child: ExpensesList(
                  expenses: _registeredExpenses,
                  onRemovedExpense: _removeExpense,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
