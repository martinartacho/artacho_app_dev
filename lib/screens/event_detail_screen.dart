import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final Map<int, String> _answers = {};
  bool _isSubmitting = false;
  bool _canRespond = false;
  late Map<String, dynamic> _event;
  bool _loadingDetails = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  // Guardar los campos de visibilidad originales
  late bool _originalVisible;
  late String? _originalStartVisible;
  late String? _originalEndVisible;

  @override
  void initState() {
    super.initState();
    _event = widget.event;

    // Guardar los campos de visibilidad originales
    _originalVisible = _event['visible'] ?? true;
    _originalStartVisible = _event['start_visible'];
    _originalEndVisible = _event['end_visible'];

    _checkEventVisibility();

    // Si el evento tiene preguntas pero no están cargadas, cargar detalles
    if (_event['has_questions'] == true &&
        (_event['questions'] == null || _event['questions'].isEmpty)) {
      _loadEventDetails();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkEventVisibility() {
    final event = _event;
    final now = DateTime.now();

    debugPrint('Event visibility check:');
    debugPrint(' - Event ID: ${event['id']}');
    debugPrint(' - Visible: ${event['visible']}');
    debugPrint(' - Start visible: ${event['start_visible']}');
    debugPrint(' - End visible: ${event['end_visible']}');
    debugPrint(' - Current time: $now');

    // Condición 1: Que sea visible (si no está definido, se considera visible)
    if (event['visible'] != null && event['visible'] == false) {
      _canRespond = false;
      debugPrint(' - Result: NOT visible');
      return;
    }

    // Condición 2: Periodo comprendido entre start_visible y end_visible
    // Si no están definidos, el evento siempre es visible
    final startVisible = event['start_visible'] != null
        ? DateTime.parse(event['start_visible']).toLocal()
        : null;
    final endVisible = event['end_visible'] != null
        ? DateTime.parse(event['end_visible']).toLocal()
        : null;

    // Si ambos están definidos, verificar el período
    if (startVisible != null && endVisible != null) {
      if (now.isBefore(startVisible) || now.isAfter(endVisible)) {
        _canRespond = false;
        debugPrint(' - Result: Outside visible period');
        return;
      }
    }
    // Si solo start_visible está definido
    else if (startVisible != null && now.isBefore(startVisible)) {
      _canRespond = false;
      debugPrint(' - Result: Before start_visible');
      return;
    }
    // Si solo end_visible está definido
    else if (endVisible != null && now.isAfter(endVisible)) {
      _canRespond = false;
      debugPrint(' - Result: After end_visible');
      return;
    }

    // Si pasa todas las condiciones, puede responder
    _canRespond = true;
    debugPrint(' - Result: CAN respond');
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _loadingDetails = true;
      _errorMessage = null;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final response = await eventProvider.fetchEventDetails(_event['id']);

      // Verificar que la respuesta es un Map
      if (response is! Map<String, dynamic>) {
        throw Exception('Formato de respuesta inesperado');
      }

      // Si la respuesta tiene un campo 'data', usarlo
      final detailedEvent =
          response.containsKey('data') ? response['data'] : response;

      // Verificar que detailedEvent es un Map
      if (detailedEvent is! Map<String, dynamic>) {
        throw Exception(
            'Los detalles del evento no tienen el formato esperado');
      }

      // Preservar los campos de visibilidad originales en el evento detallado
      setState(() {
        _event = {
          ...detailedEvent,
          'visible': _originalVisible,
          'start_visible': _originalStartVisible,
          'end_visible': _originalEndVisible,
        };
        _loadingDetails = false;
      });

      // Revisar visibilidad nuevamente con la información completa
      _checkEventVisibility();
    } catch (e) {
      setState(() {
        _loadingDetails = false;
        _errorMessage = 'Error al cargar detalles: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = _event['questions'] ?? [];
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_event['title'] ?? 'Detalle del Evento'),
      ),
      body: _loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEventInfo(_event),
                            const SizedBox(height: 24),
                            if (questions.isNotEmpty && _canRespond)
                              _buildQuestionsForm(questions)
                            else if (questions.isNotEmpty && !_canRespond)
                              _buildNotAvailableMessage()
                            else if (_event['has_questions'] == true)
                              const Text('Cargando preguntas...')
                            else
                              const Text('Este evento no tiene preguntas.'),
                          ],
                        ),
                      ),
                    ),
                    if (questions.isNotEmpty && _canRespond)
                      _buildSubmitButton(eventProvider),
                  ],
                ),
    );
  }

  Widget _buildEventInfo(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event['title'] ?? 'Sin título',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (event['description'] != null)
          Text(
            event['description'],
            style: const TextStyle(fontSize: 16),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text(_formatDateTime(event['start'])),
            if (event['end'] != null) ...[
              const Text(' - '),
              Text(_formatDateTime(event['end'])),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (event['location'] != null)
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Text(event['location']),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.visibility, size: 16),
            const SizedBox(width: 8),
            Text(_getVisibilityStatus()),
          ],
        ),
      ],
    );
  }

  String _getVisibilityStatus() {
    if (!_canRespond) {
      return 'No disponible para respuestas';
    }

    final event = _event;
    final now = DateTime.now();

    if (event['start_visible'] != null) {
      final startVisible = DateTime.parse(event['start_visible']).toLocal();
      if (now.isBefore(startVisible)) {
        return 'Disponible a partir del ${_formatDisplayDate(startVisible)}';
      }
    }

    if (event['end_visible'] != null) {
      final endVisible = DateTime.parse(event['end_visible']).toLocal();
      if (now.isAfter(endVisible)) {
        return 'Finalizó el ${_formatDisplayDate(endVisible)}';
      }
    }

    return 'Disponible para respuestas';
  }

  Widget _buildQuestionsForm(List<dynamic> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preguntas:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...questions.map((question) {
          return _buildQuestionField(question);
        }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton(EventProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: () {
                  _submitAnswers(provider);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Enviar respuestas',
                  style: TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }

  Widget _buildQuestionField(Map<String, dynamic> question) {
    final questionId = question['id'];
    final questionText = question['question'];
    final type = question['type'];
    final options = question['options'] ?? [];
    final isRequired = question['required'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isRequired ? Colors.red : Colors.black,
              ),
            ),
            if (isRequired) const SizedBox(height: 4),
            if (isRequired)
              const Text(
                '* Requerido',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            const SizedBox(height: 8),
            if (type == 'text')
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Escribe tu respuesta',
                ),
                onChanged: (value) {
                  _answers[questionId] = value;
                },
              )
            else if (type == 'single' && options.isNotEmpty)
              Column(
                children: options.map<Widget>((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _answers[questionId],
                    onChanged: (value) {
                      setState(() {
                        _answers[questionId] = value!;
                      });
                    },
                  );
                }).toList(),
              )
            else if (type == 'multiple' && options.isNotEmpty)
              Column(
                children: options.map<Widget>((option) {
                  return CheckboxListTile(
                    title: Text(option),
                    value: _answers[questionId]?.contains(option) ?? false,
                    onChanged: (checked) {
                      setState(() {
                        final currentAnswers =
                            _answers[questionId]?.split(',') ?? [];
                        if (checked == true) {
                          currentAnswers.add(option);
                        } else {
                          currentAnswers.remove(option);
                        }
                        _answers[questionId] = currentAnswers.join(',');
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAvailableMessage() {
    final event = _event;
    final now = DateTime.now();

    String reason =
        'Este evento no está disponible para respuestas en este momento.';

    // Verificar la razón específica
    if (event['visible'] != null && event['visible'] == false) {
      reason = 'Este evento no es visible.';
    } else if (event['start_visible'] != null) {
      final startVisible = DateTime.parse(event['start_visible']).toLocal();
      if (now.isBefore(startVisible)) {
        reason =
            'Este evento estará disponible a partir del ${_formatDisplayDate(startVisible)}.';
      }
    } else if (event['end_visible'] != null) {
      final endVisible = DateTime.parse(event['end_visible']).toLocal();
      if (now.isAfter(endVisible)) {
        reason =
            'Este evento ya no está disponible (finalizó el ${_formatDisplayDate(endVisible)}).';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 40),
            const SizedBox(height: 10),
            Text(
              reason,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _submitAnswers(EventProvider provider) async {
    // Validar respuestas requeridas
    final questions = _event['questions'] ?? [];
    final requiredQuestions =
        questions.where((q) => q['required'] == true).toList();

    for (var question in requiredQuestions) {
      final questionId = question['id'];
      if (_answers[questionId] == null || _answers[questionId]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('La pregunta "${question['question']}" es requerida')),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      for (var entry in _answers.entries) {
        await provider.submitAnswer(
          eventId: _event['id'],
          questionId: entry.key,
          answer: entry.value,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuestas enviadas correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar respuestas: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return "Fecha no especificada";

    try {
      final date = DateTime.parse(dateString).toLocal();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Fecha inválida";
    }
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
