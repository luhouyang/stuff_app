import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stuff_app/main.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late Box<CounterData> _counterBox;

  @override
  void initState() {
    super.initState();
    _counterBox = Hive.box<CounterData>('counterBox');
  }

  // Helper function to get the current counter data
  CounterData _getCounterData() {
    return _counterBox.get('myCounter') ?? CounterData();
  }

  // Helper function to save the counter data
  Future<void> _saveCounterData(CounterData data) async {
    await _counterBox.put('myCounter', data);
  }

  void _incrementCounter() async {
    final currentData = _getCounterData();
    final now = DateTime.now();

    // Add the current value and timestamp to history
    currentData.history.add(currentData.count);
    currentData.historyTimestamps.add(now);

    // Update the counter value and last increment time
    currentData.count++;
    currentData.lastIncrementTime = now;

    await _saveCounterData(currentData);
    setState(() {}); // Trigger a rebuild to update the UI
  }

  void _decrementCounter() async {
    final currentData = _getCounterData();
    if (currentData.count > 0) {
      final now = DateTime.now();

      // Add the current value and timestamp to history
      currentData.history.add(currentData.count);
      currentData.historyTimestamps.add(now);

      // Update the counter value
      currentData.count--;
      currentData.lastIncrementTime = now;

      await _saveCounterData(currentData);
      setState(() {});
    }
  }

  void _resetCounter() async {
    final currentData = CounterData(); // Create a new default CounterData
    await _saveCounterData(currentData);
    setState(() {});
  }

  void _undoLastIncrement() async {
    final currentData = _getCounterData();
    if (currentData.history.isNotEmpty && currentData.historyTimestamps.isNotEmpty) {
      currentData.count = currentData.history.last;
      currentData.history.removeLast();
      currentData.historyTimestamps.removeLast();
      await _saveCounterData(currentData);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter v2.0')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Counter Value:', style: TextStyle(fontSize: 20)),
            ValueListenableBuilder<Box<CounterData>>(
              valueListenable: _counterBox.listenable(keys: ['myCounter']),
              builder: (context, box, _) {
                final data = box.get('myCounter') ?? CounterData();
                return Text(
                  '${data.count}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _decrementCounter,
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(UIColor().scarlet)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: const Icon(Icons.remove),
                  ),
                ),
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _resetCounter,
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(UIColor().scarlet)),
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _undoLastIncrement,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(UIColor().lightCanary),
                  ),
                  child: const Text('Undo'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _getCounterData().lastIncrementTime != null
                  ? 'Last increment: ${DateFormat('MMM d, y HH:mm:ss').format(_getCounterData().lastIncrementTime!)}'
                  : 'No increments yet',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
              ),
              child: const Text('View History'),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<CounterData> _counterBox;

  @override
  void initState() {
    super.initState();
    _counterBox = Hive.box<CounterData>('counterBox');
  }

  @override
  Widget build(BuildContext context) {
    final counterData = _counterBox.get('myCounter') ?? CounterData();

    // Create a list of combined history entries with timestamps and values
    final List<MapEntry<int, DateTime>> historyWithDates = [];
    for (int i = 0; i < counterData.history.length; i++) {
      if (i < counterData.historyTimestamps.length) {
        historyWithDates.add(MapEntry(counterData.history[i], counterData.historyTimestamps[i]));
      }
    }

    // Sort in reverse chronological order
    historyWithDates.sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Counter History')),
      body:
          historyWithDates.isEmpty
              ? const Center(child: Text('No history yet.'))
              : ListView.builder(
                itemCount: historyWithDates.length,
                itemBuilder: (context, index) {
                  final entry = historyWithDates[index];
                  // Format the date for display
                  final formattedDate = DateFormat('MMM d, y HH:mm:ss').format(entry.value);

                  return ListTile(
                    title: Text(
                      'Value: ${entry.key}',
                      style: TextStyle(color: UIColor().mediumGray),
                    ),
                    subtitle: Text(
                      'Date: $formattedDate',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text('${entry.key}', style: TextStyle(color: UIColor().darkGray)),
                    ),
                  );
                },
              ),
    );
  }
}
