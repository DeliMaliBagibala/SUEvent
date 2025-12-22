import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_detail.dart';
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

  static const Map<String, String> _catPics = {
    "Food": "assets/images/generic_food.png",
    "Movies": "assets/images/generic_movie.png",
    "Clubs": "assets/images/generic_clubs.png",
    "Games": "assets/images/generic_dice.png",
    "Hanging Out": "assets/images/generic_hangout.png",
    "Sports": "assets/images/generic_sports.png",
    "Music": "assets/images/generic_music.png",
    "Other": "assets/images/generic_other.png",
  };

  int _timeVal(String val) {
    final parts = val.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  ImageProvider _picFor(Event event) {
    if (event.imageUrls.isNotEmpty) {
      final val = event.imageUrls.first;
      if (val.startsWith("data:image")) {
        final data = val.split(",").last;
        return MemoryImage(base64Decode(data));
      }
      if (val.startsWith("assets/")) {
        return AssetImage(val);
      }
      return NetworkImage(val);
    }
    return AssetImage(_catPics[event.category] ?? "assets/images/generic_other.png");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final dayEvents = eventProvider.events
            .where((event) => event.date == widget.dateString)
            .toList();

        final filteredEvents = _selectedCategory == 'All'
            ? dayEvents
            : dayEvents.where((e) => e.category == _selectedCategory).toList();
        filteredEvents.sort((a, b) => _timeVal(a.time).compareTo(_timeVal(b.time)));

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
                        icon: const Icon(Icons.arrow_left, size: 40, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.dateString,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                          color: Colors.black,
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
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            dropdownColor: AppColors.accentLight,
                            style: const TextStyle(
                              color: Colors.black,
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
                            return _buildDayEventCard(filteredEvents[index]);
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

  Widget _buildDayEventCard(Event event) {
    final categoryColor = AppColors.categoryColors[event.category] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: categoryColor,
            backgroundImage: _picFor(event),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      event.location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event, onBackTap: () => Navigator.pop(context)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBDBDBD),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: const [
                    Text(
                      "View\nEvent",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Icon(Icons.play_arrow, color: Colors.white, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
