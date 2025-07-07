package com.andremugabo.employeemgt.core.employee.service;

import com.andremugabo.employeemgt.core.employee.model.Employee;

import java.util.List;
import java.util.UUID;

public interface IEmployeeService {
     List<Employee> getAllEmployee();
     Employee addEmployee(Employee theEmployee);
     Employee deleteEmployee(UUID Id);
     Employee updateEmployee(UUID Id, Employee theEmployee);
     Employee findTheEmployee(UUID Id);


}
