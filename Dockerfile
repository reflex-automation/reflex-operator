FROM quay.io/operator-framework/ansible-operator:v1.42.3

# pull in CVE fixes newer than the base image
USER 0
RUN microdnf upgrade -y && microdnf clean all \
 && python3 -m ensurepip --upgrade \
 && python3 -m pip install --no-cache-dir --upgrade cryptography pyasn1 \
 && python3 -m pip uninstall -y pip
USER 1001

ARG DEFAULT_EDA_VERSION
ARG DEFAULT_EDA_UI_VERSION
ARG OPERATOR_VERSION
ENV DEFAULT_EDA_VERSION=${DEFAULT_EDA_VERSION}
ENV DEFAULT_EDA_UI_VERSION=${DEFAULT_EDA_UI_VERSION}

ENV OPERATOR_VERSION=${OPERATOR_VERSION}

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/

ENTRYPOINT ["/tini", "--", "/usr/local/bin/ansible-operator", "run", \
     "--watches-file=./watches.yaml", \
     "--reconcile-period=0s" \
     ]
