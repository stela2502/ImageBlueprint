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
From: alpine:latest

%post
    # Update and install essential packages
    apk update && apk add --no-cache \
        bash \
        build-base \
        curl \
        openblas-dev \
        gfortran \
        python3 \
        py3-pip \
        python3-dev \
        py3-setuptools \
        py3-wheel \
        R \
        R-dev \
        R-doc \
        libxml2-dev \
        libcurl \
        curl-dev \
        linux-headers \
        zeromq-dev \
        gcc \
        g++ \
        gfortran \
        libffi-dev \
        openssl-dev \
        make \
        cmake \
        git

    # Allow pip to modify system-wide packages
    export PIP_BREAK_SYSTEM_PACKAGES=1
    
    # Install JupyterLab and related Python packages
    pip3 install --no-cache-dir --upgrade pip
    pip3 install --no-cache-dir \
        jupyterlab \
        nbconvert \
        papermill \
        numpy \
        scipy \
        pandas \
        matplotlib \
        seaborn \
        notebook

    # Install R packages
    Rscript -e "install.packages('IRkernel', repos='http://cran.r-project.org')"
    Rscript -e "IRkernel::installspec(user = FALSE)"  # Register the kernel in Jupyter

    # Install additional R packages for data science
    #Rscript -e "install.packages(c('tidyverse', 'devtools', 'caret', 'data.table', 'knitr', 'rmarkdown', 'shiny', 'plotly', 'ggplot2'), repos='http://cran.r-project.org')"

    # Clean up
    apk del build-base
    rm -rf /var/cache/apk/*

%environment
    # Set environment variables
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/lib/R/bin
    export R_LIBS_USER=/usr/local/lib/R/site-library
    export PIP_BREAK_SYSTEM_PACKAGES=1

%runscript
    # This is the default command when the container is run
    exec jupyter lab --ip=0.0.0.0 --no-browser --allow-root

%test
    # Test if JupyterLab is installed correctly
    jupyter --version
    R --version

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