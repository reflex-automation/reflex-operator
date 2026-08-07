# Reflex Operator

A Kubernetes operator that deploys and manages Reflex, a
community-maintained continuation of Event-Driven Ansible (EDA) targeting
open-source AWX-compatible controllers, mainly
[CIQ Ascender](https://ciq.com/products/ascender).

Friendly fork of
[ansible/eda-server-operator](https://github.com/ansible/eda-server-operator),
built with [Operator SDK](https://github.com/operator-framework/operator-sdk)
and Ansible. It deploys
[reflex-server](https://github.com/reflex-automation/reflex-server) and
[reflex-ui](https://github.com/reflex-automation/reflex-ui) via an `EDA`
custom resource. The CRD keeps its upstream kind and group
(`eda.ansible.com/v1alpha1`) so merges stay clean; resource names come
from the CR name, so instances can be called anything.

## What Reflex changes

- Default images point at
  `ghcr.io/reflex-automation/{reflex-server,reflex-ui}:main` instead of
  the stale `quay.io/ansible/*` ones.
- Deployed from HEAD with published images, so there is no waiting on
  upstream releases. This matters: reflex-server needs PostgreSQL 14+
  (default here is 15) and the `EDA_WORKER_KIND=websocket` wiring for
  rulebook websocket auth. Both are missing from the last upstream
  release (v1.0.2).

## Install

With a running Kubernetes cluster (k3s works fine):

```bash
kubectl apply --server-side -k config/default
```

`--server-side` is needed because the CRD exceeds client-side annotation
limits. Add `--force-conflicts` when upgrading over a previous install.

By default this installs into the `eda-server-operator-system` namespace.
Use a kustomize overlay to change the namespace, or apply a pre-rendered
manifest.

## Deploy an instance

```yaml
# reflex.yaml
apiVersion: eda.ansible.com/v1alpha1
kind: EDA
metadata:
  name: reflex
  namespace: reflex
spec:
  automation_server_url: https://your-ascender-or-awx-host
  image_pull_policy: Always
```

```bash
kubectl create namespace reflex
kubectl apply -f reflex.yaml
```

`automation_server_url` points at your Ascender/AWX API host. Create an
access token there for rulebook actions
([docs](./docs/create-awx-token.md)).

The admin password is generated in the `<name>-admin-password` secret:

```bash
kubectl -n reflex get secret reflex-admin-password \
  -o jsonpath="{.data.password}" | base64 --decode ; echo
```

## Advanced configuration

Upstream's docs remain valid for admin accounts, database field
encryption, event streams, external databases, and backups:

- [Admin user, encryption, event streams (upstream README)](https://github.com/ansible/eda-server-operator#advanced-configuration)
- [EDA application settings](./docs/user-guide/advanced-configuration/settings.md)
- [Database configuration](./docs/user-guide/database-configuration.md)
- [Trusting a custom CA](./docs/user-guide/advanced-configuration/trusting-a-custom-certificate-authority.md)
- [No Log](./docs/user-guide/advanced-configuration/no-log.md)

For standalone use you may also want:

```yaml
spec:
  extra_settings:
    # let Reflex manage users/teams/orgs itself (no AAP gateway)
    - setting: EDA_ALLOW_LOCAL_RESOURCE_MANAGEMENT
      value: true
    # public URL for inbound event streams, if used
    - setting: EDA_EVENT_STREAM_BASE_URL
      value: "https://your-public-host/eda-event-streams"
```

## License and attribution

Based on
[ansible/eda-server-operator](https://github.com/ansible/eda-server-operator),
© Red Hat, Inc. and contributors (published under an Apache-2.0 badge;
upstream currently lacks a LICENSE file). Reflex is a community project
and is not affiliated with or endorsed by Red Hat. "Ansible" is a
trademark of Red Hat, Inc.
