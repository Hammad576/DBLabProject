# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary dependencies
RUN apt update && \
    apt install -y wget gnupg ca-certificates software-properties-common && \
    # Add MongoDB GPG key and repository
    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list && \
    # Install libssl1.1 manually
    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y && \
    # Install MongoDB and Python dependencies
    apt update && \
    apt install -y mongodb-org python3 python3-pip python3-dev build-essential libssl-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies for your project
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Set the working directory
WORKDIR /app

# Copy your project files into the container
COPY . /app

# Expose port 8000 for the Flask app
EXPOSE 8000

# Command to start MongoDB and the Flask app
CMD ["sh", "-c", "mongod --fork --logpath /var/log/mongodb.log && python3 /app/server.py"]
