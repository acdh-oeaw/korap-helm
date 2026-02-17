# KorAP Helm Chart

This Helm chart is a **production-ready Kubernetes conversion** of the [KorAP Docker Compose](https://github.com/KorAP/KorAP-Docker) deployment.

KorAP (Corpus Analysis Platform) is a modular system consisting of:
- **Kalamar** - Web-based frontend for corpus search and analysis
- **Kustvakt** - Backend API providing authentication, authorization, and policy management
- **Krill** - Index backend (managed via corpus data in attached volumes)

This chart provides flexible, profile-based deployments supporting lite and full configurations.

---

## 🚀 Features

✅ **Complete Docker Compose Conversion**
- All services from the original compose.yaml
- Matching port configuration (Kalamar: 64543, Kustvakt: 8089)
- Correct image repositories (korap/)
- Kubernetes-compatible restart policies

✅ **Profile-Based Deployment**
- **Lite Profile** - Single Kalamar & Kustvakt services (default)
- **Full Profile** - Enterprise setup with authentication plugins, LDAP support, dedicated data volumes
- **Example Profile** - Optional example index container for testing

✅ **Volume Management**
- Shared index volume for lite and full profiles
- Separate data volumes for full profile (Kalamar & Kustvakt)
- Support for existing PVCs or automatic creation

✅ **Production Ready**
- Initialization job for full profile configuration
- Health checks (readiness/liveness probes)
- Security context configuration
- Service accounts
- Optional Ingress support

✅ **Flexible Configuration**
- Extensive values.yaml with 60+ configuration options
- Environment variable support for custom configuration
- Production configuration file support (full profile)

---

## 📦 Chart Structure

```
korap-helm/
├── Chart.yaml
├── values.yaml
├── README.md
├── IMPLEMENTATION.md
└── charts/korap/
    ├── Chart.yaml
    ├── values.yaml
    ├── templates/
    │   ├── _helpers.tpl
    │   ├── serviceaccount.yaml
    │   ├── kalamar-deployment.yaml
    │   ├── kalamar-full-deployment.yaml
    │   ├── kalamar-configmap.yaml
    │   ├── kustvakt-deployment.yaml
    │   ├── kustvakt-full-deployment.yaml
    │   ├── example-index-deployment.yaml
    │   ├── full-init-job.yaml
    │   ├── pvc-index.yaml
    │   ├── pvc-data.yaml
    │   ├── pvc-kustvakt-data.yaml
    │   ├── ingress.yaml
    │   └── NOTES.txt
```

---

## ⚙️ Configuration

All deployment settings are controlled through `values.yaml` in the chart root directory.

### Service Configuration

```yaml
service:
  kalamar:
    port: 64543        # Kalamar web interface port
    type: ClusterIP
  kustvakt:
    port: 8089         # Kustvakt API port
    type: ClusterIP
```

### Volume Configuration

```yaml
indexVolume:
  size: 10Gi
  storageClassName: null    # Use default storage class
  existingClaim: null       # Or use existing PVC

full:
  dataVolume:
    enabled: false
    mountPath: /kalamar/data
    size: 50Gi
```

### Lite Profile (Default)

```yaml
kalamar:
  image: korap/kalamar:latest
  replicaCount: 1

kustvakt:
  image: korap/kustvakt:latest
```

### Full Profile

```yaml
full:
  enabled: false
  
kalamarFull:
  enabled: false
  image: korap/kalamar:latest

kustvaktFull:
  enabled: false
  image: korap/kustvakt:latest-full
  
# For authentication/LDAP:
full:
  superClientInfoSecretName: null
  kalamarProductionConf:
    enabled: false
    content: ""
```

### Example Profile

```yaml
exampleIndex:
  enabled: false
  image: korap/example-index:0.1
```

### Security & Restart Policies

```yaml
securityContext:
  runAsUser: 0          # Root user (required for full profile)
  runAsGroup: 0
  fsGroup: 0

restartPolicy: Always   # Kubernetes equivalent of Docker's "unless-stopped"
```

---

## 🏁 Installation

### Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- Sufficient storage for index volumes

### 1. Create Namespace

```bash
kubectl create namespace korap
```

### 2. Install Lite Profile

Basic KorAP deployment:

```bash
helm install korap ./korap \
  --namespace korap \
  --create-namespace
```

### 3. Install Full Profile

Enterprise setup with authentication:

```bash
# Create authentication secret (optional)
kubectl create secret generic korap-super-client \
  --from-file=super_client_info=./super_client_info \
  -n korap

# Install with full profile
helm install korap ./korap \
  --namespace korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set kustvaktFull.enabled=true \
  --set 'full.dataVolume.enabled=true' \
  --set 'full.superClientInfoSecretName=korap-super-client'
```

### 4. Install with Example Index

For testing purposes:

```bash
helm install korap ./korap \
  --namespace korap \
  --set exampleIndex.enabled=true
```

### 5. Verify Installation

```bash
# Check pods
kubectl get pods -n korap

# Check services
kubectl get svc -n korap

# Check volumes
kubectl get pvc -n korap

# View deployment notes
helm get notes korap -n korap
```

---

## 🌐 Accessing KorAP

### Port Forwarding

If not using Ingress:

```bash
kubectl port-forward svc/korap-korap-kalamar 64543:64543 -n korap
```

Then access: `http://localhost:64543`

### With Ingress

Enable and configure Ingress:

```bash
helm upgrade korap ./korap \
  --set 'ingress.enabled=true' \
  --set 'ingress.className=nginx' \
  --set 'ingress.hosts[0].host=korap.example.com' \
  --set 'ingress.hosts[0].paths[0].path=/' \
  --set 'ingress.hosts[0].paths[0].pathType=Prefix' \
  -n korap
```

Then access: `https://korap.example.com`

---

## 📚 Index Management

### Using Existing Index

If you have an existing corpus index on a PVC:

```bash
helm install korap ./korap \
  --set 'indexVolume.existingClaim=my-index-pvc' \
  -n korap
```

### Loading a New Index

1. Create PVC for index data
2. Copy index files to PVC
3. Reference PVC in values

```bash
# Create initial index PVC
kubectl create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: korap-index
  namespace: korap
spec:
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: 20Gi
