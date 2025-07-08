import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/employee_model.dart';
import 'employee_drawer.dart';
import 'delete_employee.dart';

class GetEmployees extends StatefulWidget {
  const GetEmployees({super.key});

  @override
  State<GetEmployees> createState() => _GetEmployeesState();
}

class _GetEmployeesState extends State<GetEmployees> {
  static const _baseUrl = "http://localhost:8080";
  static const _apiPath = "/employee/allEmployee";
  static const _cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  final _searchController = TextEditingController();
  List<Employeemodel> _allEmployees = [];
  List<Employeemodel> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees =
          _allEmployees.where((employee) {
            final firstName = employee.firstName?.toLowerCase() ?? '';
            final lastName = employee.lastName?.toLowerCase() ?? '';
            final id = employee.id?.toString().toLowerCase() ?? '';
            return firstName.contains(query) ||
                lastName.contains(query) ||
                id.contains(query);
          }).toList();
    });
  }

  Future<List<Employeemodel>> _fetchEmployees() async {
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl$_apiPath"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final employees =
            jsonData.map((e) => Employeemodel.fromJson(e)).toList();
        _allEmployees = employees;
        _filteredEmployees = employees;
        return employees;
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
      return Exception(error['message'] ?? 'Failed to load employees');
    } catch (_) {
      return Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<void> _refreshEmployees() async {
    await _fetchEmployees();
    setState(() {});
  }

  Future<void> _confirmAndDeleteEmployee(
    BuildContext context,
    String employeeId,
  ) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => Deleteemployee(employeeId: employeeId),
      ),
    );

    if (deleted == true) {
      await _refreshEmployees();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshEmployees,
          ),
        ],
      ),
      drawer: const EmployeeDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshEmployees,
              child: FutureBuilder<List<Employeemodel>>(
                future: _fetchEmployees(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  if (_filteredEmployees.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildEmployeeList();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load employees',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshEmployees,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No employees found', style: TextStyle(fontSize: 18)),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'No results for "${_searchController.text}"',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterEmployees();
              },
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
        return _buildEmployeeCard(context, employee);
      },
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employeemodel employee) {
    return Card(
      margin: _cardMargin,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(context, employee),
        onLongPress: () => _showQuickActions(context, employee),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  employee.firstName?.isNotEmpty ?? false
                      ? employee.firstName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${employee.firstName ?? ''} ${employee.lastName ?? ''}'
                          .trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${employee.id ?? 'N/A'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Employeemodel employee) {
    if (employee.id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EmployeeDetailPage(
              employee: employee,
              onEmployeeDeleted: _refreshEmployees,
            ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, Employeemodel employee) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Employee'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEdit(context, employee);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Employee',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (employee.id != null) {
                      _confirmAndDeleteEmployee(context, employee.id!);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToEdit(BuildContext context, Employeemodel employee) {
    if (employee.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit - invalid employee ID')),
      );
      return;
    }
    // TODO: Implement edit navigation
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => EditEmployeePage(employee: employee),
    // ));
  }
}

class EmployeeDetailPage extends StatelessWidget {
  final Employeemodel employee;
  final VoidCallback? onEmployeeDeleted;

  const EmployeeDetailPage({
    super.key,
    required this.employee,
    this.onEmployeeDeleted,
  });

  Future<void> _deleteEmployee(BuildContext context) async {
    if (employee.id == null) return;

    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => Deleteemployee(employeeId: employee.id!),
      ),
    );

    if (deleted == true) {
      if (onEmployeeDeleted != null) onEmployeeDeleted!();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blue[100],
                child: Text(
                  employee.firstName?.isNotEmpty ?? false
                      ? employee.firstName![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailCard(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _deleteEmployee(context),
        backgroundColor: Colors.red[400],
        child: const Icon(Icons.delete, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('First Name', employee.firstName ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Last Name', employee.lastName ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Employee ID', employee.id?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    if (employee.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit - invalid employee ID')),
      );
      return;
    }
    // TODO: Implement edit navigation
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => EditEmployeePage(employee: employee),
    // ));
  }
}
