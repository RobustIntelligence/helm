include ../../make_utils/env-var.mk

# Creates a Helm chart releases:
# See: https://helm.sh/docs/topics/chart_repository/
#
# To create a new release of the RIME chart:
#   1. Ensure the helm dependency versions are correct in rime/charts
#      and/or update with `helm dependency update`
#   2. Run `make VERSION=##.##.## APP_VERSION=v## create_rime_charts_release`

SHELL = /bin/bash

VERSION_FILE := ../../version.txt
VERSION ?= $(shell cat ${VERSION_FILE})
APP_VERSION := v$(VERSION)
REPO_URL=https://robustintelligence.github.io/helm

OPERATOR_ROLE_FILE := rime-agent/templates/operator/role.yaml

.PHONY: clean .tmp-charts/rime  .tmp-charts/rime-agent  .tmp-charts/rime-extras .tmp-charts/rime-kube-system

clean:
	rm -rf .tmp-charts/
	rm -rf .rime-releases/
	rm -rf rime-agent/crds
	rm -rf $(OPERATOR_ROLE_FILE)

# Rule to copy a file to .tmp-charts/
.tmp-charts/%: %
	mkdir -p $(@D)
	cp $< $@

# Rules to create .tmp-charts by copying only the chart files.
.tmp-charts/rime: .tmp-charts/rime/Chart.yaml .tmp-charts/rime/Chart.lock .tmp-charts/rime/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard rime/templates/*.*)) $(patsubst %, .tmp-charts/%, $(wildcard rime/charts/*.tgz)) $(patsubst %, .tmp-charts/%, $(wildcard rime/custom-key-auth/*.*))
	( \
		cp -rf "rime/templates/." ".tmp-charts/rime/templates/." \
	)

.tmp-charts/rime-agent: .tmp-charts/rime-agent/Chart.yaml .tmp-charts/rime-agent/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard rime-agent/templates/*.*)) $(patsubst %, .tmp-charts/%, $(wildcard rime-agent/templates/operator/*.*)) $(patsubst %, .tmp-charts/%, $(wildcard rime-agent/crds/*.*))
	( \
		cp -rf "rime-agent/crds" ".tmp-charts/rime-agent/." && \
		cp "$(OPERATOR_ROLE_FILE)" ".tmp-charts/rime-agent/templates/operator/." \
	)

.tmp-charts/rime-extras: .tmp-charts/rime-extras/Chart.yaml .tmp-charts/rime-extras/Chart.lock .tmp-charts/rime-extras/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard rime-extras/charts/*.tgz))

.tmp-charts/rime-kube-system: .tmp-charts/rime-kube-system/Chart.yaml .tmp-charts/rime-kube-system/Chart.lock .tmp-charts/rime-kube-system/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard rime-kube-system/charts/*.tgz))

# Rules to create a release tar-ball for the rime chart in .tmp-charts
# for the given VERSION.
.rime-releases/rime-$(VERSION).tgz: .tmp-charts/rime
	( \
		$(call check_defined, APP_VERSION VERSION, helm chart version) \
		mkdir -p .rime-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(APP_VERSION) --version=$(VERSION) --destination=../.rime-releases rime && \
		popd \
	)

.rime-releases/rime-agent-$(VERSION).tgz: .tmp-charts/rime-agent
	( \
		$(call check_defined, APP_VERSION VERSION, helm chart version) \
		mkdir -p .rime-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(APP_VERSION) --version=$(VERSION) --destination=../.rime-releases rime-agent && \
		popd \
	)

.rime-releases/rime-extras-$(VERSION).tgz: .tmp-charts/rime-extras
	( \
		$(call check_defined, APP_VERSION VERSION, helm chart version) \
		mkdir -p .rime-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(APP_VERSION) --version=$(VERSION) --destination=../.rime-releases rime-extras && \
		popd \
	)

.rime-releases/rime-kube-system-$(VERSION).tgz: .tmp-charts/rime-kube-system
	( \
		$(call check_defined, APP_VERSION VERSION, helm chart version) \
		mkdir -p .rime-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(APP_VERSION) --version=$(VERSION) --destination=../.rime-releases rime-kube-system && \
		popd \
	)

# Rule to update the release index with metadata about release VERSION.
.rime-releases/index.yaml: .rime-releases/rime-$(VERSION).tgz .rime-releases/rime-agent-$(VERSION).tgz .rime-releases/rime-extras-$(VERSION).tgz .rime-releases/rime-kube-system-$(VERSION).tgz
	( \
		mkdir -p .rime-releases && \
		pushd .rime-releases/ && \
		helm repo index --url=$(REPO_URL) . && \
		popd \
	)

# Creates a new rime Helm chart release.
create_rime_charts_release: clean .rime-releases/index.yaml

### Operator manfiest files for rime-agent helm chart ###
gen_operator_manifests: rime-agent/crds/rimejob-crd.yaml $(OPERATOR_ROLE_FILE)

rime-agent/crds/rimejob-crd.yaml: rime-agent/crds ../../go/dataplane/operator/api/v1/rimejob.go ../../go/dataplane/operator/api/v1/groupversion_info.go
	# TODO: make gen_go_protos a prereq instead
	cd ../.. && make gen_go_protos
	cd ../../go/dataplane/operator && \
	controller-gen crd paths="./..." output:crd:stdout > ../../../deployments/helm/rime-agent/crds/rimejob-crd.yaml

# CRD is generated into a subdirectory called 'crds' so that helm will skip if already installed
# as CRDs are cluster scope.
# https://helm.sh/docs/chart_best_practices/custom_resource_definitions/
rime-agent/crds:
	mkdir -p $@

$(OPERATOR_ROLE_FILE): ../../go/dataplane/operator/controllers/rimejob_controller.go
	# TODO: make gen_go_protos a prereq instead
	cd ../.. && make gen_go_protos
	cd ../../go/dataplane/operator && \
	controller-gen rbac:roleName="PLACEHOLDER_ROLE_NAME" paths="./..." output:rbac:stdout | sed 's/PLACEHOLDER_ROLE_NAME/{{ include "rime-agent.fullname" . }}-{{ .Values.rimeAgent.operator.name }}-role/1' > ../../../deployments/helm/$(OPERATOR_ROLE_FILE)
	echo '{{- if .Values.rimeAgent.operator.serviceAccount.create -}}' | cat - $(OPERATOR_ROLE_FILE) > temp.yaml && mv temp.yaml $(OPERATOR_ROLE_FILE) && \
	echo '{{- end }}' >> $(OPERATOR_ROLE_FILE)
