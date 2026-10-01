# Spring Boot Trivial App

Simple Spring boot app with actuators, metrics and traces enabled. 
`/` returns `ok` 
`/hello` returns `Data captured!` 

Use /actuator to find all available actuator endpoints

## Building

The application JAR can be rebuilt by running `mvn package` provided a JDK and Maven are installed.

## Deploy
 Run `cf push`