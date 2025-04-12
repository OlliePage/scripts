#!/bin/bash

# Script to connect to a Vertex AI notebook instance
# Usage: ./connect_vertex.sh [instance-name] [project] [zone]

# Default values (change these to match your most common settings)
DEFAULT_INSTANCE="pricing-and-promotions-ukca"
DEFAULT_PROJECT="jet-ml-dev"
DEFAULT_ZONE="europe-west1-b"
DEFAULT_PORT="8080"

# Parse command line arguments or use defaults
INSTANCE=${1:-$DEFAULT_INSTANCE}
PROJECT=${2:-$DEFAULT_PROJECT}
ZONE=${3:-$DEFAULT_ZONE}
PORT=${4:-$DEFAULT_PORT}

# Display connection information
echo "Connecting to Vertex AI notebook instance:"
echo "  Instance: $INSTANCE"
echo "  Project:  $PROJECT"
echo "  Zone:     $ZONE"
echo "  Port:     $PORT"
echo ""
echo "VS Code connection URL will be: http://localhost:$PORT/"
echo ""

# Set the project
echo "Setting project to $PROJECT..."
gcloud config set project $PROJECT

# Check if already authenticated and credentials are valid
echo "Checking authentication status..."
if gcloud auth application-default print-access-token &>/dev/null; then
  echo "✓ Already authenticated with valid credentials"
else
  echo "Authentication needed or credentials expired"
  echo "Updating application default credentials..."
  gcloud auth login --update-adc
fi

# Connect to the instance with port forwarding
echo "Establishing SSH connection with port forwarding..."
echo "Once connected, open VS Code and select kernel at http://localhost:$PORT/"
echo ""
echo "Press Ctrl+C to disconnect when you're done."
echo ""

# Execute the SSH command
gcloud compute ssh $INSTANCE --project $PROJECT --zone $ZONE --tunnel-through-iap -- -L ${PORT}:localhost:${PORT}

# This part will execute after the SSH connection is closed
echo ""
echo "Connection closed. To reconnect, run this script again."