import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_innovations_assignment/blocs/employee_bloc.dart';
import 'package:realtime_innovations_assignment/models/employee.dart';
import 'package:realtime_innovations_assignment/screens/add_employee.dart';
import 'package:realtime_innovations_assignment/screens/edit_employee.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  bool _isCurrent(Employee employee) {
    // If endDate is null or after today, the employee is current
    return employee.endDate == null ||
        employee.endDate!.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<EmployeeBloc>(),
                child: const AddEmployeeScreen(),
              ),
            ),
          );
        },
        tooltip: "ADD Employee",
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoaded) {
            final currentEmployees = state.employees.where(_isCurrent).toList();
            final previousEmployees =
                state.employees.where((e) => !_isCurrent(e)).toList();

            return ListView(
              children: [
                if (currentEmployees.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Current Employees",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...currentEmployees
                      .map((e) => _buildEmployeeTile(context, e)),
                ],
                if (previousEmployees.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Previous Employees",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...previousEmployees
                      .map((e) => _buildEmployeeTile(context, e)),
                ],
                if (currentEmployees.isEmpty && previousEmployees.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("No employees found"),
                    ),
                  )
              ],
            );
          } else if (state is EmployeeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("Something went wrong"));
          }
        },
      ),
    );
  }

  Widget _buildEmployeeTile(BuildContext context, Employee employee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Dismissible(
        key: Key(employee.eid),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          context.read<EmployeeBloc>().add(DeleteEmployee(employee.eid));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Employee data has been deleted")),
          );
        },
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: Colors.deepPurple.shade100,
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(employee.name),
            subtitle: Text(employee.role),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: "Edit Employee",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEmployeeScreen(employee: employee),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
