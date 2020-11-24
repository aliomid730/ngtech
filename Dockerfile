FROM openjdk:8-jdk-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]

#./gradlew build && java -jar build/libs/gs-spring-boot-docker-0.1.0.jar
#docker build --build-arg JAR_FILE=build/libs/*.jar -t ngtech/pay .


#./mvnw package && java -jar target/gs-spring-boot-docker-0.1.0.jar
#docker build -t ngtech/pay .
