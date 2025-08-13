import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';
import '../config.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _type = 'sugerencia';
  String _message = '';
  bool _isSubmitting = false;

  final List<String> _types = ['sugerencia', 'error', 'consulta'];

  Future<void> _submitFeedback(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final uri = Uri.parse('${Config.baseUrl}/feedback');
    final headers = {
      'Content-Type': 'application/json',
      if (authProvider.token != null)
        'Authorization': 'Bearer ${authProvider.token}',
    };

    final body = jsonEncode({
      if (!authProvider.isAuthenticated) 'email': _email,
      'type': _type,
      'message': _message,
    });

    final response = await http.post(uri, headers: headers, body: body);

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gracias por tu opinión')),
      );
      Navigator.pop(context); // Vuelve atrás después de enviar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar sugerencia')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!authProvider.isAuthenticated)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tu correo electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Este campo es obligatorio';
                    if (!value.contains('@'))
                      return 'Introduce un correo válido';
                    return null;
                  },
                  onSaved: (value) => _email = value!.trim(),
                ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de mensaje'),
                value: _type,
                items: _types
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mensaje'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.length < 5)
                    return 'El mensaje es demasiado corto';
                  return null;
                },
                onSaved: (value) => _message = value!.trim(),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _submitFeedback(authProvider),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
