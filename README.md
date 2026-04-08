# Infraestructura Microservices Voting App

Repositorio de infraestructura y configuración para la aplicación de votación basada en microservicios.

## Tabla de Contenidos

- [Descripción](#descripción)
- [Metodología Ágil](#metodología-ágil)
- [Estrategia de Branching](#estrategia-de-branching)
  - [Branching para Desarrollo](#1-branching-para-desarrollo)
  - [Branching para Operaciones](#2-branching-para-operaciones)
- [Patrones de Diseño en la Nube](#patrones-de-diseño-en-la-nube)
  - [Patrón Retry](#patrón-1-retry)
  - [Patrón Rate Limiting](#patrón-2-rate-limiting)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Tecnologías](#tecnologías)

---

## Descripción

Este proyecto implementa la infraestructura como código (IaC) y las configuraciones necesarias para desplegar y gestionar una aplicación de votación basada en microservicios, siguiendo las mejores prácticas de DevOps y arquitectura de nube.

---

## Metodología Ágil

**Metodología seleccionada:** Scrum

- Sprints cortos con duración definida
- Planificación semanal de tareas
- Revisión al final de cada sprint
- Retrospectiva para mejora continua
- Entregas incrementales y frecuentes

---

## Estrategia de Branching

### 1. Branching para Desarrollo

**Enfoque:** Trunk-Based Development ligero (ideal para equipos ágiles y entregas frecuentes)

#### Ramas principales

- **`main`**: Siempre estable, lista para producción
- **`develop`**: (Opcional) Ambiente de integración antes de pasar a `main`

#### Ramas de trabajo

- **`feature/<nombre-corto>`**: Nuevas funcionalidades
- **`bugfix/<nombre-corto>`**: Correcciones de bugs
- **`hotfix/<nombre-corto>`**: Arreglos urgentes de producción

#### Flujo de trabajo

1. Crear rama `feature/*` desde `develop` (o `main` si no se usa `develop`)
2. Realizar commits pequeños y frecuentes
3. Abrir Pull Request (PR) obligatorio que incluya:
   - Al menos 1 revisión de código
   - Tests y linters en verde (CI pasando)
4. Merge con **squash** para mantener historial limpio
5. Releases se etiquetan en `main` con formato `vX.Y.Z`

#### Reglas y protecciones

**Protección de rama `main`:**

- No push directo
- PR obligatorio
- Checks de CI obligatorios

**Convención de commits:**

- `feat: ...` - Nueva funcionalidad
- `fix: ...` - Corrección de bug
- `chore: ...` - Tareas de mantenimiento
- `docs: ...` - Documentación

**Validaciones automáticas en PR:**

- Linters (código limpio)
- Tests unitarios e integración
- Build exitoso

---

### 2. Branching para Operaciones

**Enfoque:** GitOps - La configuración de infraestructura separada del código de aplicación

Se recomienda un repositorio dedicado para infraestructura (ej: `microservices-demo-infra`)

#### Ramas de infraestructura

- **`infra/main`**: Estado real de producción
- **`infra/staging`**: Estado de pre-producción
- **`infra/feature/<cambio>`**: Cambios de IaC (Terraform/Helm/K8s manifests)

#### Flujo operativo GitOps

1. Crear cambio en rama `infra/feature/*`
2. Abrir PR hacia `infra/staging` con validaciones:
   - `terraform fmt` / `helm lint`
   - `terraform validate`
   - `terraform plan`
   - Policy checks (seguridad, costos)
3. **Aprobado** → Merge a `infra/staging` → Despliegue automático a staging
4. **Validación en staging** → PR de `infra/staging` a `infra/main`
5. **Aprobado** → Merge a `infra/main` → Despliegue automático a producción (con aprobación manual)

#### Reglas clave de operaciones

- **Cero cambios manuales** en producción (todo por Git)
- **Locks de estado** (Terraform backend remoto - S3/GCS)
- **Secrets seguros** (GitHub Secrets / Vault / AWS SSM), nunca en texto plano
- **Inmutabilidad**: cada cambio genera nueva versión
- **Auditoría completa** mediante historial de Git

---

## Patrones de Diseño en la Nube

### Patrón 1: Retry

**Problema que resuelve:**  
Fallos transitorios entre microservicios (timeouts, errores 5xx, picos de red) que pueden resolverse con reintentos automáticos.

#### Implementación

Configuración en llamadas HTTP/gRPC entre servicios:

```yaml
retry:
  maxRetries: 3
  backoff: exponential # 200ms, 400ms, 800ms
  jitter: true # Aleatorio para evitar thundering herd
  retryableErrors:
    - 429 # Too Many Requests
    - 502 # Bad Gateway
    - 503 # Service Unavailable
    - 504 # Gateway Timeout
```

#### Buenas prácticas

- **Reintentar** errores transitorios (429, 502, 503, 504)
- **No reintentar** errores funcionales (400, 401, 403, 404)
- Definir **timeout por request** para evitar bloqueos
- Combinar con **circuit breaker** para mayor resiliencia
- **Monitorear** tasa de reintentos y ajustar según sea necesario

#### Justificación

> "Implementamos el patrón Retry con backoff exponencial y jitter para mejorar la resiliencia ante fallos temporales de red o servicios, reduciendo errores intermitentes tanto en el pipeline de despliegue como en tiempo de ejecución."

---

### Patrón 2: Rate Limiting

**Problema que resuelve:**  
Sobrecarga del sistema, abuso de APIs, cascadas de fallos y degradación del servicio por exceso de tráfico.

#### Implementación

**Ubicación:** API Gateway / Ingress Controller (Nginx/Traefik/Envoy)  
**Opcional:** Por servicio crítico (checkout/payment)

```yaml
rateLimit:
  requestsPerMinute: 100 # Por IP
  burst: 20 # Ráfaga permitida
  errorResponse: 429 # Too Many Requests
```

#### Política inicial

| Endpoint       | Límite      | Burst | Respuesta |
| -------------- | ----------- | ----- | --------- |
| `/api/*`       | 100 req/min | 20    | 429       |
| `/api/payment` | 50 req/min  | 10    | 429       |
| `/health`      | Sin límite  | -     | -         |

#### Buenas prácticas

- **Excluir health checks** del límite
- **Límites por ambiente** (staging más flexible que producción)
- **Monitorear métricas** de 429 para ajustar umbrales
- **Diferenciación** por usuario/API key (si aplica)
- **Headers informativos** (X-RateLimit-Limit, X-RateLimit-Remaining)

#### Justificación

> "Aplicamos Rate Limiting para proteger la plataforma contra picos de tráfico y uso abusivo, manteniendo la disponibilidad y estabilidad del clúster. Esto previene la degradación del servicio para usuarios legítimos."

---

## Estructura del Proyecto

```
infra-microservice-voting-app/
├── README.md                 # Este archivo
├── infrastructure/           # Configuraciones de IaC
│   ├── terraform/           # Terraform configs
├── environments/            # Configuraciones por ambiente
│   ├── staging/
│   └── production/
├── .github/                 # GitHub Actions workflows
│   └── workflows/
│       ├── ci-dev.yml       # CI para desarrollo
│       └── cd-infra.yml     # CD para infraestructura
└── docs/                    # Documentación adicional
```

---

## Tecnologías

### Infraestructura y Cloud

- **Docker**: Containerización de microservicios para garantizar consistencia entre entornos
- **AWS (Amazon Web Services)**: Proveedor de nube para hosting y servicios gestionados
  - EC2: Instancias de cómputo
  - VPC: Red virtual privada
  - ECS/EKS: Orquestación de contenedores
  - RDS: Bases de datos gestionadas
  - S3: Almacenamiento de objetos y state de Terraform
  - CloudWatch: Monitoreo y logs
- **Terraform**: Infraestructura como Código (IaC) para provisionar y gestionar recursos de AWS
- **Git + GitHub**: Control de versiones y repositorio remoto
- **GitHub Actions**: CI/CD para automatización de pipelines

### Arquitectura

- **Contenedores Docker**: Empaquetado y despliegue de aplicaciones
- **Docker Compose**: Orquestación local para desarrollo
- **Microservicios**: Arquitectura distribuida y escalable

---
