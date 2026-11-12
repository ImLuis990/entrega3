# Arquitectura de Seguridad y Control de Acceso — ApexFit API
**Proyecto de Aula FullStack — Entrega 3 (Semana 8)**  
**Tecnologías:** Spring Boot 3 / Spring Security 6 · JSON Web Token (JWT) · MySQL · AWS RDS  

---

## 1. Visión General de la Seguridad

ApexFit implementa una arquitectura de seguridad **Stateless (sin estado)** basada en estándares modernos de la industria, desacoplando la capa de autenticación de las sesiones tradicionales de servidor (`SessionCreationPolicy.STATELESS`). Cada petición HTTP entrante es autenticada de manera independiente mediante un token **JWT (JSON Web Token)** transmitido en la cabecera `Authorization: Bearer <token>`.

```
[ Cliente / Frontend Angular / Postman ]
                   │
                   │ 1. POST /api/v1/auth/login {correo, contrasena}
                   ▼
       [ AuthController / Spring Security ]
                   │
                   │ 2. Autenticación DaoAuthenticationProvider (BCrypt)
                   │ 3. Generación de Token JWT firmado (HMAC-SHA256)
                   ▼
[ Retorno de Token JWT + Roles + ID Usuario ]
                   │
                   │ 4. Peticiones subsiguientes: Header "Authorization: Bearer <token>"
                   ▼
         [ AuthTokenFilter ] ── Valida firma, expiración y extrae usuario/roles
                   │
                   ▼
      [ Spring Security Context ] ── Establece Authentication
                   │
                   ▼
  [ Controladores con @PreAuthorize ] ── Valida RBAC (Rol requerido)
         ├── 200/201 OK si cumple rol
         └── 403 Forbidden si rol insuficiente
```

---

## 2. Componentes del Núcleo de Seguridad

| Componente | Clase / Archivo | Responsabilidad |
|---|---|---|
| **Filtro de Token** | `AuthTokenFilter.java` | Intercepta cada solicitud, extrae el token del header `Authorization`, valida su integridad criptográfica y establece el contexto de seguridad (`SecurityContextHolder`). |
| **Utilidad JWT** | `JwtUtils.java` | Encargada de firmar tokens mediante `io.jsonwebtoken`, validar tiempo de expiración (24h) y extraer el *subject* (correo del usuario). |
| **Servicio de Carga** | `UserDetailsServiceImpl.java` | Consulta la base de datos por correo electrónico para cargar los datos del usuario y sus roles asignados. |
| **Punto de Entrada (401)** | `AuthEntryPointJwt.java` | Captura peticiones no autenticadas o con token inválido/expirado, retornando un JSON estructurado con status `401 Unauthorized`. |
| **Encriptador de Claves** | `BCryptPasswordEncoder` | Encripta las contraseñas antes de almacenarlas en MySQL (`contrasena_hash`), con salt aleatorio para evitar ataques por diccionario o arcoíris. |
| **Manejo de Excepciones** | `GlobalExceptionHandler.java` | Captura `AccessDeniedException` (retorna `403 Forbidden`) y `BadCredentialsException` (retorna `401 Unauthorized`) de forma estandarizada. |

---

## 3. Control de Acceso Basado en Roles (RBAC)

El sistema define tres roles jerárquicos almacenados en la tabla `rol` de MySQL:
1. `ROLE_ADMINISTRADOR`: Máximo nivel de privilegios. Gestión de usuarios, membresías, asignaciones y auditoría general.
2. `ROLE_ENTRENADOR`: Personal deportivo. Creación de rutinas, registro de ejercicios, alertas y seguimiento a clientes asignados.
3. `ROLE_CLIENTE`: Usuario final del gimnasio. Consulta de sus rutinas asignadas, registro de asistencias mediante QR, registro de métricas de progreso personal y consulta de alertas.

### Matriz de Permisos por Endpoint

