# Deploying the apptainer image on COSMOS-SENS

COSMOS-SENS uses the module system to manage and load software, making it an ideal platform for deploying Singularity images. By leveraging the module system, we can share our images more effectively, reducing the workload for everyone involved.

The [generate_module.sh](generate_module.sh) script generates the necessary module file based on the deployment path, version, and tool name:

```bash
./generate_module.sh <deploy path> 1.0 Bioinformatics
```

Since all relevant information is centralized in the ``Makefile``, it is best to manage and maintain this information there to ensure consistency and ease of updates.
Focus on the ``DEPLOY_DIR``, ``MODULE_FILE`` and ``SERVER_DIR`` variables and also the ``deploy`` section in the ``Makefile``:


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

The **DEPLOY_DIR** is the path the image chould be copied from. This need to be accessible from my development platform.
The **MODULE_FILE** is the file that represents this modules lua definition. It could be built from the DEPLOY_DIR, but this is more felxible.

The **SERVER_DIR** on the contrary is the location of the image when logged in at the deploy server (here COSMOS-SENS).


## The deploy target in detail:

    1. It starts by printing a message saying the image is being deployed.
    2. It creates the deployment directory if it doesn’t exist.
    3. It uses rsync to copy the image to the deployment directory.
    4. It ensures the directory for the module file exists.
    5. If the module file doesn't already exist, it generates one using the generate_module.sh script.


# Final Steps

Before creating your own images, be sure to update the ``DEPLOY_DIR``, ``MODULE_FILE``and ``SERVER_DIR`` variable in your ``Makefile`` to match your specific project.
Or - if you do not have direct access to the deploy area - deploy to a local folder to at least have all files in the correct position and all names and version corrected before you copy the data to the server.

If you’re not already using our shared modules on COSMOS-SENS, you can add the necessary line to your ``~/.bash_profile`` like this:

```bash
echo 'module use /scale/gr01/shared/common/modules' >> ~/.bash_profile
```

I hope this guide is as helpful for you as it has been for me! :-)

# Further improvements

In typical HPC environments, users don't have sudo privileges, which means they cannot build Apptainer images directly. [ImageSmith](git@github.com:stela2502/ImageSmith.git) addresses this limitation by embedding the necessary logic into an Apptainer image, allowing unprivileged users to build Apptainer images seamlessly in an HPC environment.

The key functionality of ImageSmith is its ability to recreate the complete image development environment with a single command:

```bash
create_new_image_builder.sh <path-to>/<new-image-name>
```

This Bash script automates the setup of a new project directory for building Apptainer images. It creates the directory, copies essential template files (such as shell scripts, a definition file, and a Makefile), and customizes them based on the new image name provided by the user.

The script also ensures that:
- No directory with the same name already exists.
- It provides usage instructions if the required argument is missing.

By using ImageSmith, non-privileged users can develop and build their own Apptainer images on HPC systems without requiring root access, significantly simplifying image creation in restricted environments.

The ImageSmith is installed on the open COSMOS and should be run on the compute nodes:

```text
#!/bin/bash
#SBATCH --ntasks-per-node 1
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -A lu2024-7-5
#SBATCH -J start_Si
#SBATCH -o start_Si.%j.out
#SBATCH -e start_Si.%j.err

ml ImageSmith/1.0

exit 0
```

It is not able to access the /projects folder and therefore you need to build you images in your home directory. Clean up after you got everything as you wanted it ;-)

That ImageSmith is providing a Jupater lab entry point almost as does my Bioinformatics example - ImageSmith does only have a minimum Python and no R installed.

# And the Slurm Module - [what does that do?](./SlurmModule.md)

A really short outlook into the Slurm modules.