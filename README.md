# Scan Organization Docker Images with Trivy
This is a small bash script to scan your organization's images on DockerHub with trivy.

## Prerequisites
* **trivy** installed. [Installation guide.](https://aquasecurity.github.io/trivy/v0.18.3/installation/)
* **jq** installed. [Installation guide.](https://stedolan.github.io/jq/download/)

## Scan Org
1) Place your values in **scan-org.sh**.
```bash
# set username, password, and organization
UNAME=""
UPASS=""   #user password or pat (dckr_****).
ORG=""
```
2) Run the script

```bash
sh scan-org.sh
```

3) Scan result html files and run log will be populated under `./scan-results-***/` folder.