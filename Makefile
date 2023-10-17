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
FW_VERSION_FILE := ../../fw_version.txt
FW_VERSION ?= $(shell cat ${FW_VERSION_FILE})
FW_APP_VERSION := v$(VERSION)
REPO_URL=https://robustintelligence.github.io/helm
REPO_FW_URL=https://robustintelligence.github.io/helm/fw

OPERATOR_ROLE_FILE := $(shell pwd)/rime-agent/templates/operator/role.yaml
CRD_DIR := $(shell pwd)/rime-agent/crds
CROSSPLANE_CRD_FILE_NAME := rbst.io_crossplanerpcjobs.yaml
CROSSPLANE_CRD_FILE := $(CRD_DIR)/$(CROSSPLANE_CRD_FILE_NAME)
RIMEJOB_CRD_FILE_NAME := rbst.io_rimejobs.yaml
RIMEJOB_CRD_FILE := $(CRD_DIR)/$(RIMEJOB_CRD_FILE_NAME)

.PHONY: clean .tmp-charts/rime  .tmp-charts/rime-agent  .tmp-charts/rime-extras .tmp-charts/rime-kube-system .tmp-charts/ri-firewall

clean-rime:
	rm -rf .tmp-charts/
	rm -rf .rime-releases/

clean-firewall:
	rm -rf .tmp-charts/
	rm -rf .firewall-releases/

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
		cp -rf "rime-agent/templates/." ".tmp-charts/rime-agent/templates/." \
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
create_rime_charts_release: clean-rime .rime-releases/index.yaml

### Operator manfiest files for rime-agent helm chart ###
gen_operator_manifests: $(CROSSPLANE_CRD_FILE) $(RIMEJOB_CRD_FILE) $(OPERATOR_ROLE_FILE)

define generate_crds
	cd ../.. && make gen_go_protos
	cd ../../go/dataplane/operator && \
	controller-gen crd paths="./..." output:crd:stdout output:crd:dir=$(1)
endef

$(CROSSPLANE_CRD_FILE) $(RIMEJOB_CRD_FILE): $(CRD_DIR) ../../go/dataplane/operator/api/v1/rimejob.go ../../go/dataplane/operator/api/v1/crossplanerpcjob.go ../../go/dataplane/operator/api/v1/groupversion_info.go
	$(call generate_crds,$(CRD_DIR))

crd_diff_check:
	$(eval $@_TMP := $(shell mktemp -d /tmp/crdXXXXXXXXXXXXXXX))
	$(call generate_crds,$($@_TMP))
	diff $(CROSSPLANE_CRD_FILE) $($@_TMP)/$(CROSSPLANE_CRD_FILE_NAME) || (echo 'ERROR: Cross Plane CRD needs update' && rm -rf $($@_TMP) && exit 1)
	diff $(RIMEJOB_CRD_FILE) $($@_TMP)/$(RIMEJOB_CRD_FILE_NAME) || (echo 'ERROR: Rime Job CRD needs update' && rm -rf $($@_TMP) && exit 1)
	rm -rf $($@_TMP)

# CRD is generated into a subdirectory called 'crds' so that helm will skip if already installed
# as CRDs are cluster scope.
# https://helm.sh/docs/chart_best_practices/custom_resource_definitions/
$(CRD_DIR):
	mkdir -p $@

define generate_operator_role
	cd ../.. && make gen_go_protos
	cd ../../go/dataplane/operator && \
	controller-gen rbac:roleName="PLACEHOLDER_ROLE_NAME" paths="./..." output:rbac:stdout | sed 's/PLACEHOLDER_ROLE_NAME/{{ include "rime-agent.fullname" . }}-{{ .Values.rimeAgent.operator.name }}-role/1' > $(1)
	echo '{{- if .Values.rimeAgent.operator.serviceAccount.create -}}' | cat - $(1) > temp.yaml && mv temp.yaml $(1) && \
	echo '{{- end }}' >> $(1)
endef

$(OPERATOR_ROLE_FILE): ../../go/dataplane/operator/controllers/rimejob_controller.go
	$(call generate_operator_role,$(OPERATOR_ROLE_FILE))

operator_role_diff_check:
	$(eval $@_TMP := $(shell mktemp /tmp/operator-roleXXXXXXXXXXXXXXX))
	$(call generate_operator_role,$($@_TMP))
	diff $(OPERATOR_ROLE_FILE) $($@_TMP) || (echo 'ERROR: Operator role needs update' && rm -rf $($@_TMP) && exit 1)
	rm -rf $($@_TMP)

# Rules to create .tmp-charts by copying only the chart files.
.tmp-charts/ri-firewall: .tmp-charts/ri-firewall/Chart.yaml .tmp-charts/ri-firewall/Chart.lock .tmp-charts/ri-firewall/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard ri-firewall/templates/*.*)) $(patsubst %, .tmp-charts/%, $(wildcard ri-firewall/charts/*.tgz))
	( \
		cp -rf "ri-firewall/templates/." ".tmp-charts/ri-firewall/templates/." \
	)

# Rules to create a firewall release tar-balls for the
# for the given VERSION.
.firewall-releases/rime-extras-$(FW_VERSION).tgz: .tmp-charts/rime-extras
	( \
		$(call check_defined, FW_APP_VERSION FW_VERSION, helm chart version) \
		mkdir -p .firewall-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(FW_APP_VERSION) --version=$(FW_VERSION) --destination=../.firewall-releases rime-extras && \
		popd \
	)

.firewall-releases/rime-kube-system-$(FW_VERSION).tgz: .tmp-charts/rime-kube-system
	( \
		$(call check_defined, FW_APP_VERSION FW_VERSION, helm chart version) \
		mkdir -p .firewall-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(FW_APP_VERSION) --version=$(FW_VERSION) --destination=../.firewall-releases rime-kube-system && \
		popd \
	)

# Rules to create a release tar-ball for the firewall chart in .tmp-charts
# for the given VERSION.
.firewall-releases/ri-firewall-$(FW_VERSION).tgz: .tmp-charts/ri-firewall
	( \
		$(call check_defined, FW_APP_VERSION FW_VERSION, helm chart version) \
		mkdir -p .firewall-releases && \
		pushd .tmp-charts/ && \
		helm package --app-version=$(FW_APP_VERSION) --version=$(FW_VERSION) --destination=../.firewall-releases ri-firewall && \
		popd \
	)

# Rule to update the release index with metadata about release VERSION.
.firewall-releases/index.yaml: .firewall-releases/ri-firewall-$(FW_VERSION).tgz .firewall-releases/rime-extras-$(FW_VERSION).tgz .firewall-releases/rime-kube-system-$(FW_VERSION).tgz
	( \
		mkdir -p .firewall-releases && \
		pushd .firewall-releases/ && \
		helm repo index --url=$(REPO_FW_URL) . && \
		popd \
	)

# Creates a new RI firewall Helm chart release.
create_firewall_charts_release: clean-firewall .firewall-releases/index.yaml
