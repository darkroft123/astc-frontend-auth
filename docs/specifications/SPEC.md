========================================================
FRONTEND DE AUTENTICACIÓN - ESPECIFICACIÓN TÉCNICA
SISTEMA ASTC
========================================================

1. DESCRIPCIÓN GENERAL
--------------------------------------------------------
El frontend de autenticación es el punto de entrada del sistema ASTC.

Su función principal es autenticar usuarios mediante el servicio
de autenticación (auth-service), obtener un token JWT válido y
redirigir al usuario al módulo correspondiente según su rol.

Este frontend NO contiene lógica de negocio.
Actúa únicamente como capa de presentación y enrutamiento.

Este componente es crítico porque representa el acceso inicial
a todo el ecosistema del sistema distribuido.
========================================================


2. RESPONSABILIDADES DEL SISTEMA
--------------------------------------------------------
El frontend de autenticación es responsable de:

- Mostrar la pantalla de inicio de sesión
- Capturar credenciales del usuario (email y contraseña)
- Enviar las credenciales al auth-service mediante GraphQL
- Recibir un token JWT válido
- Almacenar el token de forma segura en el cliente
- Decodificar el JWT para obtener información del usuario
- Redirigir al usuario según su rol

Roles y redirección:

- ADMIN → Backoffice (panel administrativo)
- PROJECT_MANAGER → Panel de gestión de proyectos
- TEAM_MEMBER → Sistema de asistencia


========================================================
3. FLUJO DE AUTENTICACIÓN
--------------------------------------------------------
El flujo completo del sistema es el siguiente:

1. El usuario ingresa sus credenciales en el formulario
2. El frontend envía una mutación GraphQL al auth-service
3. El auth-service valida las credenciales en la base de datos
4. Si son correctas, genera un token JWT firmado
5. El frontend recibe el token JWT
6. El token es almacenado en el cliente
7. Se decodifica el token para obtener el rol del usuario
8. Se redirige al módulo correspondiente según el rol

Este flujo es completamente stateless (sin sesiones en servidor).
========================================================


4. INTEGRACIÓN CON EL BACKEND
--------------------------------------------------------
Servicio utilizado:
- auth-service (GraphQL API)

Endpoint:
- http://auth-service:8082/graphql

Mutación utilizada:

mutation Login($email: String!, $password: String!) {
  login(email: $email, password: $password)
}

El backend responde con un JWT firmado con RS256.
========================================================


5. MANEJO DEL TOKEN JWT
--------------------------------------------------------
El token JWT es el mecanismo principal de autenticación.

Almacenamiento:
- Desarrollo: localStorage
- Producción recomendada: cookie httpOnly segura

Uso del token:

Authorization: Bearer <token>

Contenido del token:

- sub → ID del usuario
- email → correo electrónico
- role → rol del sistema (ADMIN / PM / TEAM_MEMBER)
- iat → fecha de emisión
- exp → fecha de expiración

El frontend nunca modifica el contenido del token.
========================================================


6. LÓGICA DE ENRUTAMIENTO POR ROLES
--------------------------------------------------------
El sistema de redirección funciona de la siguiente manera:

- ADMIN
  → /backoffice

- PROJECT_MANAGER
  → /pm/dashboard

- TEAM_MEMBER
  → /assistance

Si el token no contiene un rol válido:
→ Se redirige automáticamente al login
========================================================


7. ESPECIFICACIÓN DE INTERFAZ DE USUARIO
--------------------------------------------------------
La pantalla de login debe contener:

- Campo de correo electrónico
- Campo de contraseña
- Botón de inicio de sesión
- Indicador de carga (loading state)
- Mensaje de error

Comportamiento:

- El botón se desactiva durante la petición
- Se muestra indicador de carga mientras se autentica
- Los errores se muestran de forma clara al usuario
- Los errores desaparecen al modificar los campos
========================================================


8. REGLAS DE SEGURIDAD
--------------------------------------------------------
- No se almacenan contraseñas en el frontend
- El token JWT no debe ser expuesto en logs
- El acceso a módulos depende exclusivamente del JWT
- No se permite navegación sin token válido
- El token debe validarse antes de cualquier redirección

El frontend no valida credenciales, solo las transmite.
========================================================


9. MANEJO DE ERRORES
--------------------------------------------------------
Códigos de error esperados:

- AUTH_INVALID_CREDENTIALS
  → Usuario o contraseña incorrectos

- AUTH_USER_NOT_FOUND
  → Usuario no existe

- NETWORK_ERROR
  → Error de conexión con el servidor

- SERVER_ERROR
  → Error interno del sistema

Todos los errores deben ser manejados de forma amigable
para el usuario final.
========================================================


10. VARIABLES DE ENTORNO
--------------------------------------------------------
VITE_AUTH_SERVICE_URL=http://localhost:3010

Esta variable define el endpoint del servicio de autenticación (Better Auth Service).

Puerto mapeado: 3003:3000
========================================================


11. USUARIOS DE PRUEBA
--------------------------------------------------------
Usuarios disponibles desde el backend:

- admin@astc.com → ADMIN
- pm@astc.com → PROJECT_MANAGER
- user@astc.com → TEAM_MEMBER
========================================================


12. INTEGRACIÓN CON EL SISTEMA GENERAL
--------------------------------------------------------
Este frontend depende exclusivamente del auth-service.

No tiene comunicación directa con:

- assistance-service
- backoffice-service
- project-service

Toda la autenticación es centralizada en el auth-service.
========================================================


13. ARQUITECTURA GENERAL DEL FLUJO
--------------------------------------------------------
FLUJO COMPLETO DEL SISTEMA:

FRONTEND LOGIN
        ↓
AUTH SERVICE (VALIDACIÓN + JWT)
        ↓
TOKEN JWT
        ↓
DECODIFICACIÓN EN FRONTEND
        ↓
DECISIÓN POR ROLES
        ↓
REDIRECCIÓN A MÓDULOS:

- BACKOFFICE (ADMIN)
- ASSISTANCE (TEAM_MEMBER)
- PROJECT (PROJECT_MANAGER)
========================================================


14. CARACTERÍSTICAS TÉCNICAS
--------------------------------------------------------
- SPA (Single Page Application)
- Consumo de GraphQL
- Arquitectura desacoplada del backend
- Stateless authentication
- Basado en JWT
========================================================


15. REGLAS CRÍTICAS DEL SISTEMA
--------------------------------------------------------
- Este es el único punto de entrada del sistema
- Sin JWT no existe acceso a módulos internos
- No se permite bypass de autenticación
- El frontend no contiene lógica de negocio
========================================================


FIN DEL DOCUMENTO
========================================================