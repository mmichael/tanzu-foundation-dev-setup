# Enabling JVM Metrics for Spring Boot Apps on Tanzu Platform

Follow these steps to enable and view JVM metrics (via Spring Boot Actuator and Prometheus) in the Tanzu Platform Hub UI.

## Step 1: Configure Maven Authentication
To fetch the Tanzu Spring SDK from the Broadcom repository, you must configure your local Maven settings with the provided entitlement token.

Create or edit your `~/.m2/settings.xml` file to include the server credentials:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
        <server>
            <id>broadcom</id>
            <username>Bearer</username>
            <password>YOUR_ENTITLEMENT_TOKEN_HERE</password>
        </server>
    </servers>
</settings>
```
*(Note: The username is literally the word `Bearer`, and the password is the JWT token).*

## Step 2: Update `pom.xml`
Add the Broadcom repository, the Tanzu Spring SDK, and the required Micrometer Prometheus registry to your `pom.xml`:

```xml
    <repositories>
        <repository>
            <id>broadcom</id>
            <url>https://usw1.packages.broadcom.com/artifactory/spring-enterprise-maven-prod-local</url>
        </repository>
    </repositories>

    <dependencyManagement>
        <dependencies>
            <!-- Import the Tanzu Spring SDK BOM -->
            <dependency>
                <groupId>com.vmware.tanzu.spring</groupId>
                <artifactId>tanzu-spring-sdk-dependencies</artifactId>
                <version>1.1.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <!-- Add the Tanzu Spring Starter -->
        <dependency>
            <groupId>com.vmware.tanzu.spring</groupId>
            <artifactId>tanzu-spring-starter</artifactId>
        </dependency>
        
        <!-- Ensure Actuator is included -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Add Prometheus Registry -->
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
            <scope>runtime</scope>
        </dependency>
    </dependencies>
```

## Step 3: Expose Actuator Endpoints
In your `src/main/resources/application.properties` (or `application.yml`), expose the necessary actuator endpoints:

```properties
management.endpoints.web.exposure.include=*
management.endpoint.prometheus.enabled=true
management.endpoint.prometheusjvm.enabled=true
```

## Step 4: Build and Deploy the App
Build the application using Maven and push it to your Tanzu Foundation:

```bash
# Build the application
mvn clean package -DskipTests

# Push to Cloud Foundry
cf push <your-app-name>
```

## Step 5: Register the Metrics Endpoint
The Tanzu Spring SDK automatically configures the Prometheus endpoint to run on a secure, internal management port (`8090`). You must register this specific internal port with the CF metric-registrar so the platform can scrape it.

Run the following command:
```bash
cf register-metrics-endpoint <your-app-name> /actuator/prometheus --internal-port 8090
```

Within a few minutes, the JVM metrics will begin populating in the **Spring Boot Actuator Insights** tab of the Tanzu Platform Hub UI.