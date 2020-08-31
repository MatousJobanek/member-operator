GIT_COMMIT_ID := $(shell git rev-parse HEAD)
ifneq ($(shell git status --porcelain --untracked-files=no),)
    ifeq (${IGNORE_DIRTY},)
       GIT_COMMIT_ID := $(GIT_COMMIT_ID)-dirty
    endif
endif

GIT_COMMIT_ID_SHORT := $(shell git rev-parse --short HEAD)
ifneq ($(shell git status --porcelain --untracked-files=no),)
    ifeq (${IGNORE_DIRTY},)
       GIT_COMMIT_ID_SHORT := $(GIT_COMMIT_ID_SHORT)-dirty
    endif
endif

BUILD_TIME = `date -u '+%Y-%m-%dT%H:%M:%SZ'`