#!/bin/bash

# Function to read user input
read_input() {
    read -p "$1: " input_value
    echo $input_value
}

# Get inputs from user
FULL_IMAGE_NAME=$(read_input "Enter the Docker image name including the tag (e.g., my-image:stable)")

# Push the image to the private registry
echo "Pushing the image $FULL_IMAGE_NAME to the private registry..."
docker push $FULL_IMAGE_NAME

# Check if the push was successful
if [ $? -eq 0 ]; then
    echo "Image successfully pushed to $FULL_IMAGE_NAME"
else
    echo "Failed to push the image!"
fi

echo "Done!"
