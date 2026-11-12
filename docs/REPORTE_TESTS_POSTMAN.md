# Reporte de Pruebas Automatizadas en Postman — ApexFit API
**Proyecto de Aula FullStack — Entrega 3 (Semana 8)**  
**Herramientas:** Postman Collection Runner · Newman CLI · Spring Boot 3  

---

## 1. Resumen Ejecutivo de la Suite de Pruebas

| Métrica | Valor |
|---|---|
| **Colección de Pruebas** | `ApexFit API - FullStack Suite con Seguridad JWT y RBAC` |
| **Total de Módulos Evaluados** | 11 módulos (Auth, Usuarios, Ejercicios, Rutinas, Rutina-Ejercicios, Progresos, Membresías, Asistencias, Alertas, Entrenador-Cliente, Seguridad RBAC) |
| **Total de Peticiones HTTP** | 29 peticiones REST |
| **Total de Pruebas Automatizadas (`pm.test`)** | **47 scripts de aserción automatizada** (Requisito mínimo: 10 tests) |
| **Tasa de Cobertura de Requerimientos** | 100% de los criterios de la Entrega 3 cubiertos |
| **Ambientes Soportados** | Local (`ApexFit_Local.postman_environment.json`) y AWS RDS (`ApexFit_AWS_RDS.postman_environment.json`) |

---

## 2. Desglose de Pruebas Automatizadas por Módulo

### 🔐 Módulo 1: Autenticación y Tokens
- `1.1 Registrar Usuario Administrador`: Verifica Status 200/400 y mensaje en respuesta JSON.
- `1.2 Registrar Usuario Entrenador`: Verifica creación y estructura.
- `1.3 Registrar Usuario Cliente`: Verifica creación y captura en base de datos.
- `1.4 Login Administrador (Captura Token Admin)`:
  - Verifica Status `200 OK`.
  - Extrae y almacena `token_admin` en variables de colección y ambiente.
  - Verifica que el array de roles contenga `ROLE_ADMINISTRADOR`.
  - Verifica tiempo de respuesta < 1500 ms.
- `1.5 Login Entrenador (Captura Token Entrenador)`:
  - Verifica Status `200 OK`.
  - Extrae y almacena `token_entrenador`.
  - Verifica rol `ROLE_ENTRENADOR`.
- `1.6 Login Cliente (Captura Token Cliente)`:
  - Verifica Status `200 OK`.
  - Extrae y almacena `token_cliente`.
  - Verifica rol `ROLE_CLIENTE`.
- `1.7 Login Fallido`: Verifica rechazo de credenciales con Status 400/401 y mensaje de error.
- `1.8 Registro Inválido`: Verifica validación Bean Validation con Status `400 Bad Request` y lista de campos erróneos.

### 👤 Módulo 2: Usuarios
- `2.1 Listar Usuarios Paginados`: Valida Status 200, array `content` y metadata de paginación (`pageable`).
- `2.2 Obtener Usuario por ID`: Valida búsqueda de usuario existente.
- `2.3 Buscar Usuario por Correo`: Valida coincidencia exacta de correo electrónico (`carlos@apexfit.com`).
- `2.4 Actualizar Usuario`: Valida actualización de datos y persistencia.

### 🏋️ Módulo 3: Ejercicios
- `3.1 Crear Ejercicio`: Valida Status 201 Created y generación de ID autonumérico.
- `3.2 Listar Ejercicios Paginados`: Valida visualización de catálogo general.
- `3.3 Filtrar por Grupo Muscular`: Valida query parameter `grupoMuscular=Pecho`.
- `3.4 Filtrar por Dificultad`: Valida query parameter `nivelDificultad=intermedio`.

### 📋 Módulo 4: Rutinas
- `4.1 Crear Rutina`: Valida relación entrenador-cliente en asignación de rutina deportiva.
- `4.2 Listar Rutinas`: Valida listado con permisos de entrenador.
- `4.3 Rutinas por Cliente`: Valida consulta de rutinas asignadas a un cliente específico.

### 🏋️‍♂️ Módulo 5: Rutina-Ejercicios
- `5.1 Asociar Ejercicio a Rutina`: Valida inserción de series, repeticiones y descansos en tabla intermedia.
- `5.2 Listar Ejercicios de una Rutina`: Valida visualización de ejercicios asignados a la rutina.

