# Frontend Auth (Login UI)

Frontend de autenticación - punto de entrada del sistema ASTC.

## Stack Tecnológico

- React 18 + TypeScript
- Vite (bundler)
- TailwindCSS
- GraphQL Client (Apollo)

## Descripción

El frontend de autenticación es el punto de entrada del sistema ASTC. Su función es:

- Mostrar la pantalla de inicio de sesión
- Capturar credenciales del usuario (email y contraseña)
- Enviar credenciales al auth-service mediante GraphQL
- Recibir y almacenar el token JWT
- Redirigir al usuario según su rol

**Este frontend NO contiene lógica de negocio.** Actúa únicamente como capa de presentación.

## Flujo de Autenticación

```
1. Usuario ingresa credenciales
2. Frontend envía mutación GraphQL al auth-service
3. Auth-service valida credenciales
4. Si son correctas → genera token JWT firmado
5. Frontend recibe y almacena el token
6. Decodifica el JWT para obtener el rol
7. Redirige al módulo correspondiente:
   - ADMIN → /backoffice
   - PROJECT_MANAGER → /pm/dashboard
   - TEAM_MEMBER → /assistance
```

## Estructura

```
src/
├── components/       # Componentes UI (LoginForm, etc.)
├── services/         # Servicios GraphQL
├── hooks/            # Custom hooks
├── pages/            # Páginas/rutas
└── utils/            # Utilidades (JWT decode, etc.)
```

## Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `VITE_AUTH_SERVICE_URL` | Endpoint del auth-service | `http://localhost:8082/graphql` |

## Ejecución Local

```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Puerto: 3003 (configurado en docker-compose)
```

## Mutación GraphQL Utilizada

```graphql
mutation Login($email: String!, $password: String!) {
  login(email: $email, password: $password) {
    token
    user {
      id
      email
      role
    }
  }
}
```

## Manejo del Token JWT

| Claim | Descripción |
|-------|-------------|
| `sub` | ID del usuario |
| `email` | Correo electrónico |
| `role` | Rol del sistema |
| `iat` | Fecha de emisión |
| `exp` | Fecha de expiración |

## Rutas por Rol

| Rol | Redirección |
|-----|-------------|
| ADMIN | `/backoffice` |
| PROJECT_MANAGER | `/pm/dashboard` |
| TEAM_MEMBER | `/assistance` |

## Seguridad

- No almacena contraseñas en el frontend
- El token JWT no debe ser expuesto en logs
- El acceso a módulos depende exclusivamente del JWT
- No se permite navegación sin token válido

## Docker

```bash
# Puerto mapeado: 3003:3000
docker compose up -d frontend-auth
```

## Integraciones

- **auth-service**: Único servicio del que depende
- **No tiene comunicación directa** con assistance-service, backoffice-service ni project-service
