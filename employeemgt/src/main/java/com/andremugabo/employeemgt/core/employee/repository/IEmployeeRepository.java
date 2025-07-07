package com.andremugabo.employeemgt.core.employee.repository;

import com.andremugabo.employeemgt.core.employee.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface IEmployeeRepository extends JpaRepository<Employee, UUID> {
    public Boolean existsByFirstNameAndLastName(String firstName, String LastName);
    public boolean existsById(UUID Id);

}
