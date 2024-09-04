# Deploying the singularity image on COSMOS

COSMOS uses the module system to manage and load software, making it an ideal platform for deploying Singularity images. By leveraging the module system, we can share our images more effectively, reducing the workload for everyone involved.

For most of this tutorial, I’ve used ChatGPT to assist in creating the content, including the script below:

[generate_module.sh](generate_module.sh).

This script generates the necessary module file based on the deployment path, version, and tool name:

```bash
./generate_module.sh <deploy path> 1.0 Bioinformatics
```

Since all relevant information is centralized in the ``Makefile``, it is best to manage and maintain this information there to ensure consistency and ease of updates.


```text
# Variables
VERSION := 1.0
IMAGE_NAME := Bioinformatics_v$(VERSION).sif
SANDBOX_DIR := Bioinformatics
DEFINITION_FILE := Bioinformatics.def

# Assuming COSMOS shared folders are mounted in $(HOME)/sens05_shared on the development computer
# Paths on the development computer where the image will be deployed
DEPLOY_DIR := $(HOME)/sens05_shared/common/software/$(SANDBOX_DIR)/$(VERSION)
MODULE_FILE := $(HOME)/sens05_shared/common/modules/$(SANDBOX_DIR)/$(VERSION).lua

# Path on COSMOS where the image will be stored
SERVER_DIR := /scale/gr01/shared/common/software/$(SANDBOX_DIR)/$(VERSION)

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
	@mkdir -p $(DEPLOY_DIR)
	rsync -avh --no-perms --no-owner --no-group --progress $(IMAGE_NAME) $(DEPLOY_DIR)
	@mkdir -p $(dir $(MODULE_FILE))
	@if [ ! -f $(MODULE_FILE) ]; then \
		$(CURDIR)/generate_module.sh $(SERVER_DIR) $(VERSION) $(SANDBOX_DIR) > $(MODULE_FILE);\
	fi

# Clean up the sandbox and image
clean:
	@echo "Cleaning up..."
	rm -rf $(SANDBOX_DIR)
	rm -f $(IMAGE_NAME)
```

# Final Steps

Before creating your own images, be sure to update the ``SANDBOX_DIR`` variable in your ``Makefile`` to match your specific project.

If you’re not already using the shared modules on COSMOS, you can add the necessary line to your ``~/.bash_profile`` like this:

```bash
echo 'module use /scale/gr01/shared/common/modules' >> ~/.bash_profile
```

I hope this guide is as helpful for you as it has been for me! :-)
