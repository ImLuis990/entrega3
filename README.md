# 🏋️ ENTREGA 3 — Backend Completo + Seguridad + Postman (ApexFit)

> **Asignatura / Proyecto:** Proyecto de Aula FullStack — Entrega 3  
> **Objetivo:** Backend robusto, seguro, con control de acceso por roles (RBAC), autenticación JWT y completamente documentado/probado con suite de Postman automatizada.  
> **Tecnologías:** Java 17 · Spring Boot 3 / 4 · Spring Security 6 · Spring Data JPA · MySQL (AWS RDS / Local) · Flyway DB · JWT (io.jsonwebtoken) · Postman & Newman  

---

## 📌 1. Estructura de la Carpeta `entrega3/`

```text
entrega3/
├── README.md                                # Este documento (Guía de entrega y checklist)
├── run_postman_tests.ps1                    # Script automatizado para ejecutar las 47 pruebas con Newman
├── postman_collections/
│   └── ApexFit_JWT_Security.postman_collection.json # Colección exportada en formato estándar Postman v2.1
├── postman_environments/
│   ├── ApexFit_Local.postman_environment.json       # Ambiente Local (http://localhost:8080/api/v1)
│   └── ApexFit_AWS_RDS.postman_environment.json     # Ambiente Cloud AWS RDS
└── docs/
    ├── ARQUITECTURA_SEGURIDAD.md            # Documento de arquitectura de seguridad implementada
    ├── REPORTE_TESTS_POSTMAN.md             # Reporte detallado de ejecución de pruebas automatizadas
    ├── DOCUMENTACION_API.md                 # Catálogo exhaustivo de endpoints REST, DTOs y respuestas
    └── DOCUMENTACION_BACKEND.md             # Guía técnica integral de arquitectura, capas y MER
```

---

## 🎯 2. Verificación de Criterios y Tareas del Equipo

| # | Criterio de la Entrega | Estado | Detalle de Implementación en ApexFit |
|---|---|:---:|---|
| **1** | **CRUD completo para todas las entidades** | ✅ Cumplido | Implementado para **11 entidades**: Usuarios, Ejercicios, Rutinas, Rutina-Ejercicios, Progresos, Medidas Corporales, Membresías, Asistencias (con lector QR), Alertas y Asignaciones Entrenador-Cliente. |
| **2** | **Relaciones entre entidades en JPA** | ✅ Cumplido | Mapeos `@OneToMany`, `@ManyToOne`, `@JoinColumn` y `@ManyToMany` (vía tabla intermedia de auditoría) con integridad referencial y claves foráneas. |
| **3** | **Manejo centralizado de excepciones** | ✅ Cumplido | Clase `GlobalExceptionHandler` (`@ControllerAdvice`) que estandariza respuestas de error: `404 Not Found`, `400 Bad Request` (errores de validación estructurados), `401 Unauthorized` y `403 Forbidden`. |
| **4** | **Validaciones de entrada en endpoints** | ✅ Cumplido | Uso de **Bean Validation** (`@Valid`, `@NotBlank`, `@Email`, `@Size`, `@Min`, `@NotNull`) en todos los DTOs de entrada. |
| **5** | **Autenticación Spring Security + JWT** | ✅ Cumplido | Arquitectura **Stateless** (`SessionCreationPolicy.STATELESS`), tokens firmados con HMAC-SHA256, tiempo de expiración configurable (24 horas) y filtro interceptor `AuthTokenFilter`. |
| **6** | **Control de acceso por roles (RBAC)** | ✅ Cumplido | **3 roles** implementados (`ROLE_ADMINISTRADOR`, `ROLE_ENTRENADOR`, `ROLE_CLIENTE`) protegidos a nivel de método con `@PreAuthorize("hasRole(...)")`. |
| **7** | **Colección de Postman organizada** | ✅ Cumplido | Colección organizada en **11 carpetas modulares**, cubriendo cada entidad y casos de seguridad negativos (401 y 403). |
| **8** | **Variables de entorno en Postman** | ✅ Cumplido | Ambientes con `base_url`, `token_admin`, `token_entrenador`, `token_cliente`, IDs dinámicos y endpoints preconfigurados para Local y AWS RDS. |
| **9** | **Tests automatizados en Postman (mín. 10)** | ✅ Cumplido | **47 scripts de prueba automatizados** (`pm.test`) que evalúan códigos HTTP, tiempos de respuesta (<1500ms), esquemas JSON y almacenamiento dinámico de tokens. |
| **10**| **Documentación de la API** | ✅ Cumplido | Documentación completa en Markdown (`DOCUMENTACION_API.md` y `DOCUMENTACION_BACKEND.md`) con esquemas de request/response y roles requeridos. |

