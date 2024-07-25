FROM openjdk:17-jdk-slim
WORKDIR /app
COPY simple-java-maven-app/target/my-app-1.0-SNAPSHOT.jar /app/my-app-1.0-SNAPSHOT.jar 
Expose 8080
ENTRYPOINT ["java", "jar", "/app/my-app-1.0-SNAPSHOT.jar"]