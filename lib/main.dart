
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(ShiftCalendarApp());
}

class ShiftCalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Календарь смен',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: ShiftCalendarScreen(),
    );
  }
}

class ShiftCalendarScreen extends StatefulWidget {
  @override
  _ShiftCalendarScreenState createState() => _ShiftCalendarScreenState();
}

enum ShiftType {
  work,
  dayOff,
  donation,
  sideJob,
  sickLeave,
  vacation,
}

class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
  Map<DateTime, ShiftType> _markedDays = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _markedDays[DateTime.utc(2025, 8, 12)] = ShiftType.donation;
    _markedDays[DateTime.utc(2025, 8, 13)] = ShiftType.donation;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    _showShiftTypeDialog(selectedDay);
  }

  void _showShiftTypeDialog(DateTime day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выбери тип дня'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ShiftType.values.map((type) {
            return ListTile(
              title: Text(_shiftTypeToText(type)),
              onTap: () {
                setState(() {
                  _markedDays[day] = type;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _shiftTypeToText(ShiftType type) {
    switch (type) {
      case ShiftType.work:
        return 'Рабочий';
      case ShiftType.dayOff:
        return 'Выходной';
      case ShiftType.donation:
        return 'Донация';
      case ShiftType.sideJob:
        return 'Подработка';
      case ShiftType.sickLeave:
        return 'Больничный';
      case ShiftType.vacation:
        return 'Отпуск';
      default:
        return '';
    }
  }

  Color _getShiftColor(ShiftType type) {
    switch (type) {
      case ShiftType.work:
        return Colors.deepOrange;
      case ShiftType.dayOff:
        return Colors.amber.shade200;
      case ShiftType.donation:
        return Colors.orangeAccent;
      case ShiftType.sideJob:
        return Colors.teal;
      case ShiftType.sickLeave:
        return Colors.pinkAccent;
      case ShiftType.vacation:
        return Colors.lightBlueAccent;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB347),
            Color(0xFFFFCC33),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Календарь смен'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final type = _markedDays[day];
                if (type != null) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _getShiftColor(type),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}