---

## 📦 3. Entregables Oficiales

### 3.1. Colección de Postman Exportada (.json)
- 📄 Ubicación: [`postman_collections/ApexFit_JWT_Security.postman_collection.json`](postman_collections/ApexFit_JWT_Security.postman_collection.json)
- Total de peticiones: 29 requests.
- Carpetas por módulo:
  1. `🔐 1. Autenticación y Tokens` (Login Admin, Entrenador, Cliente, Registro, Errores 400 y 401).
  2. `👤 2. Módulo Usuarios` (CRUD, búsqueda por correo, perfil y cambio de contraseña).
  3. `🏋️ 3. Módulo Ejercicios` (CRUD, filtros por grupo muscular y dificultad).
  4. `📋 4. Módulo Rutinas` (CRUD y consulta por cliente).
  5. `🏋️‍♂️ 5. Módulo Rutina-Ejercicios` (Asociación de series, repeticiones y descansos).
  6. `📊 6. Módulo Progresos` (Registro de peso, altura, IMC y medidas antropométricas).
  7. `💳 7. Módulo Membresías` (Gestión de estados: activa, vencida, cancelada).
  8. `⏱️ 8. Módulo Asistencias` (Registro manual y lectura de código QR).
  9. `🔔 9. Módulo Alertas` (Generación de alertas por inactividad o vencimiento).
  10. `🤝 10. Módulo Entrenador-Cliente` (Vinculación asesor-cliente).
  11. `🔒 11. Pruebas de Seguridad y Control de Roles (RBAC 401 y 403)` (Pruebas de acceso no autorizado y accesos denegados a roles no permitidos).

### 3.2. Reporte de Ejecución de Tests
- 📄 Ubicación: [`docs/REPORTE_TESTS_POSTMAN.md`](docs/REPORTE_TESTS_POSTMAN.md)
- Incluye el desglose de los **47 tests automatizados**, cobertura de aserciones de status code, validación de schemas JSON y captura de tokens dinámicos.

### 3.3. Documento de Arquitectura de Seguridad
- 📄 Ubicación: [`docs/ARQUITECTURA_SEGURIDAD.md`](docs/ARQUITECTURA_SEGURIDAD.md)
- Detalla:
  - Flujo de autenticación sin estado (*Stateless Session Management*).
  - Algoritmo de firma digital JWT (HMAC-SHA256).
  - Jerarquía y matriz de roles RBAC.
  - Gestión segura de contraseñas con **BCrypt** (cost factor 10).
  - Manejo de excepciones de seguridad (`AuthEntryPointJwt`, `AccessDeniedException`).

### 3.4. Documentación de la API REST
- 📄 Ubicación: [`docs/DOCUMENTACION_API.md`](docs/DOCUMENTACION_API.md) y [`docs/DOCUMENTACION_BACKEND.md`](docs/DOCUMENTACION_BACKEND.md)
- Detalla los endpoints, métodos HTTP, parámetros de consulta, bodies de petición, ejemplos de respuestas exitosas y errores controlados.

---

## ⚡ 4. Instrucciones de Ejecución Rápida

### Paso 1: Iniciar el Backend
En una terminal:
```powershell
cd apexfit/apexfit-backend
.\mvnw spring-boot:run
```
> El backend quedará escuchando en: `http://localhost:8080/api/v1`

### Paso 2: Ejecutar la Suite de Pruebas Automatizadas con Newman
En otra terminal, dentro de la carpeta `entrega3`:
```powershell
cd entrega3
.\run_postman_tests.ps1
```
*(O de forma directa mediante npx):*
```bash
npx -y newman run postman_collections/ApexFit_JWT_Security.postman_collection.json -e postman_environments/ApexFit_Local.postman_environment.json --delay-request 50 --reporters cli
```

---

## 👥 5. Repositorio Oficial del Proyecto
- **GitHub:** [https://github.com/josedavidortegabarrios9-code/apexfit](https://github.com/josedavidortegabarrios9-code/apexfit)
- **Rama:** `main`

