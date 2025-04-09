import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_innovations_assignment/screens/employee_screen.dart';
import 'blocs/employee_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => EmployeeBloc(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Employee App',
      debugShowCheckedModeBanner: false,
      home: EmployeeScreen(),
    );
  }
}
