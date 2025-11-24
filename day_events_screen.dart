import 'package:flutter/material.dart';
import 'theme_constants.dart';
import 'home_page.dart'; // Importing Event class

class DayEventsScreen extends StatefulWidget {
  final String dateString;

  const DayEventsScreen({super.key, required this.dateString});

  @override
  State<DayEventsScreen> createState() => _DayEventsScreenState();
}

class _DayEventsScreenState extends State<DayEventsScreen> {
  // Default filter selection
  String _selectedCategory = 'All';

  // Dummy data for this specific day
  final List<Event> _allEvents = [
    Event(title: "Sample Event 1", location: "FMAN G098", category: "Category-1", time: "09.00"),
    Event(title: "Sample Event 3", location: "UC 1023", category: "Category-1", time: "20.00"),
    Event(title: "Movie Night", location: "FMAN G089", category: "Category-2", time: "21.30"),
    Event(title: "Sample Event X", location: "UC G030", category: "Category-3", time: "14.00"),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter events based on selection
    final filteredEvents = _selectedCategory == 'All'
        ? _allEvents
        : _allEvents.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Back Button + Date)
            Container(
              color: AppColors.backgroundHeader, // Matching the grey header style
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

            // 2. Filter Row (Sort By)
            Container(
              color: AppColors.accentLight, // Light grey strip
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
                  // Dropdown for categories
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
                        items: <String>['All', 'Category-1', 'Category-2', 'Category-3']
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

            // 3. Event List
            Expanded(
              child: ListView.builder(
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
  }

  // Custom Card Widget for this screen to match the image
  Widget _buildDayEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // White Circle Avatar
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 16),

          // Event Details (Middle)
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
                    Text(
                      event.category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Button and Time (Right)
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // REQUIRED CONSOLE OUTPUT
                  print("View Event Button Pressed!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBDBDBD), // Light greyish button
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size.zero, // Allows compact size
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

