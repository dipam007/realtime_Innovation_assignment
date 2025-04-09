import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_innovations_assignment/blocs/employee_bloc.dart';
import 'package:realtime_innovations_assignment/models/employee.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final List<String> _roles = ['Manager', 'Developer', 'Designer', 'Tester'];
  String? _selectedRole;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate({
    required Function(DateTime?) onDatePicked,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime now = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                        "Today (${now.toLocal().toString().split(' ')[0]})"),
                    enabled: firstDate == null || !now.isBefore(firstDate),
                    onTap: () {
                      if (firstDate != null && now.isBefore(firstDate)) return;
                      Navigator.pop(context);
                      onDatePicked(now);
                    },
                  ),
                  ListTile(
                    title: const Text("Next Weekday"),
                    onTap: () {
                      DateTime next = now.add(const Duration(days: 1));
                      while (next.weekday >= 6) {
                        next = next.add(const Duration(days: 1));
                      }
                      if (firstDate != null && next.isBefore(firstDate)) return;
                      Navigator.pop(context);
                      onDatePicked(next);
                    },
                  ),
                  ListTile(
                    title: const Text("Same Date Next Month"),
                    onTap: () {
                      DateTime nextMonth = DateTime(
                        now.year,
                        now.month + 1,
                        now.day,
                      );
                      if (firstDate != null && nextMonth.isBefore(firstDate)) {
                        return;
                      }
                      Navigator.pop(context);
                      onDatePicked(nextMonth);
                    },
                  ),
                  ListTile(
                    title: const Text("No Date"),
                    onTap: () {
                      Navigator.pop(context);
                      onDatePicked(null);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text("Pick Custom Date"),
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: firstDate ?? now,
                        firstDate: firstDate ?? DateTime(2000),
                        lastDate: lastDate ?? DateTime(2100),
                      );
                      onDatePicked(picked);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a role")),
        );
        return;
      }

      final employee = Employee(
        eid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        role: _selectedRole!,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate,
      );

      // Add employee using BLoC
      context.read<EmployeeBloc>().add(AddEmployee(employee));

      // Show confirmation and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employee added successfully")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Employee Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: "Role"),
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                validator: (value) =>
                    value == null ? "Please select a role" : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("Start Date"),
                subtitle: Text(
                  _startDate != null
                      ? _startDate!.toLocal().toString().split(' ')[0]
                      : "No date selected",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(
                    onDatePicked: (picked) => setState(() {
                          _startDate = picked;
                          _endDate = null;
                        })),
              ),
              ListTile(
                title: const Text("End Date"),
                subtitle: Text(
                  _endDate != null
                      ? _endDate!.toLocal().toString().split(' ')[0]
                      : "No date selected",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  if (_startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select Start Date first")),
                    );
                    return;
                  }

                  _pickDate(
                    onDatePicked: (picked) => setState(() => _endDate = picked),
                    firstDate: _startDate,
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Add Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
