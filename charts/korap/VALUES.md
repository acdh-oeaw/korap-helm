# KorAP Helm Chart - Values Configuration Reference

This document provides a complete reference table for all configurable values in the KorAP Helm chart.

## Quick Lookup Table

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **profile** | string | `lite` | Deployment profile: `lite` or `full` |
| **global.imagePullPolicy** | string | `IfNotPresent` | Image pull policy: `Always`, `IfNotPresent`, `Never` |
| **service.kalamar.port** | integer | `64543` | Kalamar web interface port |
| **service.kalamar.type** | string | `ClusterIP` | Kalamar service type: `ClusterIP`, `NodePort`, `LoadBalancer` |
| **service.kustvakt.port** | integer | `8089` | Kustvakt API port |
| **service.kustvakt.type** | string | `ClusterIP` | Kustvakt service type: `ClusterIP`, `NodePort`, `LoadBalancer` |
| **kalamar.image** | string | `korap/kalamar:latest` | Kalamar container image (lite profile) |
| **kalamar.replicaCount** | integer | `1` | Number of Kalamar replicas |
| **kalamar.extraEnv** | array | `[]` | Additional environment variables for Kalamar |
| **kalamarFull.enabled** | boolean | `false` | Enable Kalamar full profile deployment |
| **kalamarFull.image** | string | `korap/kalamar:latest` | Kalamar container image (full profile) |
| **kalamarFull.replicaCount** | integer | `1` | Number of Kalamar full replicas |
| **kalamarFull.extraEnv** | array | `[]` | Additional environment variables for Kalamar full |
| **kustvakt.image** | string | `korap/kustvakt:latest` | Kustvakt container image (lite profile) |
| **kustvakt.extraEnv** | array | `[]` | Additional environment variables for Kustvakt |
| **kustvaktFull.enabled** | boolean | `false` | Enable Kustvakt full profile deployment |
| **kustvaktFull.image** | string | `korap/kustvakt:latest-full` | Kustvakt full container image |
| **kustvaktFull.extraEnv** | array | `[]` | Additional environment variables for Kustvakt full |
| **exampleIndex.enabled** | boolean | `false` | Enable example index container |
| **exampleIndex.image** | string | `korap/example-index:0.1` | Example index container image |
| **indexVolume.size** | string | `10Gi` | Size of index PVC |
| **indexVolume.storageClassName** | string | `null` | Storage class for index volume (null=default) |
| **indexVolume.existingClaim** | string | `null` | Use existing PVC instead of creating new one |
| **ingress.enabled** | boolean | `false` | Enable Kubernetes Ingress |
| **ingress.className** | string | `null` | Ingress class name (e.g., `nginx`, `traefik`) |
| **ingress.annotations** | object | `{}` | Ingress annotations |
| **ingress.hosts** | array | `[]` | Ingress host configuration |
| **ingress.tls** | array | `[]` | Ingress TLS configuration |
| **full.enabled** | boolean | `false` | Enable full profile features |
| **full.superClientInfo.enabled** | boolean | `true` | Auto-generate OAuth super_client_info Secret |
| **full.superClientInfo.clientId** | string | `korap-client` | OAuth2 client identifier |
| **full.superClientInfo.clientSecret** | string | `auto-generate` | Client secret (`auto-generate` = 32-char random) |
| **full.superClientInfo.clientName** | string | `KorAP` | Client display name |
| **full.superClientInfo.clientType** | string | `CONFIDENTIAL` | Client type (CONFIDENTIAL or PUBLIC) |
| **full.superClientInfo.clientDescription** | string | `KorAP Kalamar Frontend` | Client description |
| **full.superClientInfo.clientUrl** | string | `http://localhost:64543` | Client application URL |
| **full.superClientInfo.clientRedirectUri** | string | `http://localhost:64543/oauth2/callback` | OAuth2 redirect URI |
| **full.superClientInfo.super** | boolean | `true` | Mark as super client (full access) |
| **full.superClientInfo.refreshTokenExpiry** | integer | `31536000` | Refresh token expiry in seconds (365 days) |
| **full.superClientInfo.permitted** | boolean | `true` | Is client permitted/active |
| **full.superClientInfoSecretName** | string | `null` | Use existing Kubernetes secret instead of auto-generating |
| **full.superClientInfoKey** | string | `super_client_info` | Secret key containing auth data |
| **full.superClientInfoPath** | string | `/kalamar/super_client_info` | Mount path for auth info |
| **full.dataVolume.enabled** | boolean | `false` | Enable Kalamar data volume |
| **full.dataVolume.mountPath** | string | `/kalamar/data` | Mount path for Kalamar data |
| **full.dataVolume.size** | string | `50Gi` | Size of Kalamar data PVC |
| **full.dataVolume.storageClassName** | string | `null` | Storage class for Kalamar data |
| **full.dataVolume.existingClaim** | string | `null` | Use existing PVC for Kalamar data |
| **full.kustvaktDataVolume.enabled** | boolean | `false` | Enable Kustvakt data volume |
| **full.kustvaktDataVolume.mountPath** | string | `/kustvakt/data` | Mount path for Kustvakt data |
| **full.kustvaktDataVolume.size** | string | `50Gi` | Size of Kustvakt data PVC |
| **full.kustvaktDataVolume.storageClassName** | string | `null` | Storage class for Kustvakt data |
| **full.kustvaktDataVolume.existingClaim** | string | `null` | Use existing PVC for Kustvakt data |
| **full.kalamarProductionConf.enabled** | boolean | `false` | Enable custom Kalamar production config |
| **full.kalamarProductionConf.content** | string | (default config) | Kalamar production configuration in Perl format |
| **securityContext.runAsUser** | integer | `0` | Container user ID (0=root) |
| **securityContext.runAsGroup** | integer | `0` | Container group ID |
| **securityContext.fsGroup** | integer | `0` | Filesystem group ID |
| **restartPolicy** | string | `Always` | Pod restart policy: `Always`, `OnFailure`, `Never` |

