
PATH_TO_CD_GENERATE_FILE=scripts/generate-cd-release-manifests.sh
PATH_TO_PUSH_APP_FILE=scripts/push-manifests-as-app.sh
PATH_TO_BUNDLE_FILE=scripts/push-bundle-and-index-image.sh
PATH_TO_RECOVERY_FILE=scripts/recover-operator-dir.sh
PATH_TO_OLM_GENERATE_FILE=scripts/olm-catalog-generate.sh
PATH_TO_PREPARE_BUNDLE_FILE=scripts/prepare-bundle-manifests.sh

TMP_DIR?=/tmp
INDEX_IMAGE?=hosted-toolchain-index
IMAGE_BUILDER ?= docker

.PHONY: push-to-quay-nightly
## Creates a new version of CSV and pushes it to quay
push-to-quay-nightly: generate-cd-release-manifests push-manifests-as-app recover-operator-dir

.PHONY: push-to-quay-staging
## Creates a new version of operator bundle, adds it into an index and pushes it to quay
push-to-quay-staging: generate-cd-release-manifests push-bundle-and-index-image recover-operator-dir

.PHONY: generate-cd-release-manifests
## Generates a new version of operator manifests
generate-cd-release-manifests:
	$(eval CD_GENERATE_PARAMS = -pr ../member-operator/ -qn ${QUAY_NAMESPACE} -td ${TMP_DIR} -ci member-operator-webhook)
ifneq ("$(wildcard ../api/$(PATH_TO_CD_GENERATE_FILE))","")
	@echo "generating manifests for CD using script from local api repo..."
	../api/${PATH_TO_CD_GENERATE_FILE} ${CD_GENERATE_PARAMS}
else
	@echo "generating manifests for CD using script from GH api repo (using latest version in master)..."
	curl -sSL https://raw.githubusercontent.com/codeready-toolchain/api/master/${PATH_TO_CD_GENERATE_FILE} | bash -s -- ${CD_GENERATE_PARAMS}
endif

.PHONY: push-manifests-as-app
## Pushes generated manifests as an application to quay
push-manifests-as-app:
	$(eval PUSH_APP_PARAMS = -pr ../member-operator/ -qn ${QUAY_NAMESPACE} -ch nightly -td ${TMP_DIR})
ifneq ("$(wildcard ../api/$(PATH_TO_PUSH_APP_FILE))","")
	@echo "pushing to quay in nightly channel using script from local api repo..."
	../api/${PATH_TO_PUSH_APP_FILE} ${PUSH_APP_PARAMS}
else
	@echo "pushing to quay in nightly channel using script from GH api repo (using latest version in master)..."
	curl -sSL https://raw.githubusercontent.com/codeready-toolchain/api/master/${PATH_TO_PUSH_APP_FILE} | bash -s -- ${PUSH_APP_PARAMS}
endif

.PHONY: push-bundle-and-index-image
## Pushes generated manifests as a bundle image to quay and adds is to the image index
push-bundle-and-index-image:
ifneq (${BUILDER_ARGS},)
	$(eval BUILDER_ARGS_PARAM = -ba ${BUILDER_ARGS})
endif
	$(eval PUSH_BUNDLE_PARAMS = -pr ../member-operator/ -qn ${QUAY_NAMESPACE} -ch staging -td ${TMP_DIR} -ib ${IMAGE_BUILDER} -im ${INDEX_IMAGE} ${BUILDER_ARGS_PARAM})
ifneq ("$(wildcard ../api/$(PATH_TO_BUNDLE_FILE))","")
	@echo "pushing to quay in staging channel using script from local api repo..."
	../api/${PATH_TO_BUNDLE_FILE} ${PUSH_BUNDLE_PARAMS}
else
	@echo "pushing to quay in staging channel using script from GH api repo (using latest version in master)..."
	curl -sSL https://raw.githubusercontent.com/codeready-toolchain/api/master/${PATH_TO_BUNDLE_FILE} | bash -s -- ${PUSH_BUNDLE_PARAMS}
endif

.PHONY: recover-operator-dir
## Recovers the operator directory from the backup folder
recover-operator-dir:
	$(eval RECOVERY_PARAMS = -pr ../member-operator/ -td ${TMP_DIR})
ifneq ("$(wildcard ../api/$(PATH_TO_RECOVERY_FILE))","")
	@echo "recovering the operator directory from the backup folder using script from local api repo..."
	../api/${PATH_TO_RECOVERY_FILE} ${RECOVERY_PARAMS}
else
	@echo "recovering the operator directory from the backup folder script from GH api repo (using latest version in master)..."
	curl -sSL https://raw.githubusercontent.com/codeready-toolchain/api/master/${PATH_TO_RECOVERY_FILE} | bash -s -- ${RECOVERY_PARAMS}
endif


.PHONY: generate-olm-files
## Regenerates base template CSV and hack files
generate-olm-files:
	$(eval GENERATE_PARAMS = -pr ../member-operator/)
ifneq ("$(wildcard ../api/$(PATH_TO_OLM_GENERATE_FILE))","")
	@echo "generating OLM files using script from local api repo..."
	../api/${PATH_TO_OLM_GENERATE_FILE} ${GENERATE_PARAMS}
else
	@echo "generating OLM files using script from GH api repo (using latest version in master)..."
	curl -sSL https://raw.githubusercontent.com/codeready-toolchain/api/master/${PATH_TO_OLM_GENERATE_FILE} | bash -s -- ${GENERATE_PARAMS}
endif