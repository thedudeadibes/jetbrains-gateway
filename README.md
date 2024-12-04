# JetBrains Gateway SSH Server

A lightweight SSH server container designed for use with JetBrains Gateway,
featuring flexible authentication options and easy configuration.

## Features
- Supports both password and public key authentication
- Multiple SSH key type support (ED25519, ECDSA, RSA)
- Configurable SSH port
- Single key management for enhanced security
- Compatible with JetBrains Gateway
- Easy deployment on Docker and Unraid

## Quick Start

### Using Docker Compose (Recommended)
1. Clone this repository
2. Create a `.env` file with your desired configuration:
```env
SSH_USERNAME=myuser
SSH_PASSWORD=mypassword
SSH_PORT=22
# Optional: SSH_PUBLIC_KEY="your-public-key-here"
```
3. Run:
```bash
docker-compose up -d
```

### Using Docker CLI

#### Password Authentication
```bash
docker run -d \
  -e SSH_USERNAME=myuser \
  -e SSH_PASSWORD=mypassword \
  -e SSH_PORT=22 \
  -v ./home:/opt/home \
  -p 22:22 \
  jetbrains-gateway-ssh
```

#### Public Key Authentication
```bash
docker run -d \
  -e SSH_USERNAME=myuser \
  -e SSH_PORT=22 \
  -e SSH_PUBLIC_KEY="ssh-ed25519 AAAA..." \
  -v ./home:/opt/home \
  -p 22:22 \
  jetbrains-gateway-ssh
```

## Environment Variables

| Variable       | Default   | Description                                      |
|----------------|-----------|--------------------------------------------------|
| SSH_USERNAME   | jetbrains | SSH user account name                            |
| SSH_PASSWORD   | jetbrains | Password for SSH user (when using password auth) |
| SSH_PORT       | 22        | SSH server port                                  |
| SSH_PUBLIC_KEY | None      | Public key for SSH authentication                |

## SSH Key Types

This container supports multiple SSH key types:
- ED25519 (Recommended)
- ECDSA
- RSA (Traditional)

### Generating Keys

#### ED25519 (Recommended)
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

#### ECDSA
```bash
ssh-keygen -t ecdsa -b 521 -C "your_email@example.com"
```

#### RSA
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

The public key format for any of these types can be used in the `SSH_PUBLIC_KEY` environment variable.

### Key Type Recommendations
- ED25519: Modern, secure, and efficient. Recommended for current systems.
- ECDSA: Good alternative when ED25519 is not available.
- RSA: Widely supported but requires larger key sizes (minimum 3072 bits recommended).

## Authentication Methods

### Password Authentication
- Set `SSH_USERNAME` and `SSH_PASSWORD`
- Do not set `SSH_PUBLIC_KEY`

### Public Key Authentication (Recommended)
1. Generate an SSH key pair if you don't have one:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
2. Get your public key content:
```bash
cat ~/.ssh/id_ed25519.pub
```
3. Set the `SSH_PUBLIC_KEY` environment variable with the content

## Unraid Installation

1. Open the Docker tab in your Unraid web interface
2. Click "Add Container"
3. Fill in the following fields:
   - Repository: `your-docker-hub-username/jetbrains-gateway-ssh`
   - Network Type: `Host`, `Bridge`, or some other network type you want to use
   - Path: Map a docker directory to a directory on your Unraid server so your repos persist.<br> For example, Docker: `/repos` -> Host: `/mnt/user/repos`
   - Extra Parameters (Recommended):
     ```
     --restart unless-stopped
     ```
   - Variables:
     ```
     SSH_USERNAME=your-username
     SSH_PASSWORD=your-password
     # Or for public key auth:
     SSH_PUBLIC_KEY=your-public-key
     
     Optional:
     SSH_PORT=22
     ```

4. Click "Apply"

## Security Considerations

1. Public key authentication is more secure than password authentication
2. Only one public key can be active at a time
3. ED25519 keys are recommended for optimal security and performance
4. When using password authentication:
   - Use strong passwords
   - Consider changing the default SSH port
5. The container automatically disables password authentication when using public key authentication

## Volume Persistence

The container uses `/opt/home` as the home directory for the SSH user. Map this to a local directory to persist user data:

```bash
-v /path/on/host:/opt/home
```

## Updating Authentication

### Changing Public Key
Simply restart the container with a new `SSH_PUBLIC_KEY` value. The old key will be replaced.

### Switching to Password Auth
Remove the `SSH_PUBLIC_KEY` variable and provide `SSH_PASSWORD` instead.

## Building from Source

```bash
git clone https://github.com/yourusername/jetbrains-gateway-ssh.git
cd jetbrains-gateway-ssh
docker build -t jetbrains-gateway-ssh .
```

## Troubleshooting

1. Connection refused:
   - Verify the SSH port is correctly mapped
   - Check if the SSH service is running inside the container

2. Authentication failed:
   - For password auth: verify username and password
   - For key auth: check if the correct public key is provided
   - Verify key type is supported

3. Permission issues:
   - Verify volume permissions
   - Check ownership of `/opt/home`

4. Key-related issues:
   - Ensure key format is correct
   - Check key permissions (should be 600 for private key)
   - Verify the entire public key was copied correctly

## Support

For issues and feature requests, please open an issue on GitHub.