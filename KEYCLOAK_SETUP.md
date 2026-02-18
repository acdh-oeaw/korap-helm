# Keycloak Integration Setup Guide

This Helm chart is now properly configured to work with Keycloak for authentication. Here's what has been added and how to use it.

## What Was Added to the Chart

### 1. **values.yaml** - Keycloak Section
A new `keycloak` section has been added with the following parameters:
- `enabled` - Enable/disable Keycloak integration
- `authUrl` - Keycloak authentication endpoint
- `clientId` - OAuth2 Client ID
- `clientSecret` - OAuth2 Client Secret
- `issuer` - OpenID Connect issuer
- `jwksUri` - JWKS URI for token verification
- `tokenUrl` - Token endpoint
- `userinfoUrl` - User info endpoint

### 2. **keycloak-secret.yaml** - New Template
Automatically creates a Kubernetes Secret with `clientSecret` values that are passed to Kustvakt.

### 3. **kustvakt-full-deployment.yaml** - Updated
Added environment variables that pass Keycloak configuration to Kustvakt:
- `KC_AUTH_URL`
- `KC_CLIENT_ID`
- `KC_ISSUER`
- `KC_JWKS_URI`
- `KC_TOKEN_URL`
- `KC_USERINFO_URL`
- `KC_CLIENT_SECRET` (from Secret if available)

### 4. **kustvakt-deployment.yaml** - Updated
Same configuration for the lite version of Kustvakt.

---

## How to Use Keycloak Integration

### Step 1: Prepare Your Keycloak Server

You need to register KorAP as an OAuth2 client in Keycloak:

1. Log in to your Keycloak admin console
2. Create a new client or use an existing one with ID `korap`
3. Set "Access Type" to "Confidential"
4. Copy the "Client Secret" value - you'll need it soon
5. In "Valid Redirect URIs" add:
   ```
   http://localhost:64543/oauth2/callback
   https://your-domain.com/oauth2/callback
   ```

### Step 2: Prepare Keycloak Configuration

Create a values file with Keycloak parameters. You can use `values-keycloak-example.yaml` as a template:

```bash
cp values-keycloak-example.yaml values-keycloak.yaml
# Then edit values-keycloak.yaml and enter your values
```

Or copy the example and edit the values:

```yaml
keycloak:
  enabled: true
  authUrl: https://auth.acdh.oeaw.ac.at/realms/korap/protocol/openid-connect/auth
  tokenUrl: https://auth.acdh.oeaw.ac.at/realms/korap/protocol/openid-connect/token
  userinfoUrl: https://auth.acdh.oeaw.ac.at/realms/korap/protocol/openid-connect/userinfo
  issuer: https://auth.acdh.oeaw.ac.at/realms/korap
  jwksUri: https://auth.acdh.oeaw.ac.at/realms/korap/protocol/openid-connect/certs
  clientId: korap
  clientSecret: null  # Set in the next step
  clientSecretKey: client-secret
```

### Step 3: Create Kubernetes Secret with Client Secret

**Option A: Automatic (Recommended)**

Pass the clientSecret directly to Helm during deployment:

```bash
helm install korap ./korap \
  --values values-keycloak.yaml \
  --set keycloak.clientSecret="YOUR_CLIENT_SECRET_FROM_KEYCLOAK_HERE"
```

**Option B: Use an Existing Secret**

If you already have an existing Kubernetes secret:

```bash
# Create secret if you don't have one
kubectl create secret generic korap-keycloak-client-secret \
  --from-literal=client-secret="YOUR_CLIENT_SECRET_HERE" \
  -n your-namespace

# Then use values with reference to the secret
helm install korap ./korap \
  --values values-keycloak.yaml \
  --set keycloak.clientSecretSecretName="korap-keycloak-client-secret"
```

### Step 4: Deploy with Helm

```bash
# Full deployment with Keycloak
helm install korap ./korap \
  --values values-keycloak.yaml \
  --set keycloak.clientSecret="YOUR_CLIENT_SECRET_HERE" \
  --namespace korap \
  --create-namespace
```

Or if you're using an existing secret:

```bash
helm install korap ./korap \
  --values values-keycloak.yaml \
  --set keycloak.clientSecretSecretName="korap-keycloak-client-secret" \
  --namespace korap \
  --create-namespace
```

---

## Verify the Deployment

Check if everything is configured correctly:

```bash
# Check if environment variables are passed to Kustvakt
kubectl logs -l app=kustvakt-full -n korap | grep KC_

# Check if the secret was created
kubectl get secrets -n korap | grep keycloak

# Check if the pods are running
kubectl get pods -n korap

# View all environment variables in the Kustvakt pod
kubectl describe pod -l app=kustvakt-full -n korap
```

---

## Environment Variables Used by Kustvakt

Kustvakt expects the following environment variables (all are optional if Keycloak is not enabled):

| Variable | Usage |
|----------|-------|
| `KC_AUTH_URL` | Keycloak auth endpoint |
| `KC_CLIENT_ID` | OAuth2 client identifier |
| `KC_CLIENT_SECRET` | OAuth2 client secret |
| `KC_ISSUER` | OpenID Connect issuer URI |
| `KC_JWKS_URI` | JWKS endpoint for token validation |
| `KC_TOKEN_URL` | Token endpoint |
| `KC_USERINFO_URL` | User info endpoint |

---

## Troubleshooting

### Login doesn't work after deployment?

1. **Check if environment variables are passed:**
   ```bash
   kubectl describe pod -l app=kustvakt-full -n korap | grep -A 50 "Environment:"
   ```

2. **View Kustvakt logs:**
   ```bash
   kubectl logs -l app=kustvakt-full -n korap --tail=100
   ```

3. **View Kalamar logs:**
   ```bash
   kubectl logs -l app=kalamar-full -n korap --tail=100
   ```

4. **Check if the secret is properly configured:**
   ```bash
   kubectl get secret korap-keycloak-client-secret -n korap -o yaml
   ```

5. **Check if Keycloak servers are accessible:**
   ```bash
   kubectl exec -it <kustvakt-pod> -- curl https://auth.acdh.oeaw.ac.at/realms/korap
   ```

### Problem: "client-secret is not reaching Kustvakt"

If you see that `KC_CLIENT_SECRET` is not in the environment variables:

1. Check if `keycloak.enabled: true` is set in values.yaml
2. Check if `keycloak.clientSecret` is provided or if `clientSecretSecretName` points to an existing secret
3. Verify that the secret name is correct:
   ```bash
   kubectl get secrets -n korap | grep keycloak
   ```

---

## values.yaml Reference

```yaml
keycloak:
  enabled: false              # Enable Keycloak
  authUrl: null               # Authorization endpoint
  clientId: null              # OAuth2 Client ID
  clientSecret: null          # OAuth2 Client Secret (or use a secret)
  clientSecretKey: client-secret  # Key in the Secret
  clientSecretSecretName: null    # Existing Secret for client secret
  issuer: null                # OpenID Connect issuer
  jwksUri: null               # JWKS URI for validation
  tokenUrl: null              # Token endpoint
  userinfoUrl: null           # Userinfo endpoint
```

---

## Additional Notes

- **Helm Secrets Plugin**: For production use, consider using the [helm-secrets](https://github.com/jnewland/helm-secrets) plugin to encrypt client secrets in git
- **External Secret Operator**: For Kubernetes-native secret management, consider [External Secrets](https://external-secrets.io/)
- **OIDC Provider Settings**: Verify that the URLs for auth endpoint, token endpoint, etc. are correct for your Keycloak server