---

## Configuration Groups

### 1. General Configuration

**profile** (string, default: `lite`)
- Deployment profile to use
- Options: `lite` (minimal setup), `full` (enterprise with auth)
- Lite profile: Single Kalamar and Kustvakt services
- Full profile: Kalamar with plugins, Kustvakt with LDAP, initialization job, data volumes

### 2. Global Settings

**global.imagePullPolicy** (string, default: `IfNotPresent`)
- How Kubernetes pulls container images
- Options: 
  - `Always` - Always pull latest image
  - `IfNotPresent` - Use local copy if available (default)
  - `Never` - Never pull, use local only

### 3. Service Configuration

**service.kalamar.port** (integer, default: `64543`)
- Port for Kalamar web interface
- Match this port when accessing Kalamar externally
- Standard KorAP port is 64543

**service.kalamar.type** (string, default: `ClusterIP`)
- Kubernetes service type for Kalamar
- `ClusterIP` - Internal only (use with port-forward or ingress)
- `NodePort` - Accessible on node ports
- `LoadBalancer` - CloudProvider load balancer

**service.kustvakt.port** (integer, default: `8089`)
- Port for Kustvakt API backend
- Kalamar connects to this internally
- Standard KorAP port is 8089

**service.kustvakt.type** (string, default: `ClusterIP`)
- Kubernetes service type for Kustvakt
- Usually `ClusterIP` since it's backend-only

### 4. Kalamar Configuration (Lite Profile)

**kalamar.image** (string, default: `korap/kalamar:latest`)
- Docker image for Kalamar
- Use specific version tags for production (e.g., `korap/kalamar:1.2.3`)

**kalamar.replicaCount** (integer, default: `1`)
- Number of Kalamar pod replicas
- For high availability, set to 2 or more
- All replicas load-balanced

**kalamar.extraEnv** (array, default: `[]`)
- Additional environment variables
- Format: Each item as `KEY: value`
- Example: `KALAMAR_DEBUG: "true"`

### 5. Kalamar Full Configuration

**kalamarFull.enabled** (boolean, default: `false`)
- Enable full profile Kalamar deployment
- Requires `full.enabled: true`
- Includes Auth plugin support
- Automatically set when using full profile

**kalamarFull.image** (string, default: `korap/kalamar:latest`)
- Docker image for full Kalamar

**kalamarFull.replicaCount** (integer, default: `1`)
- Number of Kalamar full pod replicas

**kalamarFull.extraEnv** (array, default: `[]`)
- Additional environment variables for full Kalamar

### 6. Kustvakt Configuration (Lite Profile)

**kustvakt.image** (string, default: `korap/kustvakt:latest`)
- Docker image for Kustvakt
- Lite version: `korap/kustvakt:latest`
- Full version: `korap/kustvakt:latest-full`

