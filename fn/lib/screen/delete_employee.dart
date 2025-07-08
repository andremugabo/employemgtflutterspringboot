import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/employee_model.dart';

class Deleteemployee extends StatefulWidget {
  final String employeeId;
  final VoidCallback? onEmployeeDeleted;

  const Deleteemployee({
    super.key,
    required this.employeeId,
    this.onEmployeeDeleted,
  });

  @override
  State<Deleteemployee> createState() => _DeleteemployeeState();
}

class _DeleteemployeeState extends State<Deleteemployee> {
  bool _isLoading = false;
  final String _baseUrl = "http://localhost:8080";
  final String _apiPath = "/employee/deleteEmployee";

  Future<void> _deleteEmployee() async {
    if (widget.employeeId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid employee ID')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$_baseUrl$_apiPath/${widget.employeeId}");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (widget.onEmployeeDeleted != null) {
          widget.onEmployeeDeleted!();
        }
        Navigator.of(context).pop(true); // Return success
      } else {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this employee? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteEmployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Employee'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 72,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Delete Employee #${widget.employeeId}?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This action will permanently remove the employee record.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                          : const Text(
                            'DELETE EMPLOYEE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