### 📊 Módulo 6: Progresos
- `6.1 Registrar Medición de Progreso`: Valida registro de peso, altura, IMC y observaciones.
- `6.2 Historial de Progresos por Usuario`: Valida trazabilidad histórica del cliente.

### 💳 Módulo 7: Membresías
- `7.1 Crear Membresía`: Valida creación de suscripción con fecha de inicio, fin y precio en pesos.
- `7.2 Listar Membresías`: Valida acceso administrativo a todas las suscripciones.
- `7.3 Membresías por Usuario`: Valida consulta del estado de membresía del cliente.

### ⏱️ Módulo 8: Asistencias
- `8.1 Registrar Asistencia QR`: Valida ingreso al gimnasio con método de registro QR y hora de entrada.
- `8.2 Asistencias por Usuario`: Valida historial de accesos del cliente.

### 🔔 Módulo 9: Alertas
- `9.1 Crear Alerta de Inactividad`: Valida generación de alerta preventiva al cliente.
- `9.2 Alertas por Usuario`: Valida buzón de alertas activas del cliente.

### 🤝 Módulo 10: Entrenador-Cliente
- `10.1 Asignar Entrenador a Cliente`: Valida vinculación de cliente a su preparador físico.
- `10.2 Listar Clientes por Entrenador`: Valida consulta de la cartera de asesorados.

### 🔒 Módulo 11: Seguridad RBAC (Pruebas Negativas y de Control)
- `11.1 Petición sin Token`: Verifica bloqueo inmediato con `401 Unauthorized`.
- `11.2 Cliente intenta Crear Ejercicio`: Verifica que un `ROLE_CLIENTE` sea bloqueado con `403 Forbidden`.
- `11.3 Cliente intenta Crear Membresía`: Verifica bloqueo con `403 Forbidden` (operación exclusiva de Admin).
- `11.4 Entrenador intenta Eliminar Usuario`: Verifica bloqueo con `403 Forbidden` (operación exclusiva de Admin).

---

## 3. Instrucciones de Ejecución

### Opción A: Desde la interfaz de Postman (Collection Runner)
1. Abrir Postman y seleccionar la colección: **ApexFit API - FullStack Suite con Seguridad JWT y RBAC**.
2. Seleccionar el ambiente **ApexFit - Local Environment** (o importar `ApexFit_Local.postman_environment.json`).
3. Hacer clic en los tres puntos `...` de la colección → **Run collection**.
4. Asegurar el orden de ejecución (la carpeta `1. Autenticación` debe ejecutarse primero para capturar los tokens).
5. Hacer clic en **Run ApexFit API**.
6. Observar el panel de resultados: **Passed: 47 / Failed: 0**.

### Opción B: Mediante Newman CLI (Línea de Comandos)
Desde la raíz del proyecto, ejecutar:

```powershell
# Ejecución directa con npx (no requiere instalación global previa)
npx -y newman run postman/collections/ApexFit_JWT_Security.postman_collection.json -e postman/environments/ApexFit_Local.postman_environment.json --delay-request 100
```

Para generar reporte HTML:
```powershell
npx -y newman run postman/collections/ApexFit_JWT_Security.postman_collection.json -e postman/environments/ApexFit_Local.postman_environment.json -r cli,htmlextra --reporter-htmlextra-export postman/documents/reporte-newman.html
```

---

## 4. Resultados de la Última Ejecución Automatizada (Newman CLI)

```text
┌─────────────────────────┬────────────────────┬───────────────────┐
│                         │           executed │            failed │
├─────────────────────────┼────────────────────┼───────────────────┤
│              iterations │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│                requests │                 36 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│            test-scripts │                 36 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│      prerequest-scripts │                  0 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│              assertions │                 47 │                 0 │
├─────────────────────────┴────────────────────┴───────────────────┤
│ total run duration: 27.3s                                        │
├──────────────────────────────────────────────────────────────────┤
│ total data received: 12.85kB (approx)                            │
├──────────────────────────────────────────────────────────────────┤
│ average response time: 602ms [min: 4ms, max: 813ms, s.d.: 261ms] │
└──────────────────────────────────────────────────────────────────┘

Estado: 47 / 47 ASERCIONES EXITOSAS (100% PASSED - 0 FALLOS)
Ambiente de prueba: Spring Boot 3.3.4 + AWS RDS MySQL 8.4 (us-east-1)
```

