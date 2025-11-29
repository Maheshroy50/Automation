# Strapi AWS Deployment Project

This project contains a complete setup for deploying a **Strapi Headless CMS** application to **AWS** using **Docker**, **Terraform**, and **GitHub Actions**.

## Project Structure
- `my-project/`: The Strapi application source code (Node.js).
- `terraform/`: Infrastructure as Code (IaC) to provision AWS resources.

---

##  Step 1: Local Development (Docker)

Run the application locally to verify it works before deploying.

1.  **Navigate to the project**:
    ```bash
    cd my-project
    ```
2.  **Configure Environment**:
    - Copy `.env.example` to `.env`.
    - The `.env` file has been pre-filled with secure random keys for you.
3.  **Start Docker**:
    ```bash
    docker compose up -d --build
    ```
    *Note: This uses Node.js 20 inside the container to match Strapi's requirements.*

4.  **Access**:
    - **Website**: [http://localhost](http://localhost) (Nginx Proxy)
    - **Strapi Admin**: [http://localhost:1337/admin](http://localhost:1337/admin)

---

## ☁️ Step 2: Provision Infrastructure (Terraform)

Create the server (EC2), database storage (S3), and security groups on AWS.

1.  **Navigate to Terraform**:
    ```bash
    cd terraform
    ```
2.  **Initialize & Apply**:
    ```bash
    terraform init
    terraform apply
    ```
    *Type `yes` when prompted.*

    **Important**: This setup uses a **t3.micro** instance in the **us-east-1a** availability zone for best compatibility.

3.  **Save Outputs**:
    Terraform will output important information. **Save these values**:
    - `public_ip`: The IP address of your new server.
    - `ssh_command`: Command to SSH into the server.
    - `s3_bucket_name`: Name of the created S3 bucket.

    *Note: A private key file `strapi-key.pem` will be created in this folder. Keep it safe!*

---

## 🔄 Step 3: Configure CI/CD (GitHub Actions)

Automate the deployment so that every push to `main` updates the server.

1.  **Push to GitHub**:
    Create a new repository on GitHub and push this code.
    ```bash
    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin <your-repo-url>
    git push -u origin main
    ```

2.  **Add GitHub Secrets**:
    Go to your Repository Settings > **Secrets and variables** > **Actions** and add:

    | Secret Name | Value |
    | :--- | :--- |
    | `EC2_HOST` | The `public_ip` from Terraform output. |
    | `EC2_SSH_KEY` | The content of `terraform/strapi-key.pem`. |
    | `ENV_FILE` |  

    **Important**: You need to get your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from the AWS Console (IAM User) and add them to your local `.env` file before copying it to GitHub Secrets.

3.  **Trigger Deployment**:
    - The `Deploy Strapi` workflow will run automatically on push.
    - It builds the image on GitHub (using Node 20) and deploys it to your EC2 instance.
    - Check the **Actions** tab to see the progress.

---

## 🛠 Manual Access (SSH)

If you need to debug the server manually:

```bash
cd terraform
ssh -i strapi-key.pem ubuntu@<public_ip>
```

Once inside:
- Check logs: `docker logs strapi`
- Check status: `docker ps`
