# Automize the handling of the image

As you work with this Singularity image, you may need to manage multiple versions over time. Automating the creation, updating, and deployment processes from the beginning can save time and reduce errors.

## Makefile

A ``Makefile`` can help automate the restart, build, and deployment steps of your image management process. Below is the ``Makefile`` along with a description of its various options:

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

## Makefile Options Explained

   1. all:
    This is the default target that runs when you simply type make. It sequentially executes the restart, build, and deploy targets. This option is a convenient way to manage the entire process in one go.

   2. restart:
    This target handles the sandbox environment, which is used to create the image. If the sandbox directory ``$(SANDBOX_DIR)`` already exists, it replaces it's contents; otherwise, it creates a new one. The sandbox is essentially a writable container that you can modify before building the final image.
        Key command: ``sudo apptainer build --sandbox $(SANDBOX_DIR) $(DEFINITION_FILE)``

   3. build:
    This target builds the final Singularity image ``$(IMAGE_NAME)`` from the sandbox. The image is therfore created from the definition file or the modified sandbox, depending on the state of your sandbox. I recommend to add all changes you apply to the sandbox to the definition file, too!
        Key command: ``sudo apptainer build $(IMAGE_NAME) $(SANDBOX_DIR)``

   4. deploy:
    This target copies the final image to the specified deployment directory ``$(DEPLOY_DIR)``. This is useful for moving the image to a location where it can be accessed and used by others.
        Key command: ``cp $(IMAGE_NAME) $(DEPLOY_DIR)``

   5. clean:
    This target removes the sandbox directory and the image file. It's useful for cleaning up your workspace if you need to start fresh or if you're done with the current build.
        Key command: ``rm -rf $(SANDBOX_DIR) $(IMAGE_NAME``

## Test scripts

While developing with this image, it's helpful to have scripts for quickly starting the sandbox or the image itself.

I've created two scripts, shell.sh and run.sh, named after the Apptainer functions they utilize:

1. 'shell.sh' - Opens an interactive shell within the sandbox. [shell.sh](./image/shell.sh)
2. 'run.sh' - Runs the image as defined in the definition file's runscript section. [run.sh](./image/run.sh)

These scripts are written in Bash and are capable of detecting the directory from which they are called, making them convenient for starting your image from any location, such as your data directory.


# Next Step: Deployment

For detailed instructions on deploying your image, refer to [the Deploy Guide](./DEPLOY.md).


