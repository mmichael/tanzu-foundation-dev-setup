package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.boot.actuate.web.exchanges.HttpExchangeRepository;
import org.springframework.boot.actuate.web.exchanges.InMemoryHttpExchangeRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@EnableAutoConfiguration
public class SpringBootTrivialApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringBootTrivialApplication.class, args);
    }

    // This is the "magic" bean that enables the recording of HTTP requests
    @Bean
    public HttpExchangeRepository httpExchangeRepository() {
        return new InMemoryHttpExchangeRepository();
    }
}

@RestController
class HelloController {
    @RequestMapping("/")
    String home() {
        return "ok";
    }

    @GetMapping("/hello")
    public String sayHello() {
        return "Data captured!";
    }
}