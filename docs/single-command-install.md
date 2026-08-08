# Single-Command Installation

## Prerequisites

1. **Kubernetes cluster**: k3s, Minikube, Kind, or any conformant cluster.
2. **kubectl**: installed and pointed at your cluster (`kubectl version`).

## Installation

```bash
kubectl apply --server-side -f https://github.com/reflex-automation/reflex-operator/releases/latest/download/operator.yaml
```

This installs the CRDs and the operator into the `reflex` namespace
(created if missing). `operator.yaml` is rendered from `config/default`
and republished on every push to main, so it always matches the `main`
operator image.

Then create your `EDA` custom resource. The operator watches its own
namespace only, so the CR must go in `reflex` too:

```yaml
# reflex.yaml
apiVersion: eda.ansible.com/v1alpha1
kind: EDA
metadata:
  name: reflex
  namespace: reflex
spec:
  automation_server_url: https://your-ascender-or-awx-host
```

```bash
kubectl apply -f reflex.yaml
```

See the [README](../README.md) for configuring the `spec`.

## Upgrading

Back up your instance first by creating an `EDABackup`, then re-apply:

```bash
kubectl apply --server-side --force-conflicts -f https://github.com/reflex-automation/reflex-operator/releases/latest/download/operator.yaml
```

Watch the rollout with `kubectl -n reflex get pods`. If you are upgrading
over an install made before the `reflex-operator-*` rename, see the
cleanup note in the [README](../README.md#install).

## Cleanup

```bash
kubectl delete -f https://github.com/reflex-automation/reflex-operator/releases/latest/download/operator.yaml
```
