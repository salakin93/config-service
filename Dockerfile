# ---------- BUILD STAGE ----------
FROM gradle:8.7-jdk21 AS builder

WORKDIR /app

# Copiar archivos necesarios para cachear dependencias
COPY build.gradle settings.gradle ./
COPY gradle ./gradle

RUN gradle dependencies --no-daemon

# Copiar el código fuente
COPY . .

# Construir el jar
RUN gradle bootJar --no-daemon

# ---------- RUNTIME STAGE ----------
FROM eclipse-temurin:21-jdk

WORKDIR /app

# Copiar el jar generado
COPY --from=builder /app/build/libs/*.jar app.jar

# Puerto del Config Server
EXPOSE 8888

# Ejecutar aplicación
ENTRYPOINT ["java","-jar","/app/app.jar"]