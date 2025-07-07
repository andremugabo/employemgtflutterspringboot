package com.andremugabo.employeemgt.controller.employee;


import com.andremugabo.employeemgt.core.employee.model.Employee;
import com.andremugabo.employeemgt.core.employee.service.IEmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@RequiredArgsConstructor
@RestController
@RequestMapping("/employee")
public class EmployeeController {

    private final IEmployeeService employeeService;


    @PostMapping("/add")
    public ResponseEntity<Employee> createEmployee(@RequestBody  Employee theEmployee){
            Employee savedEmployee = employeeService.addEmployee(theEmployee);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedEmployee);
    }

    @GetMapping("/allEmployee")
    public ResponseEntity<List<Employee>> getAllEmployee(){
        List<Employee> getEmployee = employeeService.getAllEmployee();
        return ResponseEntity.ok(getEmployee);
    }

    @PutMapping("/updateEmployee/{Id}")
    public ResponseEntity<Employee> updateEmployee(@PathVariable UUID Id, @RequestBody Employee theEmployee){
        Employee updatedEmployee = employeeService.updateEmployee(Id, theEmployee);
        return ResponseEntity.ok(updatedEmployee);
    }

    @DeleteMapping("/deleteEmployee/{id}")
    public ResponseEntity<String> deleteEmployee(@PathVariable UUID id) {
        try {
            employeeService.deleteEmployee(id);
            return ResponseEntity.ok("Employee deleted successfully.");
        } catch (NoSuchElementException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Employee not found.");
        }
    }


}
