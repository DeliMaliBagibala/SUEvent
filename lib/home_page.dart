import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                    : eventProvider.events.isEmpty
                        ? const Center(child: Text("No events found."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppDimens.pagePadding),
                            itemCount: eventProvider.events.length,
                            itemBuilder: (context, index) {
                              final event = eventProvider.events[index];
                              return EventCard(
                                event: event,
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
                    : events.isEmpty
                        ? const Center(child: Text("No events found."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppDimens.pagePadding),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return EventCard(event: events[index]);
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

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

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
          const SnackBar(content: Text("You must be logged in to create an event.")),
        );
        return;
    }

    final newEvent = Event(
      id: '', // Generated by Firestore
      title: _eventTitle,
      date: _dateController.text,
      time: _timeController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      location: _locationController.text,
      createdBy: authProvider.user!.uid, // Set current user as creator
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

  Future<void> _editTitle() async {
    TextEditingController controller = TextEditingController(text: _eventTitle);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: const Text("Event Name", style: TextStyle(color: AppColors.textBlack)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: const InputDecoration(
              hintText: "Enter event name",
              hintStyle: AppTextStyles.hintText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: AppColors.textBlack)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: AppTextStyles.bodyBold),
              onPressed: () {
                setState(() {
                  _eventTitle = controller.text;
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
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: Text(label, style: const TextStyle(color: AppColors.textBlack)),
          content: TextField(
            controller: tempController,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: AppTextStyles.hintText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: AppColors.textBlack)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: AppTextStyles.bodyBold),
              onPressed: () {
                setState(() {
                  controller.text = tempController.text;
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
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
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
        final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
                  icon: const Icon(Icons.arrow_left, size: AppDimens.iconLarge, color: AppColors.textBlack),
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
                        const Icon(Icons.edit_outlined, color: AppColors.textBlack, size: AppDimens.iconSmall),
                      ],
                    ),
                  ),
                ),
                // Save Button
                IconButton(
                  icon: eventProvider.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check, size: AppDimens.iconLarge, color: AppColors.textBlack),
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
                _buildEditableRow("Date:", _dateController, () => _selectDate(context)),
                const SizedBox(height: 15),
                _buildEditableRow("Time:", _timeController, () => _selectTime(context)),
                const SizedBox(height: 15),
                _buildEditableRow("Location:", _locationController, () => _editField("Location", _locationController)),
                const SizedBox(height: 15),
                 _buildCategoryDropdown(),

                const SizedBox(height: 30),

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
                      hintText: "Add description",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Text(
                      "Add Photo:",
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        print("Button tapped");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundHeader,
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textBlack, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Container(
                    width: 200,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: AppColors.iconBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
            items: AppColors.categoryColors.keys.map<DropdownMenuItem<String>>((String value) {
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

  Widget _buildEditableRow(String label, TextEditingController controller, VoidCallback onEdit) {
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
                icon: const Icon(Icons.edit_outlined, color: AppColors.textBlack, size: AppDimens.iconSmall),
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

  @override
  Widget build(BuildContext context) {
    // Check if the current user is the creator
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.category,
                          style: AppTextStyles.cardSubtitle.copyWith(decoration: TextDecoration.none, color: Colors.white),
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
                        builder: (context) => EventDetailScreen(event: event,  onBackTap: () => Navigator.pop(context),),
                      ),
                    );
                    print("Detailed event page button pressed"); //NAVIGATE TO event_detail page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite.withOpacity(0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      Icon(Icons.play_arrow, color: AppColors.textBlack, size: AppDimens.iconSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: AppTextStyles.bodyBold,
                ),
                if (onDelete != null && isCreator) // Only show delete button if user is creator
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.textBlack, size: 20),
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
