# KorAP Helm Chart - Complete Implementation

This Helm chart is a complete conversion of the [KorAP Docker Compose](https://github.com/KorAP/KorAP-Docker/blob/master/compose.yaml) configuration to Kubernetes/Helm.

## Architecture

The chart supports three deployment profiles matching the Docker Compose setup:

### 1. **Lite Profile** (Default)
Minimal KorAP setup with single Kalamar and Kustvakt services.

**Services:**
- `kalamar:latest` - Frontend (port 64543)
- `kustvakt:latest` - Backend API (port 8089)
- Shared PVC for index data

**Usage:**
```bash
helm install korap ./korap --values values-dev.yaml
```

### 2. **Full Profile**
Enterprise setup with authentication, plugins, and separate data volumes.

**Services:**
- `kalamar:latest` + Auth plugin support
- `kustvakt:latest-full` - Full version with LDAP/authentication
- Data volumes for persistent storage
- Initialization job for super_client_info setup
- Optional production configuration

**Usage:**
```bash
helm install korap ./korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true \
  --set 'full.dataVolume.enabled=true' \
  --set 'full.superClientInfoSecretName=my-secret'
```

### 3. **Example Profile**
Optional example index container for testing.

**Usage:**
```bash
helm install korap ./korap --set exampleIndex.enabled=true
```

## Configuration

### Default Values (values.yaml)

```yaml
# Port configuration (matching Docker Compose)
service:
  kalamar:
    port: 64543        # Kalamar UI port
  kustvakt:
    port: 8089         # API port

# Image configuration (using korap/ registry)
kalamar:
  image: korap/kalamar:latest
kustvakt:
  image: korap/kustvakt:latest
kustvaktFull:
  image: korap/kustvakt:latest-full

# Volumes
indexVolume:
  size: 10Gi
  storageClassName: null
  existingClaim: null

# Full profile options
full:
  enabled: false
  dataVolume:
    enabled: false
    mountPath: /kalamar/data
    size: 50Gi
  kustvaktDataVolume:
    enabled: false
    mountPath: /kustvakt/data
    size: 50Gi
  superClientInfoSecretName: null
  kalamarProductionConf:
    enabled: false
    content: ""

# Security context (runs as root for full profile compatibility)
securityContext:
  runAsUser: 0
  runAsGroup: 0
  fsGroup: 0

# Restart policy (matches Docker Compose unless-stopped)
restartPolicy: unless-stopped
```

## Templates

### Core Templates
- **kalamar-deployment.yaml** - Lite Kalamar service
- **kustvakt-deployment.yaml** - Lite Kustvakt service
- **pvc-index.yaml** - Shared index volume
- **serviceaccount.yaml** - Service account for pods
- **ingress.yaml** - Optional ingress configuration
- **_helpers.tpl** - Helper templates

### Full Profile Templates
- **kalamar-full-deployment.yaml** - Full Kalamar with Auth plugin
- **kustvakt-full-deployment.yaml** - Full Kustvakt with LDAP
- **full-init-job.yaml** - Initialization job for super_client_info
- **pvc-data.yaml** - Data volume for lite/full profiles
- **pvc-kustvakt-data.yaml** - Kustvakt data volume

### Optional Templates
- **example-index-deployment.yaml** - Example index container
- **kalamar-configmap.yaml** - Production configuration
- **NOTES.txt** - Deployment notes

## Key Features

✅ **Complete Docker Compose Conversion**
- All services from compose.yaml included
- Port numbers match (Kalamar: 64543, Kustvakt: 8089)
- Image repositories use official `korap/` registry
- Restart policies match Docker Compose behavior

✅ **Profile Support**
- Lite profile (single services)
- Full profile (authenticated, with plugins)
- Example profile (test data)
- Conditional rendering based on enabled flags

✅ **Volume Management**
- Index volume (shared between lite and full)
- Data volume for full profile (Kalamar)
- Kustvakt data volume for full profile
- Support for existing PVCs

✅ **Security**
- Service accounts for pods
- Security context configuration
- Root user support for full profile (matches Docker)
- Secret mounting for super_client_info

✅ **Initialization**
- Full profile init job for super_client_info generation
- Proper job dependencies

✅ **Environment Variables**
- KALAMAR_API configuration
- KALAMAR_PLUGINS (Auth for full profile)
- KALAMAR_CLIENT_FILE path
- Extensible via extraEnv

✅ **Production Ready**
- Helm linting validation
- Defensive template coding (null coalescing)
- ConfigMap for production configuration
- Probes for health checks (Kalamar)

## Deployment Examples

### Basic Lite Deployment
```bash
helm install korap ./korap \
  --namespace korap \
  --create-namespace
```

### Lite with Custom Index
```bash
helm install korap ./korap \
  --namespace korap \
  --set 'indexVolume.existingClaim=my-index-pvc'
```

### Full Deployment with Data
```bash
helm install korap ./korap \
  --namespace korap \
  --values values-full.yaml \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true \
  --set 'full.dataVolume.enabled=true' \
  --set 'full.superClientInfoSecretName=korap-super-client'
```

### With Example Index
```bash
helm install korap ./korap \
  --namespace korap \
  --set exampleIndex.enabled=true \
  --set 'indexVolume.existingClaim=example-index'
```

### With Ingress
```bash
helm install korap ./korap \
  --namespace korap \
  --set 'ingress.enabled=true' \
  --set 'ingress.className=nginx' \
  --set 'ingress.hosts[0].host=korap.example.com' \
  --set 'ingress.hosts[0].paths[0].path=/' \
  --set 'ingress.hosts[0].paths[0].pathType=Prefix'
```

## Comparison with Docker Compose

| Feature | Docker Compose | Helm Chart | Status |
|---------|----------------|-----------|--------|
| Lite profile | ✓ | ✓ | ✅ |
| Full profile | ✓ | ✓ | ✅ |
| Example container | ✓ | ✓ | ✅ |
| Init job | ✓ | ✓ | ✅ |
| Port 64543 | ✓ | ✓ | ✅ |
| Auth plugins | ✓ | ✓ | ✅ |
| Data volumes | ✓ | ✓ | ✅ |
| Security context | ✓ | ✓ | ✅ |
| Restart policy | ✓ | ✓ | ✅ |
| Volume mounts | ✓ | ✓ | ✅ |

## Testing

Validate chart syntax:
```bash
helm lint charts/korap/
```

Render lite profile:
```bash
helm template korap charts/korap/
```

Render full profile:
```bash
helm template korap charts/korap/ \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true
```

# Restart Policy

The chart uses `restartPolicy: Always` for all persistent service deployments (Kalamar and Kustvakt). This is the Kubernetes equivalent of Docker Compose's `unless-stopped` policy - the container will be automatically restarted if it exits.

Supported Kubernetes restart policies:
- **Always** - Restart the container regardless of exit code (used for persistent services)
- **OnFailure** - Restart only on non-zero exit code
- **Never** - Do not restart (used for init containers and one-time jobs)
