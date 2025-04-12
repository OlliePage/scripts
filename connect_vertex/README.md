# Connect Vertex AI

A bash script to simplify connecting to Vertex AI notebook instances via SSH with port forwarding.

## Features

- Connects to Vertex AI notebook instances with proper authentication
- Sets up port forwarding to access Jupyter notebooks via VS Code
- Uses configurable defaults for common parameters
- Handles authentication automatically
- Supports command line parameters for quick customization

## Usage

```bash
./connect_vertex.sh [instance-name] [project] [zone] [port]
```

### Parameters

- `instance-name`: Name of your Vertex AI notebook instance (default: pricing-and-promotions-ukca)
- `project`: Google Cloud project ID (default: jet-ml-dev)
- `zone`: Compute zone where the instance is located (default: europe-west1-b)
- `port`: Local port to forward to (default: 8080)

### Example

```bash
# Connect using defaults
./connect_vertex.sh

# Connect to a different instance
./connect_vertex.sh my-notebook-instance

# Connect with custom parameters
./connect_vertex.sh custom-instance my-project us-central1-a 9000
```

## How It Works

- Sets the Google Cloud project
- Verifies authentication and refreshes if needed
- Establishes an SSH connection with port forwarding
- Provides instructions for accessing the notebook in VS Code