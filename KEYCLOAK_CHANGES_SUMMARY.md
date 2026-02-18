# Keycloak Integration - Summary of Changes

## Problem
Keycloak configuration was added to `values.yaml`, but it was not being passed to Kustvakt, so login didn't work.

## Solution - What Was Added

### 1. ✅ **values.yaml** - New `keycloak` Section
```yaml
keycloak:
  enabled: false
  authUrl: null
  clientId: null
  clientSecret: null
  clientSecretKey: client-secret
  clientSecretSecretName: null
  issuer: null
  jwksUri: null
  tokenUrl: null
  userinfoUrl: null
```

### 2. ✅ **New Template: `keycloak-secret.yaml`**
- Automatically creates a Kubernetes Secret with `clientSecret`
- Secret is used as a reference in pod environment variables

### 3. ✅ **Updated: `kustvakt-full-deployment.yaml`**
- Added environment variables for all Keycloak parameters
- `KC_AUTH_URL`, `KC_CLIENT_ID`, `KC_ISSUER`, `KC_JWKS_URI`, `KC_TOKEN_URL`, `KC_USERINFO_URL`, `KC_CLIENT_SECRET`
- Variables are only set if `keycloak.enabled: true`

### 4. ✅ **Updated: `kustvakt-deployment.yaml`**
- Same configuration for lite version (if user wants Keycloak without full mode)

### 5. ✅ **New File: `values-keycloak-example.yaml`**
- Complete example with all necessary values
- Instructions in comments on how to use it

### 6. ✅ **New File: `KEYCLOAK_SETUP.md`**
- Detailed setup guide
- How-to for registering client in Keycloak
- Helm command examples
- Troubleshooting section

---

## How to Use Keycloak Now

### Quick Start:

```bash
# 1. Copy example values
cp values-keycloak-example.yaml values-keycloak.yaml

# 2. Edit values-keycloak.yaml - add your Keycloak parameters

# 3. Deploy with Helm
helm install korap ./korap \
  --values values-keycloak.yaml \
  --set keycloak.clientSecret="YOUR_SECRET_HERE" \
  --namespace korap \
  --create-namespace
```

### Or if you're using an existing Kubernetes secret:

```bash
helm install korap ./korap \
  --values values-keycloak.yaml \
  --set keycloak.clientSecretSecretName="your-secret-with-client-secret" \
  --namespace korap \
  --create-namespace
```

---

## Verification - How to Check if Keycloak Works

```bash
# 1. Check if environment variables are in the Kustvakt pod
kubectl describe pod -l app=kustvakt-full -n korap | grep KC_

# 2. View logs
kubectl logs -l app=kustvakt-full -n korap

# 3. Check secret
kubectl get secret korap-keycloak-client-secret -n korap -o yaml
```

---

## What's Different Now

**Before:**
- ✗ Keycloak configuration didn't exist anywhere in the chart
- ✗ Even if it existed in values.yaml, it wouldn't be passed to Kustvakt
- ✗ No template for Secret with clientSecret

**Now:**
- ✅ Keycloak configuration is structured in values.yaml
- ✅ Environment variables are passed to Kustvakt (key to make it work!)
- ✅ Secret is automatically created with clientSecret values
- ✅ Complete documentation with examples
- ✅ Works for both lite and full profiles

---

## Next Steps

1. Register KorAP as a client in Keycloak admin console
2. Copy the client secret value
3. Edit values-keycloak.yaml with your values
4. Deploy the Helm chart
5. Test login via Keycloak

More detailed instructions are in the **KEYCLOAK_SETUP.md** file.
