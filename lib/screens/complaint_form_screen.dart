import 'package:flutter/material.dart';
import 'package:dab_app/services/api_service.dart';

class ComplaintFormScreen extends StatefulWidget {
  final int atmId;
  const ComplaintFormScreen({required this.atmId, Key? key}) : super(key: key);

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = APIService();
      final message = await api.sendComplaint(
        atmId: widget.atmId,
        email: _emailController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context); // Go back after success
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une réclamation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return "L'email est requis.";
                  final emailRegex = RegExp(r"^[\w\.\_\-]+@[a-zA-Z\d\.\-]+\.[a-zA-Z]{2,}$");
                  if (!emailRegex.hasMatch(val.trim()))
                    return "E-mail invalide.";
                  return null;
                },
                enabled: !_submitting,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return "Veuillez entrer la description.";
                  return null;
                },
                enabled: !_submitting,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Envoyer la réclamation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
