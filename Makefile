# Makefile to initialize all environments
.PHONY: all clean clean-% $(ENVS) %-activate print-%

ENVS := $(shell find . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \;)
TARGETS := $(foreach env,$(ENVS),$(env)/.venv)
UV_EXIST := $(shell command -v uv 2> /dev/null)

all: $(ENVS)

$(ENVS): %: %/.venv

$(TARGETS): %: $(wildcard %/requirements.txt) $(wildcard %/pyproject.toml)
	if [ -z "$(UV_EXIST)" ]; then \
		echo "uv not found, please install it first"; \
		echo " See https://docs.astral.sh/uv/getting-started/installation/#installation-methods"; \
		exit 1; \
	fi
	@echo "Initializing environment: $(@D)"
	cd $(@D) && uv venv
	cd $(@D) && . .venv/bin/activate && \
	if [ -f requirements.txt ]; then \
		uv pip install -r requirements.txt; \
	elif [ -f pyproject.toml ]; then \
		uv pip install --editable .; \
	else \
		echo "No requirements.txt or pyproject.toml found in $(@D)"; \
		exit 1; \
	fi

clean-%:
	@echo "Cleaning environment: $@"
	rm -rf $@/.venv
	rm -rf $@/__pycache__
	rm -rf $@/*.egg-info
	rm -rf $@/*.egg
	rm -rf $@/*.whl
	rm -rf $@/*.dist-info
	rm -rf $@/*.pyc

clean:
	@echo "Cleaning all environments"
	for env in $(ENVS); do \
		rm -rf $$env/.venv; \
		rm -rf $$env/__pycache__; \
		rm -rf $$env/*.egg-info; \
		rm -rf $$env/*.egg; \
		rm -rf $$env/*.whl; \
		rm -rf $$env/*.dist-info; \
		rm -rf $$env/*.pyc; \
	done

%-activate: $@
	@echo "Activating environment: $@"
	@echo "Run 'source $@/.venv/bin/activate' to activate the virtual environment"

# For debugging variables in Makefile, e.g. by "make print-PYTHON_INCLUDES"
print-%  : ; @echo $* = $($*)
