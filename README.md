# Inception 🐳

Docker and DevOps–focused project developed as part of the 42 Network.  
This project establishes a secure and maintainable Docker-based infrastructure (multi-container setup) with automation, monitoring, and network configuration.

---

##  Project Structure

```text
.
├── secrets/       # Private credentials (not committed)
├── srcs/         # All configuration files and Docker-related code
├── .gitignore    # Ignored items (e.g., secrets folder)
└── Makefile      # Automation for building and deploying

```

### Key Technologies

- **Docker** : Containerization for services like Nginx, MySQL, PHP, etc.
- **Docker Compose** : Orchestrates multiple containers in a coordinated stack.
- **Bash & Shell Scripting** : For automation and service management.
- **Makefile** : Simplifies build and deployment steps.

## ⚡ Pour lancer le projet  

```bash
# Clone the repository
git clone https://github.com/dangminhtran/42Cursus_Inception.git
cd 42Cursus_Inception

# Build and run the containers
make up

# Optional: Stop and cleanup services
make down
make fclean

# Rebuild from scratch
make re
