# Makefile to initialize all environments
.PHONY: all $(ENVS)

ENVS := $(shell find . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \;)
UV_EXIST := $(shell command -v uv 2> /dev/null)

all: $(ENVS)

$(ENVS): $(wildcard %/requirements.txt) $(wildcard %/pyproject.toml)
	if [ -z "$(UV_EXIST)" ]; then \
		echo "uv not found, please install it first"; \
		echo " See https://docs.astral.sh/uv/getting-started/installation/#installation-methods"; \
		exit 1; \
	fi
	@echo "Initializing environment: $@"
	cd $@ && uv venv
	cd $@ && . .venv/bin/activate && \
	if [ -f requirements.txt ]; then \
		uv pip install -r requirements.txt; \
	elif [ -f pyproject.toml ]; then \
		uv pip install --editable .; \
	else \
		echo "No requirements.txt or pyproject.toml found in $@"; \
	fi

# For debugging variables in Makefile, e.g. by "make print-PYTHON_INCLUDES"
print-%  : ; @echo $* = $($*)
