import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/event_provider.dart';

class EventsCalendarScreen extends StatefulWidget {
  const EventsCalendarScreen({super.key});

  @override
  State<EventsCalendarScreen> createState() => _EventsCalendarScreenState();
}

class _EventsCalendarScreenState extends State<EventsCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Cargar eventos al iniciar
    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).fetchEvents(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;

    // Mapear eventos por fecha
    final eventsByDate = _groupEventsByDate(events);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Eventos'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return eventsByDate[_formatDate(day)] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        events.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildEventList(eventsByDate, eventProvider),
          ),
        ],
      ),
    );
  }

  Map<String, List<dynamic>> _groupEventsByDate(List<dynamic> events) {
    final Map<String, List<dynamic>> eventsByDate = {};

    for (var event in events) {
      final dateString = event['start']?.split('T')[0];
      if (dateString != null) {
        if (!eventsByDate.containsKey(dateString)) {
          eventsByDate[dateString] = [];
        }
        eventsByDate[dateString]!.add(event);
      }
    }

    return eventsByDate;
  }

  Widget _buildEventList(
      Map<String, List<dynamic>> eventsByDate, EventProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedDay == null) {
      return const Center(child: Text('Selecciona una fecha'));
    }

    final selectedDateStr = _formatDate(_selectedDay!);
    final dayEvents = eventsByDate[selectedDateStr] ?? [];

    if (dayEvents.isEmpty) {
      return Center(
        child: Text('No hay eventos para ${_formatDisplayDate(_selectedDay!)}'),
      );
    }

    return ListView.builder(
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: event['has_questions']
                ? const Icon(Icons.question_answer, color: Colors.blue)
                : const Icon(Icons.event, color: Colors.grey),
            title: Text(event['title'] ?? 'Sin título'),
            subtitle: Text(_formatTime(event['start'])),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/event-detail',
                arguments: event,
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return "Hora no especificada";

    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return "Hora inválida";
    }
  }
}
