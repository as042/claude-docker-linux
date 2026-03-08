To install the latest version of Docker Engine on Ubuntu, the recommended method is to
use the official Docker repository. This ensures you receive the latest stable updates directly from Docker. 
You can also use this guide: https://docs.docker.com/engine/install/ubuntu/.

## Prerequisites

Ensure your Ubuntu system (20.04, 22.04, or 24.04 are supported) is updated and has the necessary packages installed. 
bash

sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y

## Step-by-Step Installation

Set up the repository: Add Docker’s official GPG key and the repository to your Apt sources.

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine: Update the package index and install the latest packages.
   
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Verify: Run the hello-world image to ensure installation.
    
```bash
sudo docker run hello-world
```