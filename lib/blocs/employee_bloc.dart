import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';

// -------- EVENTS --------
abstract class EmployeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddEmployee extends EmployeeEvent {
  final Employee employee;
  AddEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}

class EditEmployee extends EmployeeEvent {
  final String id;
  final Employee updatedEmployee;
  EditEmployee(this.id, this.updatedEmployee);

  @override
  List<Object?> get props => [id, updatedEmployee];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;
  DeleteEmployee(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadEmployees extends EmployeeEvent {}

// -------- STATES --------
abstract class EmployeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  EmployeeLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

// -------- BLOC LOGIC --------
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  static const _storageKey = 'employees';
  List<Employee> _employees = [];

  EmployeeBloc() : super(EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<EditEmployee>(_onEditEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);

    // Trigger loading at start
    add(LoadEmployees());
  }

  Future<void> _onLoadEmployees(
      LoadEmployees event, Emitter<EmployeeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    _employees = jsonList.map((e) => Employee.fromJson(jsonDecode(e))).toList();
    emit(EmployeeLoaded(List.from(_employees)));
  }

  Future<void> _onAddEmployee(
      AddEmployee event, Emitter<EmployeeState> emit) async {
    _employees.add(event.employee);
    await _saveToPrefs();
    emit(EmployeeLoaded(List.from(_employees)));
  }

  Future<void> _onEditEmployee(
      EditEmployee event, Emitter<EmployeeState> emit) async {
    _employees = _employees
        .map((e) => e.eid == event.id ? event.updatedEmployee : e)
        .toList();
    await _saveToPrefs();
    emit(EmployeeLoaded(List.from(_employees)));
  }

  Future<void> _onDeleteEmployee(
      DeleteEmployee event, Emitter<EmployeeState> emit) async {
    _employees.removeWhere((e) => e.eid == event.id);
    await _saveToPrefs();
    emit(EmployeeLoaded(List.from(_employees)));
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _employees.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}
