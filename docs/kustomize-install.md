# Install with Kustomize

Some folks may prefer to install the operator using [kustomize](https://kustomize.io/) directly with a personalized kustomize file. This allows you to modify configuration files including the operator's manager deployment itself. To do so, follow the instructions below.

1. Create a `kustomization.yaml` file with the following contents:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/reflex-automation/reflex-operator/config/default

# Pin the operator image if you don't want the rolling main tag
#images:
#  - name: ghcr.io/reflex-automation/reflex-operator
#    newTag: main

# Specify a custom namespace in which to install the operator.
# The EDA CR must be created in the same namespace.
namespace: reflex
```

2. Then build and apply it by running:

```bash
kubectl apply --server-side -k .
```

> **TIP:** If you need to change any of the default settings for the operator (such as resources.limits), you can add [patches](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patches/) at the bottom of your kustomization.yaml file.
