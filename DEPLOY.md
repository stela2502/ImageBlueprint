# Deploying the singularity image on COSMOS

COSMOS uses the module system to load software. It would make sense if you would use the module system to deploy your signuarity images.
This way we can share our images and therby hopefully reduce the amount of work each of us need to invest.

I have used ChatGPT for the creation of most of this tutorial and also for the next script:

[generate_module.sh](generate_module.sh).

This script takes the deploy path, the version of the package and the name of the tool as options:

```bash
./generate_module.sh <deploy path> 1.0 Bioinformatics
```

All of this information is known to the Makefile. So the best would be to call this script from within the makefile:

```text
# Variables
VERSION := 1.0
IMAGE_NAME := Bioinformatics_v${VERSION}.sif
SANDBOX_DIR := Bioinformatics
DEFINITION_FILE := Bioinformatics.def
# assuming you mount COSMOS shared folders in $HOME/sens05_shared like me ;-)
DEPLOY_DIR := $HOME/sens05_shared/common/software/$SANDBOX_DIR/$VERSION
MODULE_FILE := $HOME/sens05_shared/common/modules/$SANDBOX_DIR/$VERSION.lua

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
	if [ ! -f $(MODULE_FILE) ]; then \
		./generate_module $(DEPLOY_DIR) $(VERSION) $(SANDBOX_DIR) > $(MODULE_FILE) \
	fi

# Clean up the sandbox and image
clean:
	@echo "Cleaning up..."
	rm -rf $(SANDBOX_DIR)
	rm -f $(IMAGE_NAME)

```

# Finish

Before you create your own images please change the SANDBOX_DIR variable in your Makefile!

I hope this helps you as much as it hepls me ;-)

