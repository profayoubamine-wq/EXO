// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 4;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      id: fields[0] as String,
      levelId: fields[1] as String,
      subjectId: fields[2] as String,
      teacherId: fields[3] as String,
      roomId: fields[4] as String,
      day: fields[5] as int,
      startHour: fields[6] as int,
      startMinute: fields[7] as int,
      durationMinutes: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.levelId)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.teacherId)
      ..writeByte(4)
      ..write(obj.roomId)
      ..writeByte(5)
      ..write(obj.day)
      ..writeByte(6)
      ..write(obj.startHour)
      ..writeByte(7)
      ..write(obj.startMinute)
      ..writeByte(8)
      ..write(obj.durationMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