**kustvakt.extraEnv** (array, default: `[]`)
- Additional environment variables
- Used for configuration that doesn't have dedicated fields

### 7. Kustvakt Full Configuration

**kustvaktFull.enabled** (boolean, default: `false`)
- Enable full profile Kustvakt deployment
- Requires `full.enabled: true`
- Includes LDAP/authentication support
- Uses `korap/kustvakt:latest-full` image

**kustvaktFull.image** (string, default: `korap/kustvakt:latest-full`)
- Docker image for full Kustvakt
- Always use `-full` suffix for full profile

**kustvaktFull.extraEnv** (array, default: `[]`)
- Additional environment variables

### 8. Example Container

**exampleIndex.enabled** (boolean, default: `false`)
- Deploy example index container for testing
- Uses `korap/example-index:0.1` image
- Non-persistent (emptyDir volume)
- Useful for testing without real corpus data

**exampleIndex.image** (string, default: `korap/example-index:0.1`)
- Docker image for example index

### 9. Index Volume (All Profiles)

**indexVolume.size** (string, default: `10Gi`)
- Size of the shared index volume
- Adjust based on corpus size
- Format: '10Gi', '100Gi', '1Ti' etc.
- Lite profile default: 10Gi (for testing)
- Production: typically 50Gi-500Gi+

**indexVolume.storageClassName** (string, default: `null`)
- Kubernetes storage class for the volume
- Leave empty to use default storage class
- Examples: `fast-ssd`, `standard`, `aws-ebs`
- Check available classes: `kubectl get storageclasses`

**indexVolume.existingClaim** (string, default: `null`)
- Name of existing PVC to use instead of creating new
- Useful when reusing data from previous installs
- If set, new PVC is NOT created
- Must be in same namespace

### 10. Ingress Configuration

**ingress.enabled** (boolean, default: `false`)
- Enable Kubernetes Ingress for external access
- Requires ingress controller (nginx, traefik, etc.)
- Set to `true` to expose Kalamar via domain name

**ingress.className** (string, default: `null`)
- Ingress class name
- Common values: `nginx`, `traefik`, `istio`, `gce`
- Check available: `kubectl get ingressclasses`

**ingress.annotations** (object, default: `{}`)
- Annotations for ingress (certifications, SSL, etc.)
- Example: `cert-manager.io/cluster-issuer: "letsencrypt-prod"`

**ingress.hosts** (array, default: `[]`)
- Host configuration
- Format:
  ```yaml
  - host: korap.example.com
    paths:
      - path: /
        pathType: Prefix
  ```

**ingress.tls** (array, default: `[]`)
- TLS/SSL configuration
- Requires cert-manager typically
- Format:
  ```yaml
  - secretName: korap-tls
    hosts:
      - korap.example.com
  ```

### 11. Full Profile Settings

**full.enabled** (boolean, default: `false`)
- Master flag to enable full profile features
- Enables:
  - Full profile Kalamar (with Auth plugin)
  - Full profile Kustvakt (with LDAP)
  - Initialization job
  - Optional data volumes
  - OAuth2 authentication (auto-generated by default)

### 12. OAuth2 Auto-Generation (New!)

**full.superClientInfo.enabled** (boolean, default: `true`)
- **NEW**: Auto-generate OAuth2 `super_client_info` Secret automatically
- When enabled, the chart creates a production-ready OAuth client on deployment
- No manual secret creation needed!
- All OAuth fields automatically configured from values below
- Secure random client secret generated (32 characters) if set to `"auto-generate"`

**Default behavior:**
```bash
# This deployment will auto-generate OAuth credentials
helm install korap ./korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true
```

**Customize auto-generated OAuth client:**

**full.superClientInfo.clientId** (string, default: `korap-client`)
- Unique identifier for the OAuth client
- Should be URL-safe (alphanumeric, hyphens, underscores)
- Example: `korap-prod`, `my-korap-app`

**full.superClientInfo.clientSecret** (string, default: `auto-generate`)
- OAuth client secret for authentication
- `"auto-generate"` = 32-character secure random string (RECOMMENDED)
- Custom value = your own secret (must be strong/secure)
- See in pod/secret after deployment: `kubectl get secret <name> -o jsonpath='{.data.super_client_info}' | base64 -d`

