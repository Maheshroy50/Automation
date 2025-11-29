# Strapi AWS Architecture

This document outlines a streamlined AWS architecture for deploying a Strapi application. It utilizes a single instance deployment strategy to consolidate resources while maintaining standard DevOps practices like containerization and cloud storage integration.

## Architecture Diagram

```mermaid
graph TD
    User((User))
    
    subgraph "AWS Cloud"
        subgraph "VPC"
            subgraph "Public Subnet"
                EC2[EC2 Instance]
                
                subgraph "Docker Compose"
                    Nginx[Nginx Container\n(Reverse Proxy)]
                    Strapi[Strapi Container]
                    DB[(PostgreSQL Container)]
                end
            end
        end
        
        S3[S3 Bucket\n(Media Storage)]
        IGW[Internet Gateway]
    end

    User -->|HTTP/HTTPS| EC2
    EC2 -->|Traffic| Nginx
    Nginx -->|Proxy| Strapi
    Strapi -->|Read/Write| DB
    Strapi -->|Uploads| S3
    
    EC2 <--> IGW
```

## Component Details

### 1. Compute: Amazon EC2
*   **Service**: Amazon EC2.
*   **Why**:
    *   **Consolidated Hosting**: Hosting the application, database, and web server on a single instance simplifies infrastructure management.
    *   **Control**: Provides full root access to the underlying operating system for configuration and monitoring.
*   **Configuration**:
    *   **OS**: Ubuntu Server or Amazon Linux 2.
    *   **Docker & Docker Compose**: Installed on the instance to orchestrate the application services.
    *   **Elastic IP**: Assigned to the instance to ensure a consistent public entry point.

### 2. Database: PostgreSQL (Containerized)
*   **Service**: Docker Container running on the EC2 instance.
*   **Why**:
    *   **Integrated Environment**: Keeps the database close to the application logic within the same network context.
    *   **Portability**: The entire stack (App + DB) is defined in code (`docker-compose.yml`), making it easy to replicate or move.
*   **Note**: A Docker volume is mounted to the host system to ensure data persistence across container restarts.

### 3. Storage: Amazon S3
*   **Service**: Simple Storage Service (S3).
*   **Why**:
    *   **Scalability**: Offloads static asset storage (images, videos) from the compute instance, allowing for unlimited storage growth.
    *   **Persistence**: Ensures media files are safe and independent of the application server's lifecycle.
*   **Configuration**: Utilizes the `@strapi/provider-upload-aws-s3` plugin for seamless integration.

### 4. Networking & Security
*   **Security Group**:
    *   **Inbound**: Allow Port 80 (HTTP) and 443 (HTTPS) from Anywhere (`0.0.0.0/0`).
    *   **Management**: Allow Port 22 (SSH) restricted to specific administrative IP addresses.
*   **Nginx**:
    *   Functions as a reverse proxy, directing external traffic to the Strapi container.
    *   Manages SSL/TLS termination to ensure secure communication (HTTPS).

## Deployment Workflow
1.  **Version Control**: Code changes are committed and pushed to the repository.
2.  **Deployment**:
    *   Connect to the EC2 instance via SSH.
    *   Pull the latest changes from the repository.
    *   Rebuild and restart containers using Docker Compose (`docker-compose up -d --build`).
