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

## Authentication & Authorization

### Overview

The full profile supports OAuth2/LDAP authentication through Kustvakt backend. Authentication is **optional** and controlled via the `full.superClientInfoSecretName` setting.

- **With Auth Secret**: Kalamar loads the Auth plugin and enables login via OAuth2/LDAP
- **Without Auth Secret**: Full profile runs without Auth plugin; anonymous access only

### Setting Up Authentication

#### 1. Create super_client_info File

Create a JSON file with OAuth2 client credentials:

```json
{
  "client_id": "korap-client",
  "client_secret": "your-secret-key-here",
  "scope": "read write",
  "redirect_uri": "http://localhost:64543/oauth2/callback",
  "response_type": "code",
  "grant_type": "authorization_code"
}
```

See [Kustvakt Documentation](https://github.com/KorAP/Kustvakt/wiki) for all available options.

#### 2. Create Kubernetes Secret

```bash
kubectl create secret generic korap-super-client \
  --from-file=super_client_info=./super_client_info \
  -n korap
```

#### 3. Deploy Full Profile with Auth

```bash
helm install korap ./korap \
  --namespace korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true \
  --set 'full.superClientInfoSecretName=korap-super-client' \
  --set 'full.dataVolume.enabled=true'
```

**What This Does:**
1. Mounts the secret into Kalamar at `/kalamar/super_client_info`
2. Automatically enables the KALAMAR_PLUGINS=Auth environment variable
3. Kalamar automatically detects the client file and activates OAuth
4. Users see login button in frontend

### How It Works (Technical Details)

**Environment Variables Set:**
```bash
KALAMAR_API=http://korap-korap-kustvakt-full:8089/api/
KALAMAR_PLUGINS=Auth
KALAMAR_CLIENT_FILE=/kalamar/super_client_info
```

**Volume Mounts:**
- Secret mounted as: `/kalamar/super_client_info`
- Kalamar reads this file on startup
- Auth plugin auto-loads when file is present

**Auth Plugin Disabled When:**
- Secret is not referenced (superClientInfoSecretName is null)
- Environment variables are not set
- No client file is mounted

This is **intentional** - allows full profile to work without authentication if needed.

### Troubleshooting Authentication

**Symptom**: `Can't open file "/kalamar/super_client_info": No such file or directory`

**Causes:**
- `superClientInfoSecretName` is set but secret doesn't exist
- Secret was not created
- Wrong secret name referenced
- Secret not in correct namespace

**Solution:**
```bash
# Verify secret exists
kubectl get secrets -n korap

# Check secret contents
kubectl describe secret korap-super-client -n korap

# Verify correct name in Helm values
helm get values korap -n korap | grep superClientInfo
```

**Symptom**: Auth plugin loads but OAuth fails

**Solution:**
1. Verify client_id, client_secret in super_client_info match your OAuth provider
2. Check redirect_uri matches your Kalamar URL
3. Verify Kustvakt is running and accessible:
   ```bash
   kubectl exec -it deployment/korap-korap-kustvakt-full -n korap -- \
     curl http://localhost:8089/api/
   ```

### Updating Credentials

To update OAuth credentials:

```bash
# Delete old secret
kubectl delete secret korap-super-client -n korap

# Create new secret with updated file
kubectl create secret generic korap-super-client \
  --from-file=super_client_info=./super_client_info \
  -n korap

# Restart Kalamar to reload credentials
kubectl rollout restart deployment/korap-korap-kalamar-full -n korap
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

## Troubleshooting

### Kalamar-Full CrashLoopBackOff - Missing super_client_info

**Error**: `Can't open file "/kalamar/super_client_info": No such file or directory at Kalamar/Plugin/Auth.pm`

**Root Cause**: The Auth plugin tries to load but the secret is not mounted

**Solutions**:

**Option 1: Disable Auth (if you don't need it)**
```bash
# Remove the superClientInfoSecretName setting
helm upgrade korap ./korap \
  --namespace korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true \
  --set 'full.superClientInfoSecretName=' \
  --install
```

**Option 2: Create and Mount the Secret**
```bash
# 1. Create super_client_info file (JSON format)
cat > super_client_info <<EOF
{
  "client_id": "korap",
  "client_secret": "your-secret",
  "redirect_uri": "http://localhost:64543/oauth2/callback"
}
EOF

# 2. Create secret
kubectl create secret generic korap-super-client \
  --from-file=super_client_info=./super_client_info \
  -n korap

# 3. Update deployment
helm upgrade korap ./korap \
  --namespace korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true \
  --set 'full.superClientInfoSecretName=korap-super-client' \
  --install
```

### Verifying Auth Configuration

```bash
# Check if secret exists
kubectl get secrets -n korap | grep super-client

# View secret content (base64 decoded)
kubectl get secret korap-super-client -o jsonpath='{.data.super_client_info}' -n korap | base64 -d

# Check if Kalamar pod can see the file
kubectl exec deployment/korap-korap-kalamar-full -n korap -- \
  ls -la /kalamar/super_client_info

# View Kalamar logs for auth errors
kubectl logs deployment/korap-korap-kalamar-full -n korap | grep -i auth
```

### CrashLoopBackOff with Example Index

**Error**: `CrashLoopBackOff: Last state: Terminated with : Completed`

**Cause**: This is **expected behavior**. Example Index is a Kubernetes Job (not a Deployment) that completes after running successfully.

**Verify Job Status:**
```bash
kubectl get jobs -n korap
kubectl logs job/korap-korap-example-index -n korap
```

Job should show `1/1` completions and status `Completed`.

### Volume AttachVolume.Attach Errors

**Error**: `AttachVolume.Attach failed for volume "pvc-..." : an operation with the given Volume ID already exists`

**Cause**: Old PVC with incompatible access mode (ReadWriteOnce) still exists

**Solution**:
```bash
# Delete old PVC
kubectl delete pvc korap-korap-index -n korap

# Verify storage class supports ReadWriteMany
kubectl get storageclasses

# Redeploy
helm upgrade korap ./korap --namespace korap --install
```

#### Cleanup Stuck PVCs

```bash
# Force delete stuck PVC
kubectl patch pvc korap-korap-index -p '{"metadata":{"finalizers":null}}' -n korap
kubectl delete pvc korap-korap-index -n korap

# Force delete stuck PV
kubectl patch pv <pv-name> -p '{"metadata":{"finalizers":null}}'
kubectl delete pv <pv-name>
```
