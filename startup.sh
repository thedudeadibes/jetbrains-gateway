#!/usr/bin/env bash

set -e

# Set default SSH port if not provided
SSH_PORT=${SSH_PORT:-22}

# Create group if it doesn't exist
if ! grep -q "${SSH_USERNAME}" /etc/group &> /dev/null; then
    addgroup "${SSH_USERNAME}"
fi

# Create user if it doesn't exist
if ! id "${SSH_USERNAME}" &> /dev/null; then
    adduser --home /opt/home --ingroup "${SSH_USERNAME}" "${SSH_USERNAME}"
fi

# Create and set permissions for .ssh directory
mkdir -p /opt/home/.ssh
chmod 700 /opt/home/.ssh

# Handle authentication method
if [ -n "${SSH_PUBLIC_KEY}" ]; then
    # Always overwrite authorized_keys with the provided key
    echo "${SSH_PUBLIC_KEY}" > /opt/home/.ssh/authorized_keys
    chmod 600 /opt/home/.ssh/authorized_keys

    # Disable password authentication in sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

    echo "SSH key authentication configured with provided key"
else
    # If no key provided but authorized_keys exists, remove it to ensure password auth
    if [ -f /opt/home/.ssh/authorized_keys ]; then
        rm /opt/home/.ssh/authorized_keys
        echo "Removed existing SSH key, switching to password authentication"
    fi

    # Configure password authentication
    echo -e "${SSH_PASSWORD}\n${SSH_PASSWORD}" | passwd "${SSH_USERNAME}"
    echo "Password authentication configured"
fi

# Set proper ownership
chown -R "${SSH_USERNAME}:${SSH_USERNAME}" /opt/home

# Update SSH port in config
sed -i "s/#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config
# Also handle case where Port is already set
sed -i "s/Port [0-9]*/Port ${SSH_PORT}/" /etc/ssh/sshd_config

# Start SSH service
service ssh start

# Keep container running
exec tail -f /dev/null