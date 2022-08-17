# Chaos Demo Click To Deploy

Requirement: **GCP PROJECT INTO WHICH TO DEPLOY**

## Tool Setup Guide

[Tool Install Guide](tools/ReadMe.md)

## Environment Setup
* Install tools
* Run the following commands to login to gcloud:
```
gcloud auth login
gcloud auth application-default login
```

This will setup your permissions for terraform to run.

## Deploy guide
```
cd terraform
./setup.sh
terraform init
terraform plan
terraform apply
```

# Todo:
- [x] Build Project
- [x] 2x GKE Project
- [x] 1x ABM
- [ ] Deploy ASM
- [ ] Deploy ACM
- [ ] Deploy Metrics Board
- [ ] Deploy Application Yaml
- [ ] Deploy Cloud Run Control Instance
