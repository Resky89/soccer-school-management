import 'package:flutter/material.dart';
import '../Layout/sidebar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../controllers/schedule_controller.dart';
import '../models/schedule_model.dart';
import 'package:shimmer/shimmer.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _lastTapped;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch initial month's schedules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleController>().fetchMonthlySchedules(_focusedDay);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const Sidebar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7F50),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showScheduleDialog(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          return Column(
            children: [
              // Custom AppBar
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'YOUTH TIGER SOCCER SCHOOL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            'images/logo.png',
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Make entire content area scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calendar Container
                      Container(
                        margin: EdgeInsets.all(constraints.maxWidth * 0.04),
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 600 : double.infinity,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.black, Color(0xFF2C2C2C)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Schedule',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFFFF7F50),
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              // Calendar Section
                              Consumer<ScheduleController>(
                                builder: (context, controller, child) {
                                  if (controller.isLoading) {
                                    return Column(
                                      children: [
                                        _buildShimmerCalendar(),
                                        _buildShimmerScheduleList(),
                                      ],
                                    );
                                  }
                                  return TableCalendar(
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: _focusedDay,
                                    selectedDayPredicate: (day) =>
                                        isSameDay(_selectedDay, day),
                                    onDaySelected: (selectedDay, focusedDay) {
                                      setState(() {
                                        _selectedDay = selectedDay;
                                        _focusedDay = focusedDay;
                                      });
                                      // Double tap detection
                                      if (isSameDay(_lastTapped, selectedDay)) {
                                        _showScheduleDialog(
                                            selectedDate: selectedDay);
                                      }
                                      _lastTapped = selectedDay;

                                      // Fetch daily schedules
                                      final formattedDate =
                                          "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                                      controller
                                          .fetchDailySchedules(formattedDate);
                                    },
                                    calendarBuilders: CalendarBuilders(
                                      markerBuilder: (context, date, events) {
                                        final formattedDate =
                                            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                                        // Find matching monthly schedule
                                        final monthlySchedule = controller
                                            .monthlySchedules
                                            .firstWhere(
                                          (schedule) =>
                                              schedule.dateSchedule ==
                                              formattedDate,
                                          orElse: () => MonthlySchedule(
                                              dateSchedule: '',
                                              totalSchedule: 0),
                                        );

                                        if (monthlySchedule.totalSchedule > 0) {
                                          return Positioned(
                                            right: 1,
                                            top: 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFFF7F50),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${monthlySchedule.totalSchedule}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                    calendarStyle: const CalendarStyle(
                                      selectedDecoration: BoxDecoration(
                                        color: Color(0xFFFF7F50),
                                        shape: BoxShape.circle,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      defaultTextStyle:
                                          TextStyle(color: Colors.white),
                                      weekendTextStyle:
                                          TextStyle(color: Colors.white),
                                      selectedTextStyle:
                                          TextStyle(color: Colors.white),
                                      todayTextStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle:
                                          TextStyle(color: Colors.white),
                                      leftChevronIcon: Icon(Icons.chevron_left,
                                          color: Colors.white),
                                      rightChevronIcon: Icon(
                                          Icons.chevron_right,
                                          color: Colors.white),
                                    ),
                                    onPageChanged: (focusedDay) {
                                      setState(() {
                                        _focusedDay = focusedDay;
                                      });
                                      // Fetch monthly schedules when month changes
                                      controller
                                          .fetchMonthlySchedules(focusedDay);
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              // Schedule List
                              Consumer<ScheduleController>(
                                builder: (context, controller, child) {
                                  if (controller.schedules.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No schedules for this date',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: controller.schedules.length,
                                    itemBuilder: (context, index) {
                                      final schedule =
                                          controller.schedules[index];
                                      return _buildScheduleItem(schedule);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleModel schedule) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              schedule.nameSchedule,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: schedule.statusSchedule == 1
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.statusSchedule == 1 ? 'Active' : 'Inactive',
              style: TextStyle(
                color: schedule.statusSchedule == 1 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFFF7F50)),
            onPressed: () => _showScheduleDialog(
              selectedDate: DateTime.parse(schedule.dateSchedule),
              schedule: schedule,
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(schedule),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content:
            Text('Are you sure you want to delete "${schedule.nameSchedule}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final success = await context
                    .read<ScheduleController>()
                    .deleteSchedule(
                        schedule.idSchedule!, schedule.dateSchedule);

                if (success && mounted) {
                  context
                      .read<ScheduleController>()
                      .fetchMonthlySchedules(_focusedDay);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog({DateTime? selectedDate, ScheduleModel? schedule}) {
    bool isActive = schedule?.statusSchedule == 1;

    // Reset or set initial values
    _titleController.text = schedule?.nameSchedule ?? '';
    _dateController.text = schedule?.dateSchedule ??
        "${selectedDate?.year}-${(selectedDate?.month ?? DateTime.now().month).toString().padLeft(2, '0')}-${(selectedDate?.day ?? DateTime.now().day).toString().padLeft(2, '0')}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      schedule != null ? 'Edit Schedule' : 'Add Schedule',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Schedule Title',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.title, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFFF7F50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(_dateController.text),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _dateController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dateController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.calendar_today,
                                  color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFFF7F50)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Status Switch
                      SwitchListTile(
                        title: const Text('Status',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color:
                                isActive ? Color(0xFFFF7F50) : Colors.white70,
                          ),
                        ),
                        value: isActive,
                        activeColor: const Color(0xFFFF7F50),
                        onChanged: (bool value) {
                          setState(() => isActive = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Submit Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a schedule title')),
                      );
                      return;
                    }

                    final scheduleData = ScheduleModel(
                      idSchedule: schedule?.idSchedule,
                      nameSchedule: _titleController.text.trim(),
                      dateSchedule: _dateController.text,
                      statusSchedule: isActive ? 1 : 0,
                    );

                    try {
                      final success = schedule != null
                          ? await context
                              .read<ScheduleController>()
                              .updateSchedule(
                                schedule.idSchedule!,
                                scheduleData,
                              )
                          : await context
                              .read<ScheduleController>()
                              .createSchedule(scheduleData);

                      if (success && mounted) {
                        Navigator.pop(context);
                        context
                            .read<ScheduleController>()
                            .fetchMonthlySchedules(_focusedDay);
                        context
                            .read<ScheduleController>()
                            .fetchDailySchedules(_dateController.text);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(schedule != null
                                ? 'Schedule updated successfully'
                                : 'Schedule added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F50),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    schedule != null ? 'Update Schedule' : 'Add Schedule',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getScheduleCount(DateTime date, List<ScheduleModel> schedules) {
    return schedules
        .where((schedule) =>
            schedule.dateSchedule ==
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}")
        .length;
  }

  Widget _buildShimmerCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Color(0xFF2C2C2C)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 26,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 35,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerScheduleList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 200,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      width: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
