import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:stuff_app/main.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class LockInTimerScreen extends StatefulWidget {
  const LockInTimerScreen({super.key});

  @override
  State<LockInTimerScreen> createState() => _LockInTimerScreenState();
}

class _LockInTimerScreenState extends State<LockInTimerScreen> with WidgetsBindingObserver {
  late Box<TimerData> _timerBox;
  Timer? _displayTimer;
  int _displaySeconds = 0;
  bool _isRunning = false;
  DateTime? _sessionStartTime;
  DateTime? _pauseTime;
  int _accumulatedSeconds = 0;
  TimerSession? _currentSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timerBox = Hive.box<TimerData>('timerBox');
    _initData();
    _loadActiveSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _displayTimer?.cancel();
    _saveActiveSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveActiveSession();
    }
  }

  void _initData() {
    if (!_timerBox.containsKey('timerData')) {
      _timerBox.put('timerData', TimerData());
    }
  }

  TimerData _getTimerData() => _timerBox.get('timerData')!;

  Future<void> _saveTimerData(TimerData data) async {
    await _timerBox.put('timerData', data);
  }

  void _loadActiveSession() {
    final timerData = _getTimerData();
    if (timerData.activeSession != null) {
      _currentSession = timerData.activeSession!;
      _accumulatedSeconds = timerData.accumulatedSeconds;
      _isRunning = timerData.isRunning;

      if (_isRunning) {
        final elapsed = DateTime.now().difference(_currentSession!.startTime).inSeconds;
        _accumulatedSeconds += elapsed;
        _currentSession!.startTime = DateTime.now();
        _sessionStartTime = DateTime.now();

        _startTimer();
      }

      setState(() {
        _displaySeconds = _calculateElapsedSeconds();
      });
    }
  }

  void _saveActiveSession() async {
    final timerData = _getTimerData();
    if (_currentSession != null) {
      timerData.activeSession = _currentSession;
      timerData.accumulatedSeconds = _accumulatedSeconds;
      timerData.isRunning = _isRunning;
      await _saveTimerData(timerData);
    }
  }

  void _startTimer() {
    if (!_isRunning) {
      final now = DateTime.now();

      if (_currentSession == null) {
        _currentSession =
            TimerSession()
              ..startTime = now
              ..completed = false;
        _accumulatedSeconds = 0;
      } else {
        _currentSession!.startTime = now;
      }

      _sessionStartTime = now;
      _displayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _displaySeconds = _calculateElapsedSeconds();
        });
      });

      setState(() {
        _isRunning = true;
        _pauseTime = null;
      });

      final timerData = _getTimerData();
      timerData.isRunning = true;
      _saveTimerData(timerData);
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _displayTimer?.cancel();
      final now = DateTime.now();
      final elapsed = now.difference(_sessionStartTime!).inSeconds;
      _accumulatedSeconds += elapsed;

      setState(() {
        _isRunning = false;
        _pauseTime = now;
      });

      final timerData = _getTimerData();
      timerData.isRunning = false;
      timerData.accumulatedSeconds = _accumulatedSeconds;
      _saveTimerData(timerData);
    }
  }

  int _calculateElapsedSeconds() {
    if (_currentSession == null) return 0;
    return _accumulatedSeconds +
        (_isRunning ? DateTime.now().difference(_sessionStartTime!).inSeconds : 0);
  }

  void _resetTimer() {
    _displayTimer?.cancel();
    _saveActiveSession();

    setState(() {
      _isRunning = false;
      _displaySeconds = 0;
      _sessionStartTime = null;
      _pauseTime = null;
      _accumulatedSeconds = 0;
      _currentSession = null;
    });

    final timerData = _getTimerData();
    timerData.activeSession = null;
    timerData.accumulatedSeconds = 0;
    timerData.isRunning = false;
    _saveTimerData(timerData);
  }

  Future<void> _saveSession() async {
    if (_currentSession != null) {
      final timerData = _getTimerData();
      final elapsed = _calculateElapsedSeconds();

      _currentSession!
        ..endTime = DateTime.now()
        ..durationInSeconds = elapsed
        ..completed = true;

      timerData.sessions.add(_currentSession!);
      timerData.totalTimeInSeconds += elapsed;
      timerData.activeSession = null;
      timerData.accumulatedSeconds = 0;
      timerData.isRunning = false;

      await _saveTimerData(timerData);

      setState(() {
        _currentSession = null;
        _displaySeconds = 0;
        _sessionStartTime = null;
        _pauseTime = null;
        _accumulatedSeconds = 0;
      });
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lock In Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDuration(_displaySeconds),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_currentSession != null)
              Column(
                children: [
                  Text(
                    'Session started: ${DateFormat('MMM d, y HH:mm').format(_currentSession!.startTime)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_pauseTime != null)
                    Text(
                      'Paused at: ${DateFormat('HH:mm:ss').format(_pauseTime!)}',
                      style: TextStyle(fontSize: 14, color: UIColor().lightCanary),
                    ),
                ],
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_currentSession != null ? 'Resume' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColor().springGreen,
                      foregroundColor: UIColor().darkGray,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColor().lightCanary,
                      foregroundColor: UIColor().darkGray,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor().scarlet,
                    foregroundColor: UIColor().darkGray,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_currentSession != null)
              ElevatedButton.icon(
                onPressed: () async {
                  await _saveSession();
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Session saved successfully!')));
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColor().celeste,
                  foregroundColor: UIColor().darkGray,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            const SizedBox(height: 40),
            ValueListenableBuilder<Box<TimerData>>(
              valueListenable: _timerBox.listenable(),
              builder: (context, box, _) {
                final data = box.get('timerData') ?? TimerData();
                return Column(
                  children: [
                    const Text(
                      'Total Time Logged:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDuration(data.totalTimeInSeconds),
                      style: TextStyle(fontSize: 22, color: UIColor().celeste),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total Sessions: ${data.sessions.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimerHistoryScreen()),
                      ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                    padding: WidgetStatePropertyAll(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimerStatsScreen()),
                      ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                    padding: WidgetStatePropertyAll(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Statistics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimerHistoryScreen extends StatefulWidget {
  const TimerHistoryScreen({super.key});

  @override
  State<TimerHistoryScreen> createState() => _TimerHistoryScreenState();
}

class _TimerHistoryScreenState extends State<TimerHistoryScreen> {
  late Box<TimerData> _timerBox;

  @override
  void initState() {
    super.initState();
    _timerBox = Hive.box<TimerData>('timerBox');
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer History')),
      body: ValueListenableBuilder<Box<TimerData>>(
        valueListenable: _timerBox.listenable(),
        builder: (context, box, _) {
          final timerData = box.get('timerData') ?? TimerData();
          if (timerData.sessions.isEmpty) {
            return const Center(
              child: Text('No sessions recorded yet', style: TextStyle(fontSize: 18)),
            );
          }

          final sessions =
              timerData.sessions.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text('${index + 1}', style: TextStyle(color: UIColor().darkGray)),
                  ),
                  title: Text(
                    'Duration: ${_formatDuration(session.durationInSeconds)}',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  subtitle: Text(
                    'Date: ${DateFormat('MMM d, y').format(session.startTime)}',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
                  ),
                  collapsedIconColor: Theme.of(context).primaryColor,
                  iconColor: Theme.of(context).primaryColor,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Started: ${DateFormat('HH:mm').format(session.startTime)}'),
                          if (session.endTime != null)
                            Text('Ended: ${DateFormat('HH:mm').format(session.endTime!)}'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.delete, color: UIColor().darkGray),
                                label: Text('Delete', style: TextStyle(color: UIColor().darkGray)),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(UIColor().scarlet),
                                ),
                                onPressed: () async {
                                  timerData.totalTimeInSeconds -= session.durationInSeconds;
                                  timerData.sessions.remove(session);
                                  await box.put('timerData', timerData);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Session deleted')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TimerStatsScreen extends StatelessWidget {
  const TimerStatsScreen({super.key});

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Statistics')),
      body: ValueListenableBuilder<Box<TimerData>>(
        valueListenable: Hive.box<TimerData>('timerBox').listenable(),
        builder: (context, box, _) {
          final timerData = box.get('timerData') ?? TimerData();
          if (timerData.sessions.isEmpty) {
            return const Center(
              child: Text('No data available yet', style: TextStyle(fontSize: 18)),
            );
          }

          final totalSessions = timerData.sessions.length;
          final totalSeconds = timerData.totalTimeInSeconds;
          final averageSessionTime = totalSessions > 0 ? totalSeconds ~/ totalSessions : 0;
          final longestSessionSeconds =
              timerData.sessions.isNotEmpty
                  ? timerData.sessions
                      .map((s) => s.durationInSeconds)
                      .reduce((max, duration) => duration > max ? duration : max)
                  : 0;

          final now = DateTime.now();
          final last7Days = List.generate(7, (i) => DateTime(now.year, now.month, now.day - i));
          final dailyTotals = <String, int>{};

          for (final day in last7Days) {
            dailyTotals[DateFormat('MMM d').format(day)] = 0;
          }

          for (final session in timerData.sessions) {
            final sessionDate = DateTime(
              session.startTime.year,
              session.startTime.month,
              session.startTime.day,
            );

            for (final day in last7Days) {
              if (sessionDate.year == day.year &&
                  sessionDate.month == day.month &&
                  sessionDate.day == day.day) {
                final dayString = DateFormat('MMM d').format(day);
                dailyTotals[dayString] = (dailyTotals[dayString] ?? 0) + session.durationInSeconds;
                break;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        _buildStatRow('Total Time', _formatDuration(totalSeconds)),
                        _buildStatRow('Total Sessions', '$totalSessions'),
                        _buildStatRow('Average Session', _formatDuration(averageSessionTime)),
                        _buildStatRow('Longest Session', _formatDuration(longestSessionSeconds)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Last 7 Days',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...dailyTotals.entries.map((entry) {
                  final seconds = entry.value;
                  final hours = seconds / 3600;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: hours > 0 ? (hours / 8).clamp(0.0, 1.0) : 0.0,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(seconds),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${hours.toStringAsFixed(1)} hours',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session Distribution',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildDistributionBar(
                          '< 30 min',
                          timerData.sessions.where((s) => s.durationInSeconds < 1800).length,
                          totalSessions,
                          UIColor().scarlet,
                        ),
                        _buildDistributionBar(
                          '30 min - 1 hr',
                          timerData.sessions
                              .where(
                                (s) => s.durationInSeconds >= 1800 && s.durationInSeconds < 3600,
                              )
                              .length,
                          totalSessions,
                          UIColor().lightCanary,
                        ),
                        _buildDistributionBar(
                          '1 hr - 2 hrs',
                          timerData.sessions
                              .where(
                                (s) => s.durationInSeconds >= 3600 && s.durationInSeconds < 7200,
                              )
                              .length,
                          totalSessions,
                          UIColor().springGreen,
                        ),
                        _buildDistributionBar(
                          '> 2 hrs',
                          timerData.sessions.where((s) => s.durationInSeconds >= 7200).length,
                          totalSessions,
                          UIColor().celeste,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text('$count ${count == 1 ? "session" : "sessions"}')],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 2),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
