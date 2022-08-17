# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# GCP Project Name
variable "project_id" {
    type = string
}

# VPC Demo Network Name
variable "vpc-name" {
    type = string
    description = "Custom VPC Name"
    default = "bank-of-anthos"
}

# List of regions (support for multi-region deployment)
variable "regions" { 
    type = list(object({
        region = string
        cidr = string
        management-cidr = string
        })
    )
    default = [{
            region = "us-west1"
            cidr = "10.0.0.0/20"
            management-cidr = "192.168.10.0/28"
        },
        {
            region = "us-east1"
            cidr = "10.0.16.0/20"
            management-cidr = "192.168.10.16/28"
        },]
}

# Service to enable
variable "services_to_enable" {
    description = "List of GCP Services to enable"
    type    = list(string)
    default =  [
        "compute.googleapis.com",
        "container.googleapis.com",
        "monitoring.googleapis.com",
        "cloudtrace.googleapis.com",
        "clouddebugger.googleapis.com",
        "cloudprofiler.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "iam.googleapis.com",
        "sourcerepo.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
        "anthos.googleapis.com",
        "anthosaudit.googleapis.com",
        "anthosgke.googleapis.com",
        "gkeconnect.googleapis.com",
        "gkehub.googleapis.com",
        "anthosconfigmanagement.googleapis.com",
        "multiclusterservicediscovery.googleapis.com",
        "multiclusteringress.googleapis.com",
        "meshconfig.googleapis.com",
        "secretmanager.googleapis.com",
        "storage.googleapis.com",
        "opsconfigmonitoring.googleapis.com",
        "stackdriver.googleapis.com"
    ]
  
}


# BOA config
variable "namespace" {
    description = "GKE Namespace"
    type = string
    default = "boa"
}


# Master Node Count
variable "master-node-count" {
    description = "# of Kubernetes master nodes"
    type = number
    default = 1
}

# Worker Node Cout
variable "worker-node-count" {
    description = "# of Kubernetes worker nodes"
    type = number
    default = 3
}

# Instance Type
variable "gce-instance-type" {
  description = "GCE Instance Spec"
  type = string
  default = "n1-standard-8"
}

# Instance OS
variable "gce-instance-os" {
    description = "GCE Instance OS"
    type = string
    default = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
  
}

# Storage Bucket
variable "gcs-bucket-name" {
    default = "abm-config"
    description = "Bucket used to store kubectl config and abm template"
    type = string
    }

# Firewall rules
variable "abm-firewall-ports-tcp" {
    description = "Ports required for abm"
    type = list(string)
    default = [ 
        "6444",
        "10250",
        "2379-2380",
        "10250-10252",
        "10256",
        "4240",
        "30000-32767",
        "7946",
        "443",
        "22"
        ]
  
}

variable "abm-firewall-ports-udp" {
    description = "Ports required for abm"
    type = list(string)
    default = [ 
        "6081",
        "7946"
        ]
  
}

variable "abm-vpc-name" {
    type = string
    description = "Custom VPC Name"
    default = "anthos-bare-metal"
}

# List of regions (support for multi-region deployment)
variable "abm-regions" { 
    type = list(object({
        region = string
        cidr = string
        })
    )
    default = [{
            region = "us-central1"
            cidr = "10.0.0.0/24"
        },]
}




# ----------------------------------------------------------------------------------------------------------------------
# Optional Vars
# ----------------------------------------------------------------------------------------------------------------------
# variable "project_name" {
#  type        = string
#  description = "project name in which demo deploy"
# }
# variable "project_number" {
#  type        = string
#  description = "project number in which demo deploy"
# }
# variable "gcp_account_name" {
#  description = "user performing the demo"
# }
# variable "deployment_service_account_name" {
#  description = "Cloudbuild_Service_account having permission to deploy terraform resources"
# }
# variable "org_id" {
#  description = "Organization ID in which project created"
# }