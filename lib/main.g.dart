// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeminiAPIKeyAdapter extends TypeAdapter<GeminiAPIKey> {
  @override
  final int typeId = 1;

  @override
  GeminiAPIKey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeminiAPIKey(
      apiKey: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GeminiAPIKey obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.apiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeminiAPIKeyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CounterDataAdapter extends TypeAdapter<CounterData> {
  @override
  final int typeId = 2;

  @override
  CounterData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CounterData()
      ..count = fields[0] as int
      ..lastIncrementTime = fields[1] as DateTime?
      ..history = (fields[2] as List).cast<int>()
      ..historyTimestamps = (fields[3] as List).cast<DateTime>();
  }

  @override
  void write(BinaryWriter writer, CounterData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.count)
      ..writeByte(1)
      ..write(obj.lastIncrementTime)
      ..writeByte(2)
      ..write(obj.history)
      ..writeByte(3)
      ..write(obj.historyTimestamps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimerSessionAdapter extends TypeAdapter<TimerSession> {
  @override
  final int typeId = 3;

  @override
  TimerSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerSession()
      ..startTime = fields[0] as DateTime
      ..endTime = fields[1] as DateTime?
      ..durationInSeconds = fields[2] as int
      ..notes = fields[3] as String?
      ..completed = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, TimerSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.durationInSeconds)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimerDataAdapter extends TypeAdapter<TimerData> {
  @override
  final int typeId = 4;

  @override
  TimerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerData()
      ..sessions = (fields[0] as List).cast<TimerSession>()
      ..totalTimeInSeconds = fields[1] as int
      ..activeSession = fields[2] as TimerSession?
      ..accumulatedSeconds = fields[3] as int
      ..isRunning = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, TimerData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sessions)
      ..writeByte(1)
      ..write(obj.totalTimeInSeconds)
      ..writeByte(2)
      ..write(obj.activeSession)
      ..writeByte(3)
      ..write(obj.accumulatedSeconds)
      ..writeByte(4)
      ..write(obj.isRunning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