| Endpoint | Método | Acción | Roles Permitidos | Código Si Denegado |
|---|---|---|---|---|
| `/api/v1/auth/**` | POST | Login y Registro | **Público** (Sin autenticación) | N/A |
| `/api/v1/usuarios` | GET | Listado paginado de usuarios | `ADMINISTRADOR`, `ENTRENADOR` | `403 Forbidden` |
| `/api/v1/usuarios/{id}` | GET | Ver detalle de usuario | `ADMINISTRADOR`, `ENTRENADOR`, `CLIENTE` | `403 Forbidden` |
| `/api/v1/usuarios` | POST | Crear usuario directamente | `ADMINISTRADOR` | `403 Forbidden` |
| `/api/v1/usuarios/{id}` | DELETE | Borrado lógico de usuario | `ADMINISTRADOR` | `403 Forbidden` |
| `/api/v1/ejercicios` | POST | Crear nuevo ejercicio | `ADMINISTRADOR`, `ENTRENADOR` | `403 Forbidden` |
| `/api/v1/ejercicios` | GET | Listar ejercicios del catálogo | `ADMINISTRADOR`, `ENTRENADOR`, `CLIENTE` | `401 Unauthorized` |
| `/api/v1/ejercicios/{id}` | DELETE | Eliminar ejercicio | `ADMINISTRADOR`, `ENTRENADOR` | `403 Forbidden` |
| `/api/v1/rutinas` | POST | Crear rutina | `ADMINISTRADOR`, `ENTRENADOR` | `403 Forbidden` |
| `/api/v1/rutinas/cliente/{id}` | GET | Consultar rutinas de un cliente | `ADMINISTRADOR`, `ENTRENADOR`, `CLIENTE` | `401 / 403` |
| `/api/v1/membresias` | POST | Registrar o renovar membresía | `ADMINISTRADOR` | `403 Forbidden` |
| `/api/v1/membresias/usuario/{id}` | GET | Consultar membresía activa | `ADMINISTRADOR`, `CLIENTE` | `403 Forbidden` |
| `/api/v1/asistencias` | POST | Registrar ingreso al gimnasio | `ADMINISTRADOR`, `CLIENTE` | `401 Unauthorized` |
| `/api/v1/asistencias` | GET | Auditoría global de asistencias | `ADMINISTRADOR` | `403 Forbidden` |
| `/api/v1/progresos` | POST | Registrar medición física | `ADMINISTRADOR`, `ENTRENADOR`, `CLIENTE` | `401 Unauthorized` |
| `/api/v1/alertas` | POST | Generar alerta al cliente | `ADMINISTRADOR`, `ENTRENADOR` | `403 Forbidden` |
| `/api/v1/entrenador-cliente` | POST | Asignar cliente a entrenador | `ADMINISTRADOR` | `403 Forbidden` |

---

## 4. Estándar de Respuesta de Errores

Para garantizar que los clientes REST (Angular, Postman) interpreten los errores sin ambigüedad, el backend estandariza las respuestas de seguridad:

### 4.1. Error 401 Unauthorized (Sin Token / Token Expirado)
```json
{
  "status": 401,
  "error": "Unauthorized",
  "message": "Error: No autorizado. Token ausente, invalido o expirado."
}
```

### 4.2. Error 403 Forbidden (Rol Insuficiente / RBAC)
```json
{
  "timestamp": "2026-10-12T20:30:15.123",
  "status": 403,
  "error": "Forbidden",
  "message": "Acceso denegado: No cuenta con los roles o permisos requeridos para esta operación.",
  "validationErrors": null
}
```

### 4.3. Error 400 Bad Request (Fallo de Validación Bean Validation)
```json
{
  "timestamp": "2026-10-12T20:30:15.123",
  "status": 400,
  "error": "Validation Error",
  "message": "Uno o más campos tienen errores de validación",
  "validationErrors": {
    "correo": "El correo electrónico debe ser válido",
    "contrasena": "La contraseña debe tener mínimo 6 caracteres"
  }
}
```

---

## 5. Verificación y Pruebas Automatizadas

La arquitectura de seguridad está verificada de punta a punta a través de la suite de pruebas de Postman:
- **Prueba 11.1:** Solicitud GET a `/api/v1/ejercicios` sin cabecera `Authorization` → Verifica respuesta `401 Unauthorized`.
- **Prueba 11.2:** Token con rol `ROLE_CLIENTE` intentando crear un ejercicio vía POST `/api/v1/ejercicios` → Verifica respuesta `403 Forbidden`.
- **Prueba 11.3:** Token con rol `ROLE_CLIENTE` intentando registrar membresía vía POST `/api/v1/membresias` → Verifica respuesta `403 Forbidden`.
- **Prueba 11.4:** Token con rol `ROLE_ENTRENADOR` intentando eliminar un usuario vía DELETE `/api/v1/usuarios/1` → Verifica respuesta `403 Forbidden`.
- **Pruebas 1.4 a 1.6:** Autenticación exitosa y extracción automática de tokens diferenciados (`token_admin`, `token_entrenador`, `token_cliente`).
