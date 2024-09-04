# **Creating an Apptainer Image for Bioinformatics**

## **Introduction to Apptainer**

Apptainer (formerly known as Singularity) is a powerful containerization tool tailored for scientific and high-performance computing (HPC) environments. Unlike other containerization platforms like Docker, Apptainer is designed with security in mind, allowing users to run containers without needing elevated privileges. This makes it an excellent choice for bioinformaticians working on shared or secure systems.

Containers encapsulate software environments, including libraries, dependencies, and the application itself, ensuring reproducibility and ease of deployment. This is especially valuable in bioinformatics, where software dependencies can be complex and challenging to manage.

In this tutorial, you'll learn how to create an Apptainer image tailored for bioinformatics workflows, focusing on Python and R packages, and configuring the image to run Jupyter Notebooks by default.

## **Step 1: Installing Apptainer**

Before you begin, ensure that Apptainer is installed on your system. You can download and install it from the [Apptainer website](https://apptainer.org/). If you are using a shared server, your system administrator may have already installed it.

## **Step 2: Create an Apptainer Definition File**

The first step in creating an Apptainer image is to write a definition file. This file outlines the base operating system, packages, and environment configurations needed for your image. Below is a sample definition file for a bioinformatics workflow that includes Python, R, and Jupyter Notebook with R bindings.

Create a file named `Bioinformatics.def`:

```plaintext
Bootstrap: docker
From: ubuntu:22.04

%labels
    Author: Your Name
    Version: 1.0
    Description: Apptainer image for bioinformatics with Python, R, and Jupyter

%post
    # do not ask any question while installing the packages
    export DEBIAN_FRONTEND=noninteractive
    # do not use my home folder to install python packages - like ever!
    export PYTHONNOUSERSITE="true"

    # Update and install basic dependencies
    apt-get update && apt-get install -y \
        python3 \
        python3-pip \
        r-base \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        pandoc \
        git \
        wget

    # Install Python packages
    pip3 install --upgrade pip
    pip3 install \
        jupyter \
        notebook \
        numpy \
        pandas \
        matplotlib \
        seaborn

    # Install R packages
    R -e "install.packages(c('IRkernel', 'ggplot2', 'dplyr', 'tidyr', 'biocManager'), repos='https://cloud.r-project.org/')"
    R -e "IRkernel::installspec()"

    # Clean up
    apt-get clean

%environment
    # Set environment variables
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    export PYTHONNOUSERSITE="true"

%runscript
    # This will be executed when the container runs
    jupyter notebook --ip=0.0.0.0 --no-browser --allow-root

%startscript
    # This will be executed when the container starts as a service
 CharSet="jupyter notebook --ip=0.0.0.0 --no-browser --allow-root"
```

**Explanation:**

- **Bootstrap and From:** The container will be built from an Ubuntu 22.04 base image, sourced from Docker Hub.
- **%labels:** Metadata about the container (author, version, etc.).
- **%post:** Commands that install Python, R, Jupyter, and necessary packages. The `IRkernel` package is installed to enable R in Jupyter Notebooks.
- **%environment:** Sets the environment variables.
- **%runscript:** Defines the default command when running the container (`jupyter notebook` in this case).
- **%startscript:** Similar to `runscript`, but used when the container starts as a service.

## **Step 3: Build the Apptainer Image**

With your definition file ready, you can now build the Apptainer image. There are two primary methods to build an image: directly building an `.sif` file or creating a writable sandbox.

1. **Build a Compressed Image (.sif):**

    ```sh
    sudo apptainer build Bioinformatics_v1.0.sif Bioinformatics.def
    ```

   This command creates a compressed, immutable image file (`Bioinformatics.sif`).

2. **Create a Writable Sandbox:**

   If you want to modify the container interactively, you can create a sandbox, which is a writable directory containing the container’s filesystem:

    ```sh
    sudo apptainer build --sandbox Bioinformatics/ Bioinformatics.def
    ```

   This creates a directory called `Bioinformatics/` that you can modify.

## **Step 4: Modify the Sandbox (Optional)**

If you created a sandbox, you can enter it and make changes:

```sh
sudo apptainer shell --writable Bioinformatics/
```

Inside the container, you can install additional packages or modify configurations. Once done, you can exit the container with the `exit` command.

## **Step 5: Running the Container**

To run the container and start Jupyter Notebook, use:

```sh
apptainer run Bioinformatics.sif
```

Or if you are using the sandbox:

```sh
apptainer run Bioinformatics/
```

This will start a Jupyter Notebook server, accessible via your web browser. The notebook will be running with both Python and R support, allowing you to interact with your bioinformatics tools directly from the web interface.

## **Step 6: Accessing Jupyter Notebook**

When you run the container, Jupyter Notebook will output a URL containing a token, something like:

```plaintext
http://<server name>:8888/?token=<token>
```

Copy and paste this URL into your web browser to start working with your bioinformatics notebooks.


## Next - Automate the Image Creation

For more information, check out the [Automation Guide](./AUTOMATION.md).