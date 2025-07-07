package com.andremugabo.employeemgt.core.employee.service;

import com.andremugabo.employeemgt.core.employee.model.Employee;
import com.andremugabo.employeemgt.core.employee.repository.IEmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.hibernate.ObjectNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;


@RequiredArgsConstructor
@Service
public class EmployeeServiceImp implements IEmployeeService{

    private final IEmployeeRepository employeeRepository;

    @Override
    public List<Employee> getAllEmployee() {
        return employeeRepository.findAll();
    }
    @Override
    public Employee addEmployee(Employee theEmployee){
        if(!employeeRepository.existsByFirstNameAndLastName(theEmployee.getFirstName(), theEmployee.getLastName()))
        {
            return employeeRepository.save(theEmployee);
        }else{
            throw new IllegalArgumentException("Employee already exists");
        }

    }

    @Override
    public Employee deleteEmployee(UUID Id) {
        if(employeeRepository.existsById(Id)){
            Employee theEmployee = findTheEmployee(Id);
            employeeRepository.deleteById(Id);
            return theEmployee;
        }
        throw new NoSuchElementException("Employee not found");
    }

    @Override
    public Employee updateEmployee(UUID Id, Employee theEmployee) {
        Employee foundEmployee = employeeRepository.findById(Id)
                .orElseThrow(()-> new ObjectNotFoundException(Employee.class,"Employee not Found"));
       foundEmployee.setFirstName(theEmployee.getFirstName());
       foundEmployee.setLastName(theEmployee.getLastName());
       return  employeeRepository.save(foundEmployee);
    }

    @Override
    public Employee findTheEmployee(UUID Id) {
        return employeeRepository.findById(Id)
                .orElseThrow(()-> new ObjectNotFoundException(Employee.class,"Employee not found"));
    }

}
