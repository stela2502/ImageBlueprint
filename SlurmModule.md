# Different way to interact with your Apptainer image

In order to interact with the images in our server structure (small frontend - large compute nodes), we need to execute the images on the compute nodes.
We normally do not get a shell login at these nodes, so one needs to employ a server-client structure to interact with the image.

It would be possible to start an SSH server in the image and then use a common login to log into them, but that is not secure with a static login. Moreover, it doesn't provide much comfort in usage either.

Therefore, I decided to install Jupyter Lab on the image. Jupyter Lab starts its own server and has a rather secure login (login details will be written to stdout). This server is started when the image is 'run'.

The default installation will hence create this SLURM module file:

```
help([[This module is an example Singularity Image providing  
       a 'naked' Python Jupyter Lab interface to both Python and R ]])

local version = "1.0"
local base = pathJoin("/scale/gr01/shared/common/software/Bioinformatics/1.0")


-- this happens at load
execute{cmd="singularity run -B/scale,/sw ".. base.. "/Bioinformatics_v".. version ..".sif",modeA={"load"}}


-- this happens at unload
-- could also do "conda deactivate; " but that should be part of independent VE module

-- execute{cmd="exit",modeA={"load"}}

whatis("Name         : Bioinformatics singularity image")
whatis("Version      : Bioinformatics 1.0")
whatis("Category     : Image")
whatis("Description  : Singularity image providing Python and R and a jupyter lab as default entry point ")
whatis("Installed on : 04/09/2024 ")
whatis("Modified on  : --- ")
whatis("Installed by : `whomai`")

family("images")

-- Change Module Path
--local mroot = os.getenv("MODULEPATH_ROOT")
--local mdir = pathJoin(mroot,"Compiler/anaconda",version)
--prepend_path("MODULEPATH",mdir)
--
```

I am by far not good with this syntax - I just change the ones I found on COSMOS ;-)

When loaded, this definition file 'runs' the Apptainer image, starting the Jupyter Lab server.

## And when you do not want that?

Apptainer images can also be used to execute commands. But the command looks kind of complicated:

```
apptainer exec <image> <command>
```

And remember that the image for this example is located here:
```
 /scale/gr01/shared/common/software/Bioinformatics/1.0/Bioinformatics_v1.0.sif
```
Not much fun to write that down.

My strategy would be to create a small script that automates the fixed part `apptainer exec <image>` of the Apptainer command and just runs the user's `<command>`:

```
#!/bin/bash

# Path to your Singularity image
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
VERSION=1.0
SINGULARITY_IMAGE="$SCRIPT_DIR/../Rustody_v${VERSION}.sif"

# Check if a command was provided
if [ "$#" -lt 1 ]; then
  echo "Usage: Rustody <command> [options...]"
  echo "With commands being described there: 
  https://github.com/stela2502/Rustody 
  https://github.com/stela2502/bam_aligner
  https://github.com/stela2502/subset_bam
  "
  exit 1
fi

# Run the command inside the Singularity image
singularity exec "$SINGULARITY_IMAGE" "$@"
```

You can see this script is from another of my Apptainer image definitions. 
You can find that [on Github](https://github.com/stela2502/Rustody_image) and on COSMOS.

**And the lua definition file for that?**

This is the important part of the lua file:

```text
prepend_path("PATH", pathJoin( base, 'bin'))
```
And one little add on in the makefile's deploy:
```text
# Deploy the image by copying it to the deployment directory
deploy:
	@echo "Deploying $(IMAGE_NAME) to $(DEPLOY_DIR)..."
	@mkdir -p $(DEPLOY_DIR)
	rsync -avh --no-perms --no-owner --no-group --progress $(IMAGE_NAME) $(DEPLOY_DIR)
	@mkdir -p $(dir $(MODULE_FILE))
	@if [ ! -f $(MODULE_FILE) ]; then \
           $(CURDIR)/generate_module.sh $(SERVER_DIR) $(VERSION) $(SANDBOX_DIR) > $(MODULE_FILE);\
	   mkdir -p $(DEPLOY_DIR)/bin; \
	   cp $(CURDIR)/bin/Rustody $(DEPLOY_DIR)/bin; \
	   sed -i 's/^VERSION=.*/VERSION=${VERSION}/' $(DEPLOY_DIR)/bin/Rustody \
	   chmod +x $(DEPLOY_DIR)/bin/Rustody; \
	fi
```

You see the combination of an apptainer image with a slurm module definition creates a lot of possible usage combinations - PLESE DOCUMENT HOW YOUR MODULE CAN BE USED!!


