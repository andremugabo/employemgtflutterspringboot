import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:employeeflutterspring/model/employee_model.dart';
import 'package:http/http.dart' as http;

class RegisterEmployee extends StatefulWidget {
  final void Function() onEmployeeRegistered;

  const RegisterEmployee({super.key, required this.onEmployeeRegistered});

  @override
  State<RegisterEmployee> createState() => _RegisterEmployeeState();
}

class _RegisterEmployeeState extends State<RegisterEmployee> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  static const _baseUrl = "http://localhost:8080";
  static const _apiPath = "/employee/add";
  static const _fieldPadding = 12.0;
  static const _buttonHeight = 48.0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<Employeemodel?> _registerEmployee({
    required String firstName,
    required String lastName,
  }) async {
    final uri = Uri.parse("$_baseUrl$_apiPath");
    final body = jsonEncode({"firstName": firstName, "lastName": lastName});

    try {
      final response = await http
          .post(uri, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return employeemodelFromJson(response.body);
      } else {
        throw _handleApiError(response);
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response');
    }
  }

  Exception _handleApiError(http.Response response) {
    try {
      final error = jsonDecode(response.body);
      return Exception(error['message'] ?? 'Unknown API error');
    } catch (_) {
      return Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final employee = await _registerEmployee(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (employee != null) {
        _handleRegistrationSuccess(employee);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleRegistrationSuccess(Employeemodel employee) {
    widget.onEmployeeRegistered();
    _firstNameController.clear();
    _lastNameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully registered ${employee.firstName} ${employee.lastName}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _showSuccessDialog(employee);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(Employeemodel employee) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Registration Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${employee.id}'),
                const SizedBox(height: 8),
                Text('Name: ${employee.firstName} ${employee.lastName}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register Employee'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildNameField(
                context,
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter first name',
              ),
              const SizedBox(height: _fieldPadding),
              _buildNameField(
                context,
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter last name',
              ),
              const SizedBox(height: _fieldPadding * 2),
              _buildSubmitButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator:
          (value) =>
              value?.trim().isEmpty ?? true ? 'Please enter $label' : null,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
                : const Text('REGISTER EMPLOYEE'),
      ),
    );
  }
}