**full.superClientInfo.clientName** (string, default: `KorAP`)
- Display name of the OAuth client
- Shown to users during OAuth flow
- Example: `KorAP Production`, `My Corpus Platform`

**full.superClientInfo.clientType** (string, default: `CONFIDENTIAL`)
- OAuth2 client type
- `CONFIDENTIAL` = server-side app (has client secret, RECOMMENDED for KorAP)
- `PUBLIC` = client-side app (no secret, for mobile/SPA)

**full.superClientInfo.clientDescription** (string, default: `KorAP Kalamar Frontend`)
- Detailed description of the OAuth client
- Used internally for documentation/admin purposes

**full.superClientInfo.clientUrl** (string, default: `http://localhost:64543`)
- URL of the Kalamar frontend
- Should match deployment environment
- Examples:
  - Local: `http://localhost:64543`
  - Production: `https://korap.example.com`

**full.superClientInfo.clientRedirectUri** (string, default: `http://localhost:64543/oauth2/callback`)
- OAuth2 redirect URI (crucial for security!)
- Must exactly match what your OAuth provider expects
- Format: `<protocol>://<domain>[:port]/oauth2/callback`
- **MUST** use HTTPS in production for security
- Examples:
  - Local: `http://localhost:64543/oauth2/callback`
  - Production: `https://korap.example.com/oauth2/callback`

**full.superClientInfo.super** (boolean, default: `true`)
- Mark this as a super client in Kustvakt
- Super clients have full administrative access
- Should be `true` for the main Kalamar frontend

**full.superClientInfo.refreshTokenExpiry** (integer, default: `31536000`)
- Refresh token expiry time in seconds
- `31536000` = 365 days (1 year, RECOMMENDED)
- Adjust based on security requirements

**full.superClientInfo.permitted** (boolean, default: `true`)
- Is this OAuth client active/permitted
- `true` = client can authenticate
- `false` = client is disabled (can be changed later)

**Example: Customize for Production**

```bash
helm install korap ./korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set 'full.superClientInfo.clientId=korap-prod' \
  --set 'full.superClientInfo.clientName=KorAP Production' \
  --set 'full.superClientInfo.clientUrl=https://korap.example.com' \
  --set 'full.superClientInfo.clientRedirectUri=https://korap.example.com/oauth2/callback' \
  --set 'full.superClientInfo.clientSecret=my-secure-secret-key'
```

### 13. Using External OAuth Client (Optional)

**full.superClientInfoSecretName** (string, default: `null`)
- Reference a pre-existing Kubernetes secret instead of auto-generating
- Useful if you want to manage OAuth credentials separately
- If set, auto-generation is skipped and this secret is used
- Secret must contain a file key `super_client_info` with OAuth JSON

**To use an external secret:**

```bash
# 1. Create your super_client_info.json file with OAuth details
# 2. Create Kubernetes secret from file
kubectl create secret generic my-oauth-secret \
  --from-file=super_client_info=./super_client_info.json \
  -n korap

# 3. Reference it in Helm
helm install korap ./korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set 'full.superClientInfoSecretName=my-oauth-secret'
```

**full.superClientInfoKey** (string, default: `super_client_info`)
- Key name inside the secret file containing OAuth data
- Usually `super_client_info` (matches the JSON filename)
- Rarely needs to be changed

**full.superClientInfoPath** (string, default: `/kalamar/super_client_info`)
- Where the OAuth credentials are mounted inside Kalamar pod
- Kalamar reads this path to load OAuth configuration
- Do not change unless you know what you're doing

### 14. Disable Authentication

**To run full profile WITHOUT OAuth/authentication:**

```bash
helm install korap ./korap \
  --set full.enabled=true \
  --set kalamarFull.enabled=true \
  --set 'full.superClientInfo.enabled=false'
```

**Result:**
- No OAuth secret created
- Kalamar runs without Auth plugin
- Anonymous access only
- No login functionality

### 15. Full Profile - Full Profile - Data Volumes

**full.dataVolume.enabled** (boolean, default: `false`)

**full.superClientInfoKey** (string, default: `super_client_info`)
- Key in the secret containing authentication data
- Usually `super_client_info`
- Must match the file name in secret

**full.superClientInfoPath** (string, default: `/kalamar/super_client_info`)
- Mount path inside container
- Do not change unless you know what you're doing
- Kalamar looks for file at this path

### 12. Full Profile - Data Volumes

