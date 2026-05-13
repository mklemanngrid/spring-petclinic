FROM eclipse-temurin:17-jdk-jammy@sha256:978ed38b7785312f7761bee5e24cfcd7ac2fe466c5f07acee7b322e0bae6d0ec AS build
WORKDIR /project

COPY gradlew build.gradle settings.gradle ./
COPY gradle ./gradle

RUN chmod +x gradlew && ./gradlew dependencies

COPY src ./src
RUN ./gradlew build -x test

FROM eclipse-temurin:17-jre-jammy@sha256:642d45bf22d3cb9face159181732ed9fa70873b2681e50445eff7d4785c176bb

RUN apt-get update && \
    apt-get install -y dumb-init && \
    rm -rf /var/lib/apt/lists/*
RUN groupadd --system javauser && \
    useradd --system -s /bin/false -g javauser javauser

WORKDIR /app
COPY --from=build /project/build/libs/spring-petclinic-*.jar /app/petclinic.jar
RUN chown -R javauser:javauser /app

USER javauser
EXPOSE 8080
CMD ["dumb-init", "java", "-jar", "petclinic.jar"]
