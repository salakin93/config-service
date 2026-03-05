# Config Service

El **Config Service** es el servidor central de configuración de la plataforma de microservicios.
Está construido utilizando **Spring Cloud Config Server** y permite que todos los microservicios obtengan su configuración desde una fuente centralizada.

Este enfoque evita duplicación de configuraciones y facilita la gestión de múltiples ambientes como **development, staging y production**.

---

# Responsabilidad del servicio

Este servicio tiene una única responsabilidad:

**Servir configuraciones centralizadas a todos los microservicios del sistema.**

En lugar de que cada microservicio tenga su propia configuración embebida dentro del código, el Config Server permite:

* centralizar configuraciones
* cambiar propiedades sin recompilar servicios
* gestionar configuraciones por ambiente
* mantener consistencia entre microservicios

---

# Arquitectura

El Config Service funciona como intermediario entre los microservicios y el repositorio de configuraciones.

```
Microservices
      │
      ▼
Config Service (Spring Cloud Config Server)
      │
      ▼
Repositorio de configuraciones (GitHub)
```

Flujo de funcionamiento:

1. Un microservicio inicia.
2. El microservicio solicita su configuración al Config Server.
3. El Config Server busca la configuración en el repositorio Git.
4. La configuración es enviada al microservicio.

---

# Tecnologías utilizadas

| Tecnología                 | Propósito                    |
| -------------------------- | ---------------------------- |
| Spring Boot                | Framework base               |
| Spring Cloud Config Server | Servidor de configuración    |
| Gradle                     | Build tool                   |
| Docker                     | Contenerización del servicio |

---

# Estructura del proyecto

```
config-service
│
├── src
│   └── main
│       ├── java
│       │   └── edu.usip.config
│       │        └── ConfigServiceApplication.java
│       │
│       └── resources
│            └── application.properties
│
├── build.gradle
├── Dockerfile
└── README.md
```

---

# Configuración del servidor

Archivo:

```
src/main/resources/application.properties
```

Ejemplo:

```
server.port=8888

spring.application.name=config-service

spring.cloud.config.server.git.uri=https://github.com/salakin93/microservices-config
spring.cloud.config.server.git.clone-on-start=true
```

### Explicación

| Propiedad                                     | Descripción                                        |
| --------------------------------------------- | -------------------------------------------------- |
| server.port                                   | Puerto donde se ejecuta el Config Server           |
| spring.application.name                       | Nombre del servicio                                |
| spring.cloud.config.server.git.uri            | Repositorio donde se almacenan las configuraciones |
| spring.cloud.config.server.git.clone-on-start | Clona el repositorio al iniciar                    |

---

# Habilitar Config Server

La aplicación debe habilitar el servidor de configuración mediante la anotación:

```
@EnableConfigServer
```

Ejemplo:

```java
package edu.usip.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@SpringBootApplication
@EnableConfigServer
public class ConfigServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigServiceApplication.class, args);
    }

}
```

---

# Repositorio de configuraciones

El Config Server obtiene configuraciones desde un repositorio Git dedicado.

Ejemplo de repositorio:

```
microservices-config
│
├── identity-service.properties
├── gateway-service.properties
├── document-service.properties
└── ai-service.properties
```

Cada microservicio tendrá su propio archivo de configuración.

Ejemplo:

```
identity-service.properties
```

```
server.port=8081

spring.datasource.url=jdbc:postgresql://postgres:5432/identity_db
spring.datasource.username=postgres
spring.datasource.password=postgres

spring.jpa.hibernate.ddl-auto=update
```

---

# Cómo los microservicios consumen configuración

Cada microservicio debe incluir en su configuración:

```
spring.application.name=identity-service
spring.config.import=configserver:http://config-service:8888
```

Esto indica al microservicio que debe cargar su configuración desde el Config Server.

---

# Endpoints del Config Server

Para obtener configuración manualmente se puede acceder a:

```
http://localhost:8888/{application}/{profile}
```

Ejemplo:

```
http://localhost:8888/identity-service/default
```

Respuesta ejemplo:

```json
{
  "name": "identity-service",
  "profiles": ["default"],
  "propertySources": [
    {
      "source": {
        "server.port": "8081"
      }
    }
  ]
}
```

---

# Dockerización

Cada microservicio de la plataforma debe ser ejecutado dentro de contenedores Docker para poder ser orquestados mediante **Docker Compose**.

---

# Dockerfile

```
FROM gradle:8.7-jdk21 AS builder

WORKDIR /app

COPY . .

RUN gradle bootJar --no-daemon

FROM eclipse-temurin:21-jdk

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8888

ENTRYPOINT ["java","-jar","/app/app.jar"]
```

Este Dockerfile realiza:

1. Construcción de la aplicación usando Gradle
2. Generación del archivo `.jar`
3. Ejecución del servicio dentro de un contenedor Java optimizado

---

# Ejecución con Docker

Construir imagen:

```
docker build -t config-service .
```

Ejecutar contenedor:

```
docker run -p 8888:8888 config-service
```

---

# Integración con Docker Compose

Este servicio será levantado junto con los demás microservicios utilizando **Docker Compose**.

Ejemplo simplificado:

```yaml
services:

  config-service:
    build: ./config-service
    container_name: config-service
    ports:
      - "8888:8888"
```

Otros microservicios se conectarán a este servicio utilizando:

```
http://config-service:8888
```

Esto es posible porque Docker Compose crea automáticamente una red interna entre contenedores.

---

# Próximos servicios en la arquitectura

Este servicio es el primero dentro de la infraestructura de la plataforma.

Los siguientes servicios que formarán parte del sistema son:

* service-discovery (Eureka)
* api-gateway
* identity-service
* document-service
* ai-service
* notification-service
* telegram-bot-service

Todos estos servicios obtendrán su configuración desde **config-service**.

---

# Estado actual

✔ Config Server implementado
✔ Conexión con repositorio Git de configuraciones
✔ Dockerfile preparado
✔ Compatible con Docker Compose

---

# Licencia

Proyecto académico / investigación.
