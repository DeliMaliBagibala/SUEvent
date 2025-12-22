import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'event_detail.dart';
import 'theme_constants.dart';
import 'calendar_screen.dart';
import 'starting_page.dart';
import 'profile_page.dart';
import 'models/event_model.dart';
import 'providers/event_provider.dart';
import 'providers/auth_provider.dart';

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        useMaterial3: true,
      ),
      home: const StartingPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    final VoidCallback onBackToHome = () => _onItemTapped(0);

    if (_selectedIndex == 0) {
      bodyContent = _buildHomeContent();
    } else if (_selectedIndex == 1) {
      bodyContent = SearchScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 2) {
      bodyContent = CreateEventScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 3) {
      bodyContent = CalendarScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 4) {
      bodyContent = ProfilePage(onBackTap: onBackToHome);
    } else {
      bodyContent = Center(child: Text("Page Index $_selectedIndex"));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: bodyContent,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.accentLight,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 0, isActive: _selectedIndex == 0),
            _buildNavItem(Icons.search, 1, isActive: _selectedIndex == 1),
            _buildNavItem(Icons.add_circle_outline, 2, isActive: _selectedIndex == 2),
            _buildNavItem(Icons.calendar_today_outlined, 3, isActive: _selectedIndex == 3),
            _buildNavItem(Icons.person_outline, 4, isActive: _selectedIndex == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final weekLater = today.add(const Duration(days: 7)); //filter events for the next 7 days

        final upcomingEvents = eventProvider.events.where((event) {
          try {
            final dateParts = event.date.split('/');
            final eventDate = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
            return eventDate.isAfter(today.subtract(const Duration(days: 1))) && eventDate.isBefore(weekLater);
          } catch (e) {
            return false;
          }
        }).toList();

        upcomingEvents.sort((a, b) {
          try {
            final aDateParts = a.date.split('/');
            final bDateParts = b.date.split('/');
            final aDateTime = DateTime(int.parse(aDateParts[2]), int.parse(aDateParts[1]), int.parse(aDateParts[0]));
            final bDateTime = DateTime(int.parse(bDateParts[2]), int.parse(bDateParts[1]), int.parse(bDateParts[0]));

            int dateComparison = aDateTime.compareTo(bDateTime);
            if (dateComparison != 0) return dateComparison;

            final aTimeParts = a.time.split(':');
            final bTimeParts = b.time.split(':');
            final aTime = TimeOfDay(hour: int.parse(aTimeParts[0]), minute: int.parse(aTimeParts[1]));
            final bTime = TimeOfDay(hour: int.parse(bTimeParts[0]), minute: int.parse(bTimeParts[1]));
            final aTimeInMinutes = aTime.hour * 60 + aTime.minute;
            final bTimeInMinutes = bTime.hour * 60 + bTime.minute;
            return aTimeInMinutes.compareTo(bTimeInMinutes);
          } catch (e) {
            return 0;
          }
        });

        final Map<String, List<Event>> groupedEvents = {};
        for (final event in upcomingEvents) {
          if (groupedEvents.containsKey(event.date)) {
            groupedEvents[event.date]!.add(event);
          } else {
            groupedEvents[event.date] = [event];
          }
        }
        final uniqueDates = groupedEvents.keys.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Consumer<AppAuthProvider>(
                builder: (context, auth, _) {
                  String username = auth.userData?['username'] ?? 'User';
                  return Text(
                    "Welcome Back, $username!",
                    style: AppTextStyles.headerLarge,
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppDimens.smallRadius),
              ),
              child: const Text(
                "Upcoming Events:",
                style: AppTextStyles.bodyBold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                color: AppColors.backgroundDark,
                child: eventProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : uniqueDates.isEmpty
                        ? const Center(child: Text("No events in the next 7 days."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppDimens.pagePadding),
                            itemCount: uniqueDates.length,
                            itemBuilder: (context, index) {
                              final date = uniqueDates[index];
                              final eventsForDate = groupedEvents[date]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                                        border: Border.all(color: AppColors.textBlack.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        date,
                                        style: AppTextStyles.dateHeader,
                                      ),
                                    ),
                                  ),
                                  ...eventsForDate.map((event) => EventCard(event: event)).toList(),
                                ],
                              );
                            },
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isActive
            ? BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black54, width: 2),
              )
            : null,
        child: Icon(
          icon,
          size: AppDimens.iconMedium,
          color: AppColors.iconBlack,
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const SearchScreen({super.key, required this.onBackTap});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final events = eventProvider.events.where((event) {
          final query = _searchQuery.toLowerCase();
          return event.title.toLowerCase().contains(query) ||
              event.location.toLowerCase().contains(query) ||
              event.category.toLowerCase().contains(query);
        }).toList();

        events.sort((a, b) {
          try {
            final aDateParts = a.date.split('/');
            final bDateParts = b.date.split('/');
            final aDateTime = DateTime(int.parse(aDateParts[2]), int.parse(aDateParts[1]), int.parse(aDateParts[0]));
            final bDateTime = DateTime(int.parse(bDateParts[2]), int.parse(bDateParts[1]), int.parse(bDateParts[0]));

            int dateComparison = aDateTime.compareTo(bDateTime);
            if (dateComparison != 0) return dateComparison;

            final aTimeParts = a.time.split(':');
            final bTimeParts = b.time.split(':');
            final aTime = TimeOfDay(hour: int.parse(aTimeParts[0]), minute: int.parse(aTimeParts[1]));
            final bTime = TimeOfDay(hour: int.parse(bTimeParts[0]), minute: int.parse(bTimeParts[1]));
            final aTimeInMinutes = aTime.hour * 60 + aTime.minute;
            final bTimeInMinutes = bTime.hour * 60 + bTime.minute;
            return aTimeInMinutes.compareTo(bTimeInMinutes);
          } catch (e) {
            return 0;
          }
        });

        final Map<String, List<Event>> groupedEvents = {};
        for (final event in events) {
          if (groupedEvents.containsKey(event.date)) {
            groupedEvents[event.date]!.add(event);
          } else {
            groupedEvents[event.date] = [event];
          }
        }
        final uniqueDates = groupedEvents.keys.toList();

        return Column(
          children: [
            Container(
              color: AppColors.backgroundHeader,
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, size: AppDimens.iconLarge, color: AppColors.textBlack),
                    onPressed: widget.onBackTap,
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: AppTextStyles.labelLarge,
                        decoration: const InputDecoration(
                          hintText: "Search",
                          hintStyle: AppTextStyles.labelLarge,
                          prefixIcon: Icon(Icons.search, color: AppColors.textBlack, size: 28),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.backgroundDark,
                child: eventProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : uniqueDates.isEmpty
                        ? const Center(child: Text("No events found."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppDimens.pagePadding),
                            itemCount: uniqueDates.length,
                            itemBuilder: (context, index) {
                              final date = uniqueDates[index];
                              final eventsForDate = groupedEvents[date]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                                        border: Border.all(color: AppColors.textBlack.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        date,
                                        style: AppTextStyles.dateHeader,
                                      ),
                                    ),
                                  ),
                                  ...eventsForDate.map((event) => EventCard(event: event)).toList(),
                                ],
                              );
                            },
                          ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CreateEventScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const CreateEventScreen({super.key, required this.onBackTap});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String _eventTitle = "NEW EVENT";
  String _selectedCategory = "Other";
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

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  List<String> _pics = [];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: "01/01/2026");
    _timeController = TextEditingController(text: "00:00");
    _descriptionController = TextEditingController();
    _locationController = TextEditingController(text: "FMAN G098");
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be logged in to create an event.")),
      );
      return;
    }

    final pics = List<String>.from(_pics);

    final newEvent = Event(
      id: '',
      title: _eventTitle,
      date: _dateController.text,
      time: _timeController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      location: _locationController.text,
      createdBy: authProvider.user!.uid,
      imageUrls: pics,
    );

    await eventProvider.addEvent(newEvent);

    if (eventProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(eventProvider.error!)),
        );
        eventProvider.clearError();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event created successfully!")),
        );
        widget.onBackTap();
      }
    }
  }

  Future<void> _pickPics() async {
    if (_pics.length >= 3) return;
    final picker = ImagePicker();
    final imgs = await picker.pickMultiImage(imageQuality: 75);
    if (imgs.isEmpty) return;
    final canAdd = 3 - _pics.length;
    final picked = imgs.length > canAdd ? imgs.sublist(0, canAdd) : imgs;
    final list = <String>[];
    for (final img in picked) {
      final bytes = await img.readAsBytes();
      list.add("data:image/jpeg;base64,${base64Encode(bytes)}");
    }
    setState(() {
      _pics.addAll(list);
    });
  }

  void _removePic(int index) {
    setState(() {
      _pics.removeAt(index);
    });
  }

  static const int _titleMax = 14;

  Future<void> _editTitle() async {
    TextEditingController controller = TextEditingController(text: _eventTitle);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: const Text("Event Name",
              style: TextStyle(color: AppColors.textBlack)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textBlack),
            maxLength: _titleMax,
            decoration: const InputDecoration(
              hintText: "Enter event name",
              hintStyle: AppTextStyles.hintText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.textBlack)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: AppTextStyles.bodyBold),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                setState(() {
                  _eventTitle = text.length > _titleMax ? text.substring(0, _titleMax) : text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editField(String label, TextEditingController controller) async {
    TextEditingController tempController = TextEditingController(text: controller.text);
    final limit = label == "Location" ? 10 : null;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: Text(label, style: const TextStyle(color: AppColors.textBlack)),
          content: TextField(
            controller: tempController,
            style: const TextStyle(color: AppColors.textBlack),
            maxLength: limit,
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: AppTextStyles.hintText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.textBlack)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: AppTextStyles.bodyBold),
              onPressed: () {
                var text = tempController.text.trim();
                if (limit != null && text.length > limit) {
                  text = text.substring(0, limit);
                }
                setState(() {
                  controller.text = text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final String formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        _timeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left,
                      size: AppDimens.iconLarge, color: AppColors.textBlack),
                  onPressed: widget.onBackTap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _editTitle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _eventTitle.toUpperCase(),
                          style: AppTextStyles.headerMediumThin,
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.edit_outlined,
                            color: AppColors.textBlack,
                            size: AppDimens.iconSmall),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: eventProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check,
                          size: AppDimens.iconLarge,
                          color: AppColors.textBlack),
                  onPressed: eventProvider.isLoading ? null : _saveEvent,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildEditableRow(
                    "Date:", _dateController, () => _selectDate(context)),
                const SizedBox(height: 15),
                _buildEditableRow(
                    "Time:", _timeController, () => _selectTime(context)),
                const SizedBox(height: 15),
                _buildEditableRow("Location:", _locationController,
                    () => _editField("Location", _locationController)),
                const SizedBox(height: 15),
                _buildCategoryDropdown(),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        "Images:",
                        style: AppTextStyles.labelLarge,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._pics.asMap().entries.map((entry) {
                              final data = entry.value.split(",").last;
                              return Container(
                                width: 70,
                                height: 70,
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(data),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: GestureDetector(
                                        onTap: () => _removePic(entry.key),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            GestureDetector(
                              onTap: _pickPics,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black54),
                                ),
                                child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textBlack),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 80,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    border: Border.all(color: Colors.black54),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    style: const TextStyle(color: AppColors.textBlack),
                    decoration: const InputDecoration(
                      hintText: "Add description...",
                      hintStyle: TextStyle(color: AppColors.textBlack),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            "Category:",
            style: AppTextStyles.labelLarge,
          ),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            items: AppColors.categoryColors.keys
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: AppTextStyles.labelLarge),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableRow(
      String label, TextEditingController controller, VoidCallback onEdit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.labelLarge,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: onEdit,
            style: AppTextStyles.labelLarge,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textBlack, size: AppDimens.iconSmall),
                onPressed: onEdit,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onDelete;

  const EventCard({super.key, required this.event, this.onDelete});

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

  ImageProvider _cardPic() {
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
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final isCreator = authProvider.user?.uid == event.createdBy;
    final categoryColor = AppColors.categoryColors[event.category] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: categoryColor,
              backgroundImage: _cardPic(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.bodyBold,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        event.location,
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.category,
                          style: AppTextStyles.cardSubtitle.copyWith(
                              decoration: TextDecoration.none,
                              color: Colors.white),
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
                        builder: (context) => EventDetailScreen(
                          event: event,
                          onBackTap: () => Navigator.pop(context),
                        ),
                      ),
                    );
                    print(
                        "Detailed event page button pressed"); //NAVIGATE TO event_detail page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite.withOpacity(0.5),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "View\nEvent",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.buttonSmall,
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.play_arrow,
                          color: AppColors.textBlack, size: AppDimens.iconSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: AppTextStyles.bodyBold,
                ),
                if (onDelete != null &&
                    isCreator) // only show delete button if user is creator
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: AppColors.textBlack, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
