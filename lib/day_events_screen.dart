import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_constants.dart';
import 'home_page.dart';
import 'models/event_model.dart';
import 'providers/event_provider.dart';

class DayEventsScreen extends StatefulWidget {
  final String dateString;

  const DayEventsScreen({super.key, required this.dateString});

  @override
  State<DayEventsScreen> createState() => _DayEventsScreenState();
}

class _DayEventsScreenState extends State<DayEventsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        // Filter events for the selected day
        final dayEvents = eventProvider.events
            .where((event) => event.date == widget.dateString)
            .toList();

        // Further filter by category if not 'All'
        final filteredEvents = _selectedCategory == 'All'
            ? dayEvents
            : dayEvents.where((e) => e.category == _selectedCategory).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: AppColors.backgroundHeader,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: 40, color: AppColors.textBlack),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.dateString,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.accentLight,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sort By:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textBlack),
                            dropdownColor: AppColors.accentLight,
                            style: const TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            items: <String>['All', ...AppColors.categoryColors.keys]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredEvents.isEmpty
                      ? const Center(child: Text("No events on this day."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            return EventCard(event: filteredEvents[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
