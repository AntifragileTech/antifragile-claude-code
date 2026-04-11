# Kubernetes & Container Security Reference

## Tools Required
- `kubectl` (cluster-admin or read access)
- `trivy` — image + manifest scanning
- `falco` — runtime threat detection
- `kubeaudit` — cluster hardening checks
- `kube-bench` — CIS benchmark runner
- `rbac-tool` / `KubiScan` — RBAC analysis
- `grype` — image vulnerability scanning
- `kubesec` — manifest static analysis

---

## 1. RBAC Audit
```bash
# Wildcard permissions (dangerous)
kubectl get clusterroles -o json | jq '.items[] | select(.rules[]?.verbs[]? == "*") | .metadata.name'

# Service accounts with cluster-admin
kubectl get clusterrolebindings -o json | jq '.items[] | select(.roleRef.name == "cluster-admin") | .subjects'

# rbac-tool: show who can do what
kubectl rbac-tool who-can create pods
kubectl rbac-tool who-can get secrets

# KubiScan: find risky roles
python3 /opt/kubiscan/kubiscan.py -rr   # risky roles
python3 /opt/kubiscan/kubiscan.py -rs   # risky service accounts
```
**Fix**: Remove wildcard verbs, bind least-privilege roles, disable automountServiceAccountToken on pods that don't need it.

---

## 2. Container Image Scanning
```bash
# Trivy: scan image for CVEs
trivy image --severity HIGH,CRITICAL nginx:latest

# Grype: alternative scanner
grype nginx:latest

# Trivy: scan entire cluster (all running images)
trivy k8s --report summary cluster

# Scan in CI/CD (fail on CRITICAL)
trivy image --exit-code 1 --severity CRITICAL myapp:$TAG
```
**Fix**: Use distroless or minimal base images, update dependencies, pin image digests not tags.

---

## 3. Pod Security Standards
```bash
# Check Pod Security Admission labels on namespaces
kubectl get namespaces -o json | jq '.items[] | {name: .metadata.name, pss: .metadata.labels}'

# kubeaudit: full cluster hardening check
kubeaudit all -f deployment.yaml   # against manifest
kubeaudit all                       # against live cluster

# Check for privileged pods
kubectl get pods -A -o json | jq '.items[] | select(.spec.containers[]?.securityContext.privileged == true) | .metadata'
```
**Fix**: Enforce `restricted` PSS on prod namespaces, set `runAsNonRoot: true`, `readOnlyRootFilesystem: true`, drop ALL capabilities.

---

## 4. Container Escape Detection (Falco)
```bash
# Install Falco (DaemonSet)
helm install falco falcosecurity/falco --set falco.grpc.enabled=true

# Key rules to enable:
# - Terminal shell in container
# - Sensitive mount in container
# - Container running as root
# - Outbound connection to C2 ports

# Check Falco alerts
kubectl logs -n falco -l app=falco --tail=50
```
**Signals**: Shell spawned inside container, /proc mount access, sensitive file reads (/etc/shadow), unexpected outbound connections.

---

## 5. Network Policies
```bash
# Check namespaces with no network policy (open east-west traffic)
kubectl get networkpolicies -A
kubectl get pods -n <ns> -o wide  # cross-ref with policies

# Apply default-deny
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
EOF
```
**Fix**: Implement Calico or Cilium, default-deny per namespace, explicit allow rules per service.

---

## 6. CIS Benchmark (kube-bench)
```bash
# Run against control plane
kube-bench run --targets master

# Run against worker nodes
kube-bench run --targets node

# Run in-cluster as a Job
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs job/kube-bench
```
**Target score**: Zero FAIL on Level 1 checks before prod.

---

## 7. etcd Security
```bash
# Check etcd encryption at rest
kubectl get apiserver -o yaml | grep encryption
# Should show: encryptionConfig with AES-CBC or AES-GCM

# Verify etcd TLS
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health
```

---

## 8. Registry Security
```bash
# Harbor: scan on push
# Enable in Harbor UI: Administration > Interrogation Services

# Block unsigned images (cosign)
cosign verify --key cosign.pub myregistry/myapp:latest

# Trivy registry scan
trivy registry myregistry.io/myapp:latest
```

---

## Checklist Summary
- [ ] No wildcard RBAC roles in production namespaces
- [ ] All images scanned — zero CRITICAL CVEs
- [ ] Pod Security Standards: `restricted` on prod namespaces
- [ ] Falco deployed and alerting
- [ ] Default-deny NetworkPolicy on all namespaces
- [ ] kube-bench Level 1: zero FAILs
- [ ] etcd encrypted at rest
- [ ] No privileged containers
- [ ] Service accounts: automount disabled where not needed
- [ ] Registry: signed images only (cosign)
