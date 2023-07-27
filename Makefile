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
REPO_URL=gs://rime-backend-helm-repository

.PHONY: clean .tmp-charts/rime  .tmp-charts/rime-agent  .tmp-charts/rime-extras .tmp-charts/rime-kube-system

clean:
	rm -rf .tmp-charts/

# Rule to copy a file to .tmp-charts/
.tmp-charts/%: %
	mkdir -p $(@D)
	cp $< $@

# Rules to create .tmp-charts by copying only the chart files.
.tmp-charts/rime: .tmp-charts/rime/Chart.yaml .tmp-charts/rime/Chart.lock .tmp-charts/rime/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard rime/templates/*.*)) $(patsubst %, .tmp-charts/%, $(wildcard rime/charts/*.tgz)) $(patsubst %, .tmp-charts/%, $(wildcard rime/custom-key-auth/*.*))

.tmp-charts/rime-agent: .tmp-charts/rime-agent/Chart.yaml .tmp-charts/rime-agent/values.yaml $(patsubst %, .tmp-charts/%, $(wildcard rime-agent/templates/*.*))

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

# Builds and pushes a new RIME Helm chart to GCS.
# You must be logged in to GCS (see README.md).
push_rime_charts_release: create_rime_charts_release
	$(call check_defined, VERSION, helm chart version)
	helm repo add rime $(REPO_URL)
	helm repo update
	env | sort
ifeq ($(DO_PUBLISH), true)
	echo "INFO: Push Helm charts into GCS"
	helm gcs push .rime-releases/rime-$(VERSION).tgz rime
	helm gcs push .rime-releases/rime-agent-$(VERSION).tgz rime
	helm gcs push .rime-releases/rime-extras-$(VERSION).tgz rime
	helm gcs push .rime-releases/rime-kube-system-$(VERSION).tgz rime
	helm repo update
else
	echo "WARNING: Not push Helm charts into GCS per DO_PUBLISH"
endif
