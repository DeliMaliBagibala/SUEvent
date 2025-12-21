import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/event_model.dart';
import 'providers/event_provider.dart';
import 'theme_constants.dart';
import 'day_events_screen.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const CalendarScreen({super.key, required this.onBackTap});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.backgroundHeader,
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left,
                    size: AppDimens.iconLarge, color: AppColors.textBlack),
                onPressed: widget.onBackTap,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    size: AppDimens.iconLarge, color: AppColors.textBlack),
                onPressed: _previousMonth,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "${_getMonthName(_currentDate.month)} ${_currentDate.year}",
                    style: AppTextStyles.headerLarge.copyWith(fontSize: 28),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    size: AppDimens.iconLarge, color: AppColors.textBlack),
                onPressed: _nextMonth,
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.textWhite,
            child: CalendarGrid(currentDate: _currentDate),
          ),
        ),
      ],
    );
  }
}

class CalendarGrid extends StatelessWidget {
  final DateTime currentDate;

  CalendarGrid({super.key, required this.currentDate});

  final List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  List<int> _generateDays(DateTime date) {
    final year = date.year;
    final month = date.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    int blankDays = firstDayOfMonth.weekday % 7;

    final days = <int>[];
    for (int i = 0; i < blankDays; i++) {
      days.add(-1);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    while (days.length % 7 != 0) {
      days.add(-1);
    }

    return days;
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  Map<int, int> _getEventsForMonth(List<Event> events, DateTime date) {
    final Map<int, int> eventsPerDay = {};
    final month = date.month;
    final year = date.year;

    for (final event in events) {
      try {
        final parts = event.date.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final eventMonth = int.parse(parts[1]);
          final eventYear = int.parse(parts[2]);

          if (eventYear == year && eventMonth == month) {
            eventsPerDay.update(day, (value) => value + 1, ifAbsent: () => 1);
          }
        }
      } catch (e) {
        print("Error parsing date for event ${event.id}: ${event.date}");
      }
    }
    return eventsPerDay;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _generateDays(currentDate);
    final eventProvider = Provider.of<EventProvider>(context);
    final eventsPerDay = _getEventsForMonth(eventProvider.events, currentDate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) => Expanded(child: Center(
              child: Text(
                day,
                style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: AppColors.textBlack),
              ),
            ))).toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 1.0,
              childAspectRatio: 0.8,
            ),
            itemCount: daysInMonth.length,
            itemBuilder: (context, index) {
              final day = daysInMonth[index];
              return _buildDayCell(context, day, eventsPerDay);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, int day, Map<int, int> eventsPerDay) {
    final isCurrentMonth = day > 0;
    final eventCount = isCurrentMonth ? (eventsPerDay[day] ?? 0) : 0;
    final textColor = isCurrentMonth ? AppColors.textBlack : Colors.black45;
    
    // Construct date string formatted as dd/MM/yyyy to match database format
    final dateString = isCurrentMonth 
        ? "${day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}"
        : "";

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Material(
        color: AppColors.textWhite,
        child: InkWell(
          onTap: isCurrentMonth
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayEventsScreen(dateString: dateString),
              ),
            );
            print("Tapped day $day, date: $dateString");
          }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentMonth ? day.toString() : "",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (eventCount > 0)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.circle, size: 5, color: AppColors.textBlack),
                          const SizedBox(height: 4),
                          Text(
                            "$eventCount Event${eventCount > 1 ? 's' : ''}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
