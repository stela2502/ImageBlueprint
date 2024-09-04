#!/bin/bash

SCRIPT=$(readlink -f $0)
IMAGE_PATH=`dirname $SCRIPT`

# Ensure a directory name argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_directory_name>"
    exit 1
fi

NEW_DIR=$1
NEW_NAME=$(basename "$NEW_DIR")

# Check if the new directory already exists
if [ -d "$NEW_DIR" ]; then
    echo "Directory '$NEW_DIR' already exists. Please choose a different name."
    exit 1
fi

# Create the new directory
mkdir -p "$NEW_DIR"
echo "Created directory: $NEW_DIR"

# Copy specific files from the 'image' folder to the new directory
cp $IMAGE_PATH/image/run.sh "$NEW_DIR/"
cp $IMAGE_PATH/image/shell.sh "$NEW_DIR/"
cp $IMAGE_PATH/image/Bioinformatics.def "$NEW_DIR/${NEW_NAME}.def"
cp $IMAGE_PATH/image/generate_module.sh "$NEW_DIR/"
cp $IMAGE_PATH/image/Makefile "$NEW_DIR/"
echo "Copied selected files to '$NEW_DIR'"

# Update Makefile
MAKEFILE="$NEW_DIR/Makefile"
if [ -f "$MAKEFILE" ]; then
    sed -i "s/Bioinformatics/${NEW_NAME}/g" "$MAKEFILE"
    echo "Updated 'Bioinformatics' to '${NEW_NAME}' in $MAKEFILE"
else
    echo "Makefile not found in $NEW_DIR"
fi

# Update shell.sh
MAKEFILE="$NEW_DIR/shell.sh"
if [ -f "$MAKEFILE" ]; then
    sed -i "s/Bioinformatics/${NEW_NAME}/g" "$MAKEFILE"
    echo "Updated 'Bioinformatics' to '${NEW_NAME}' in $MAKEFILE"
else
    echo "shell.sh not found in $NEW_DIR"
fi


# Update run.sh
MAKEFILE="$NEW_DIR/run.sh"
if [ -f "$MAKEFILE" ]; then
    sed -i "s/Bioinformatics/${NEW_NAME}/g" "$MAKEFILE"
    echo "Updated 'Bioinformatics' to '${NEW_NAME}' in $MAKEFILE"
else
    echo "run.sh not found in $NEW_DIR"
fi


# Provide final instructions to the user
echo "Please modify the '${NEW_NAME}.def' file as needed to fit your requirements."
echo "Also, review the updated Makefile to ensure it matches your needs."

echo "Setup completed."