**full.dataVolume.enabled** (boolean, default: `false`)
- Enable persistent data volume for Kalamar
- Full profile only
- Stores initialization data and generated files

**full.dataVolume.mountPath** (string, default: `/kalamar/data`)
- Mount path inside Kalamar container
- Standard KorAP path
- Do not change unless needed

**full.dataVolume.size** (string, default: `50Gi`)
- Size of Kalamar data volume
- Adjust based on data generation needs

**full.dataVolume.storageClassName** (string, default: `null`)
- Storage class for Kalamar data volume

**full.dataVolume.existingClaim** (string, default: `null`)
- Use existing PVC instead of creating new

**full.kustvaktDataVolume.enabled** (boolean, default: `false`)
- Enable persistent data volume for Kustvakt
- Full profile only
- Stores authentication and policy data

**full.kustvaktDataVolume.mountPath** (string, default: `/kustvakt/data`)
- Mount path inside Kustvakt container

**full.kustvaktDataVolume.size** (string, default: `50Gi`)
- Size of Kustvakt data volume

**full.kustvaktDataVolume.storageClassName** (string, default: `null`)
- Storage class for Kustvakt data volume

**full.kustvaktDataVolume.existingClaim** (string, default: `null`)
- Use existing PVC instead of creating new

### 13. Full Profile - Configuration

**full.kalamarProductionConf.enabled** (boolean, default: `false`)
- Enable custom production configuration file for Kalamar
- Full profile only
- Creates a ConfigMap mounted in the Kalamar pod
- Configuration is in Perl format

**full.kalamarProductionConf.content** (string, default: production settings)
- Content of Kalamar production configuration file
- Format: Perl hash with Kalamar, Auth, and CSP settings
- Default provided includes:
  - API endpoint configuration
  - Plugin specifications
  - OAuth2 authentication settings
  - Content Security Policy (CSP) headers
  - HTTPS enforcement
- Example configuration:
  ```perl
  {
    Kalamar => {
      api_path => 'https://korap.ids-mannheim.de/api/',
      api_version => '1.0',
      https_only => 1,
      plugins => ['Auth', 'KorAPXML2Krill', 'Tei2KorAPXML', 'Plugins']
    },
    'Kalamar-Auth' => {
      oauth2 => 1
    },
    CSP => {
      'default-src' => 'self',
      'style-src' => ['self','unsafe-inline'],
      'script-src' => ['self'],
      'connect-src' => 'self',
      'img-src' => ['self', 'data:']
    }
  }
  ```
- See [Kalamar Documentation](https://github.com/KorAP/Kalamar) for all available settings
- Customize API endpoints, plugins, authentication, and security policies as needed

### 14. Security Configuration

**securityContext.runAsUser** (integer, default: `0`)
- UID for running containers
- `0` = root user (required for full profile)
- Other values = specific user ID
- Affects file permissions and capabilities

**securityContext.runAsGroup** (integer, default: `0`)
- GID for running containers
- Usually same as runAsUser

**securityContext.fsGroup** (integer, default: `0`)
- GID for filesystem volume ownership
- Required for volume mounting

### 15. Pod Configuration

**restartPolicy** (string, default: `Always`)
- Pod restart policy for Kubernetes
- `Always` - Restart container when it exits (default, for persistent services)
- `OnFailure` - Restart only on non-zero exit code
- `Never` - Never restart (for one-time jobs)

---

## Common Configuration Examples

### Minimal Lite Setup
```yaml
profile: lite
service:
  kalamar:
    port: 64543
indexVolume:
  size: 10Gi
```

### Full Setup with Authentication
```yaml
profile: full
full:
  enabled: true
kalamarFull:
  enabled: true
kustvaktFull:
  enabled: true
full:
  superClientInfoSecretName: korap-auth
  dataVolume:
    enabled: true
    size: 100Gi
```

### With Ingress
```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: korap.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Production Setup
```yaml
profile: full
kalamar:
  replicaCount: 2
kalamarFull:
  enabled: true
  replicaCount: 2
kustvaktFull:
  enabled: true
full:
  enabled: true
  superClientInfoSecretName: korap-auth
  dataVolume:
    enabled: true
    size: 200Gi
service:
  kalamar:
    type: LoadBalancer
ingress:
  enabled: true
  className: nginx
```

---

## For more information
- See [README.md](../README.md) for installation and usage
- See [IMPLEMENTATION.md](../IMPLEMENTATION.md) for detailed architecture
