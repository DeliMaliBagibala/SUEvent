import 'package:flutter/material.dart';
import 'theme_constants.dart';
import 'day_events_screen.dart'; // Import the new screen

class CalendarScreen extends StatelessWidget {
  final VoidCallback onBackTap;

  const CalendarScreen({super.key, required this.onBackTap});

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
                onPressed: onBackTap,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "November",
                    style: AppTextStyles.headerLarge.copyWith(fontSize: 32),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // This will be made later, I hope
                },
                child: Text(
                  "Next Month",
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textBlack.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),

        Expanded(
          child: Container(
            color: AppColors.textWhite,
            child: CalendarGrid(),
          ),
        ),
      ],
    );
  }
}

class CalendarGrid extends StatelessWidget {
  CalendarGrid({super.key});

  final List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  final List<int> _daysInMonth = const [
    -1, -1, -1, 1, 2, 3, 4,
    5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18,
    19, 20, 21, 22, 23, 24, 25,
    26, 27, 28, 29, 30, -2, -2,
  ];

  final Map<int, int> _eventsPerDay = {
    26: 4, 27: 4, 28: 4, 29: 4, 30: 4, 1: 4, 2: 4,
    3: 4, 4: 4, 5: 4, 6: 4, 7: 4, 8: 4, 9: 4,
    10: 4, 11: 4, 12: 4, 13: 4, 14: 4, 15: 4, 16: 4,
    17: 4, 18: 4, 19: 4, 20: 4, 21: 4, 22: 4, 23: 4,
    24: 4, 25: 4, 30: 4,
  };

  @override
  Widget build(BuildContext context) {
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
            itemCount: _daysInMonth.length,
            itemBuilder: (context, index) {
              final day = _daysInMonth[index];
              return _buildDayCell(context, day);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, int day) {
    final isCurrentMonth = day > 0;
    final eventCount = isCurrentMonth ? (_eventsPerDay[day] ?? 0) : 0;

    final textColor = isCurrentMonth ? AppColors.textBlack : Colors.black45;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Material(
        color: AppColors.textWhite,
        child: InkWell(
          onTap: isCurrentMonth
              ? () {
            // Navigate to the Day Events Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayEventsScreen(dateString: "$day, October"), // Passing dummy month for now
              ),
            );
            print("Tapped day $day");
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
                            "$eventCount Events",
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