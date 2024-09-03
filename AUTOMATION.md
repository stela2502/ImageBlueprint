# Automize the handling of the image

I foresee you needing multiple versions of this singularity image over time.
Therfore it is helpful to automize as much as possible right from the start.

## Makefile

We can create a makefile to automize the restart, build and deploy steps:

```text
# Variables
VERSION := 1.0
IMAGE_NAME := Bioinformatics_v${VERSION}.sif
SANDBOX_DIR := Bioinformatics
DEFINITION_FILE := Bioinformatics.def
DEPLOY_DIR := /path/to/deploy/directory

# Phony targets are not actual files, but represent actions
.PHONY: all restart build deploy clean

# Default target - runs all the steps
all: restart build deploy

# Restart the sandbox - creates or updates the sandbox
restart:
	@echo "Restarting sandbox..."
	@if [ -d $(SANDBOX_DIR) ]; then \
		echo "Updating existing sandbox..."; \
	else \
		echo "Creating new sandbox..."; \
	fi
	sudo apptainer build --sandbox $(SANDBOX_DIR) $(DEFINITION_FILE)

# Build the .sif image from the definition file or sandbox
build:
	@echo "Building $(IMAGE_NAME) from $(SANDBOX_DIR)..."
	sudo apptainer build $(IMAGE_NAME) $(SANDBOX_DIR)

# Deploy the image by copying it to the deployment directory
deploy:
	@echo "Deploying $(IMAGE_NAME) to $(DEPLOY_DIR)..."
	cp $(IMAGE_NAME) $(DEPLOY_DIR)

# Clean up the sandbox and image
clean:
	@echo "Cleaning up..."
	rm -rf $(SANDBOX_DIR)
	rm -f $(IMAGE_NAME)

```

## Test scripts

While working with this image on your dev-platform it is helpful to have scripts that can start the sandbox as well as the image.

I am using a run.sh and shell.sh named by the apptiner functions they use:

1. 'shell' the image [shell.sh](./image/shell.sh)
2. 'run' the image [run.sh](./image/run.sh)

These scripts use bash and are able to detect the path they are called from. Very useful if you start your image from your data directory...



## Next - deploy

For more information, check out the [Deploy Guide](./DEPLOY.md).


