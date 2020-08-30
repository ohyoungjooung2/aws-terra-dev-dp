package com.spvue.ex.repo;

import java.util.List;

import org.springframework.data.repository.CrudRepository;
 
import com.spvue.ex.model.Customer;
 
public interface CustomerRepository extends CrudRepository<Customer, Long> {
  List<Customer> findByAge(int age);
}
