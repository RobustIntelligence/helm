# vim: filetype=make
include ../../make_utils/env-var.mk

# General configurations of make options.
MAKEFLAGS += --no-print-directory

# Creates a Helm chart releases:
# See: https://helm.sh/docs/topics/chart_repository/
#
# To create a new release of the RIME chart:
#   1. Run `make VERSION=##.##.## APP_VERSION=v## create_rime_charts_release`
#
# To create a new release of the Firewall chart:
#   1. Run `make create_firewall_charts_release`

SHELL = /bin/bash

VERSION_FILE := ../../version.txt
VERSION ?= $(shell cat ${VERSION_FILE})
APP_VERSION := v$(VERSION)
FW_VERSION_FILE := ../../fw_version.txt
FW_VERSION ?= $(shell cat ${FW_VERSION_FILE})
FW_APP_VERSION := v$(FW_VERSION)
REPO_URL=https://robustintelligence.github.io/helm
REPO_FW_URL=https://robustintelligence.github.io/helm/fw

RIME_AGENT_OPERATOR_ROLE_FILE := $(shell pwd)/rime-agent/templates/operator/role.yaml
# We use absolute paths for the CRD_OUT_DIR paths because `controller-gen` is
# run in the OPERATOR_DIR working directory, which is in `go/`.
# It is easier to reason about an absolute path than a relative path from a
# different project directory.
# The OPERATOR_DIR is a relative path from this Makefile because we use it to
# change directory to where the operator code is defined.
RIME_AGENT_CRD_OUT_DIR := $(shell pwd)/rime-agent/crds
RIME_AGENT_OPERATOR_DIR :=  ../../go/dataplane/operator
# TODO(PINT-3257): include the RI Firewall CRDs in the Helm chart.
RI_FIREWALL_CRD_OUT_DIR := $(shell pwd)/../../_out/firewallcrds
RI_FIREWALL_OPERATOR_DIR := ../../go/generativefirewall/operator

MAKEFLAGS += --no-print-directory

define release_targets
	$(patsubst %,.tmp-charts/%,$(shell find $(1) -type f -name '*.yaml' -o -name '*.tpl' -o -name '*.md' -o -name '*.txt'))
endef

.SECONDARY:
.SECONDEXPANSION:
.PHONY: clean-firewall clean-rime

clean-rime:
	rm -rf .tmp-charts/
	rm -rf .rime-releases/

clean-firewall:
	rm -rf .tmp-charts/
	rm -rf .firewall-releases/

.tmp-charts/%.yaml: %.yaml
	@mkdir -p $(@D)
	cp $< $@

.tmp-charts/%.tpl: %.tpl
	@mkdir -p $(@D)
	cp $< $@

.tmp-charts/%.txt: %.txt
	@mkdir -p $(@D)
	cp $< $@

.tmp-charts/%.md: %.md
	@mkdir -p $(@D)
	cp $< $@

# Rules to create .tmp-charts by copying only the chart files.
.tmp-charts/%: $$(call release_targets,$$(@F))
	@cd $@ && \
		helm dependency update

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

### Operator manifest files for RI Helm charts ###
.PHONY: gen_operator_manifests
gen_operator_manifests: gen_rime_agent_crds gen_ri_firewall_crds $(RIME_AGENT_OPERATOR_ROLE_FILE)

# CRD is generated into a subdirectory called 'crds' so that helm will skip if already installed
# as CRDs are cluster scope.
# https://helm.sh/docs/chart_best_practices/custom_resource_definitions/
$(RIME_AGENT_CRD_OUT_DIR):
	@mkdir -p $@

$(RI_FIREWALL_CRD_OUT_DIR):
	@mkdir -p $@

define generate_crds
	@cd ../.. && make gen_go_protos
	@cd $(1) && \
	controller-gen crd paths="./..." output:crd:stdout output:crd:dir=$(2)
endef

.PHONY: gen_rime_agent_crds
gen_rime_agent_crds: $(wildcard ../../go/dataplane/operator/api/v1/*.go) $(RIME_AGENT_CRD_OUT_DIR)
	$(call generate_crds,$(RIME_AGENT_OPERATOR_DIR),$(RIME_AGENT_CRD_OUT_DIR))

.PHONY: gen_ri_firewall_crds
gen_ri_firewall_crds: $(wildcard ../../go/generativefirewall/operator/api/v1/*.go) $(RI_FIREWALL_CRD_OUT_DIR)
	$(call generate_crds,$(RI_FIREWALL_OPERATOR_DIR),$(RI_FIREWALL_CRD_OUT_DIR))

# TODO(PINT-3257): extend the diff-check to cover Firewall CRDs.
.PHONY: crd_diff_check
crd_diff_check:
	$(eval $@_TMP := $(shell mktemp -d /tmp/crdXXXXXXXXXXXXXXX))
	$(call generate_crds,$(RIME_AGENT_OPERATOR_DIR),$($@_TMP))
	@diff $(RIME_AGENT_CRD_OUT_DIR) $($@_TMP) || (echo 'ERROR: RIME Agent CRDs need to be updated' && rm -rf $($@_TMP) && exit 1)
	@rm -rf $($@_TMP)

define generate_operator_role
	cd ../.. && make gen_go_protos
	cd ../../go/dataplane/operator && \
	controller-gen rbac:roleName="PLACEHOLDER_ROLE_NAME" paths="./..." output:rbac:stdout | sed 's/PLACEHOLDER_ROLE_NAME/{{ include "rime-agent.fullname" . }}-{{ .Values.rimeAgent.operator.name }}-role/1' > $(1)
	echo '{{- if .Values.rimeAgent.operator.serviceAccount.create -}}' | cat - $(1) > temp.yaml && mv temp.yaml $(1) && \
	echo '{{- end }}' >> $(1)
endef

$(RIME_AGENT_OPERATOR_ROLE_FILE): ../../go/dataplane/operator/controllers/rimejob_controller.go
	$(call generate_operator_role,$(RIME_AGENT_OPERATOR_ROLE_FILE))

# TODO(PINT-3233): extend the diff-check to cover Firewall operator roles.
operator_role_diff_check:
	$(eval $@_TMP := $(shell mktemp /tmp/operator-roleXXXXXXXXXXXXXXX))
	$(call generate_operator_role,$($@_TMP))
	diff $(RIME_AGENT_OPERATOR_ROLE_FILE) $($@_TMP) || (echo 'ERROR: Operator role needs update' && rm -rf $($@_TMP) && exit 1)
	rm -rf $($@_TMP)

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
		$(call check_defined, APP_VERSION VERSION, helm chart version) \
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
