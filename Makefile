# Makefile to initialize all environments
.PHONY: all $(ENVS)

ENVS := $(shell find . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \;)

all: $(ENVS)

$(ENVS): $(wildcard %/requirements.txt) $(wildcard %/pyproject.toml)
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
