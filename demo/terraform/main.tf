# ----------------------------------------------------------------------------------------------------------------------
# Configure Providers
# ----------------------------------------------------------------------------------------------------------------------
provider "google" {
  region        = var.regions[0].region
  project       = var.project_id
}

provider "google-beta" {
  region        = var.regions[0].region
  project       = var.project_id
}

# ----------------------------------------------------------------------------------------------------------------------
# DATA
# ----------------------------------------------------------------------------------------------------------------------
data "google_project" "project" {}
data "google_client_config" "current" {}

# ----------------------------------------------------------------------------------------------------------------------
# ORG Policies
# ----------------------------------------------------------------------------------------------------------------------
module "org_policy" {
  source  = "./modules/org_policy"

  project_id = var.project_id
}

# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure VPC
# ----------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "./modules/vpc"
  project_id = var.project_id
  regions = var.regions
  vpc-name = var.vpc-name
  
  depends_on = [
    google_project_service.enable-services,
    module.org_policy
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure GKE
# ----------------------------------------------------------------------------------------------------------------------
module "gke" {
  source  = "./modules/gke"
  project_id = var.project_id

  vpc-name = var.vpc-name
  regions = var.regions
  
  
  depends_on = [
    module.vpc
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure Cloud SQL
# ----------------------------------------------------------------------------------------------------------------------
module "cloud_sql" {
  source  = "./modules/cloud_sql"
  project_id = var.project_id
  vpc_id = module.vpc.vpc_id
  region = module.vpc.primary_region
    
  depends_on = [
    module.vpc
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure Workload Identity
# ----------------------------------------------------------------------------------------------------------------------
module "workload_identity" {
  source  = "./modules/workload_identity"
  project_id = var.project_id
  boa_namespace = var.namespace
  
  
  depends_on = [
    module.vpc
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Enable Anthos
# ----------------------------------------------------------------------------------------------------------------------
module "anthos-enable" {
  source  = "./modules/anthos-enable"
  project_id = var.project_id

  project-number = data.google_project.project.number
  vpc-name = var.vpc-name

    gke_cluster_list = module.gke.cluster_list
  
  depends_on = [
    module.gke
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# ABM VPC
# ----------------------------------------------------------------------------------------------------------------------
module "abm-vpc" {
  source  = "./modules/abm-vpc"
  project_id = var.project_id
  regions = var.abm-regions
  vpc-name = var.abm-vpc-name
  firewall-ports-tcp = var.abm-firewall-ports-tcp
  firewall-ports-udp = var.abm-firewall-ports-udp
  
  depends_on = [
    google_project_service.enable-services,
    module.org_policy
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Generate SSH Key
# ----------------------------------------------------------------------------------------------------------------------
module "ssh-key" {
    source = "./modules/ssh-key"

    depends_on = [
        google_project_service.enable-services,
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Generate SAs
# ----------------------------------------------------------------------------------------------------------------------
module "abm-sa" {
    source = "./modules/abm_sa"
    project_id = var.project_id

    depends_on = [
        google_project_service.enable-services,
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Build Nodes
# ----------------------------------------------------------------------------------------------------------------------
module "nodes" {
    source = "./modules/nodes"

    zone = "${module.abm-vpc.primary_region}-a"
    node-spec = var.gce-instance-type
    master-node-count = var.master-node-count
    worker-node-count = var.worker-node-count
    node-os = var.gce-instance-os
    network = module.abm-vpc.vpc_id
    subnetwork = module.abm-vpc.primary_region
    project_id = var.project_id
    public-key = module.ssh-key.public-key
    vx-ip-master = 3
    vx-ip-worker = 4


    depends_on = [
      module.vpc,
      module.ssh-key
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# GCS For template files
# ----------------------------------------------------------------------------------------------------------------------

module "gcs" {
  source = "./modules/gcs"

  project_id = var.project_id
  gcs-bucket-name = var.gcs-bucket-name
  bucket-location = module.abm-vpc.primary_region


  depends_on = [
    google_project_service.enable-services
  ]
  
}

# ----------------------------------------------------------------------------------------------------------------------
# Build Workstation
# ----------------------------------------------------------------------------------------------------------------------
module "amb-workstation" {
    source = "./modules/abm_workstation"

    zone = "${module.abm-vpc.primary_region}-a"
    node-spec = var.gce-instance-type
    network = module.abm-vpc.vpc_id
    master-node-ips = module.nodes.master-ips
    worker-node-ips = module.nodes.worker-ips
    node-os = var.gce-instance-os
    subnetwork = module.abm-vpc.primary_region
    project_id = var.project_id
    private-key = module.ssh-key.secret-name
    public-key = module.ssh-key.public-key
    sa-key-list = module.abm-sa.secrets-list
    template-path = module.gcs.abm-template-file
    vx-ip = 2

    depends_on = [
      module.nodes,
      module.gcs,
      module.abm-sa
    ]
}

# # ----------------------------------------------------------------------------------------------------------------------
# # Map Out GKE Clusters
# # ----------------------------------------------------------------------------------------------------------------------
# #--GKE Token Lookups
# data "google_container_cluster" "gke_cluster" {
#     name = "${var.project_id}-us-west1"
#     location = "us-west1"
#     depends_on = [
#       module.gke
#     ]
# }

# provider "kubernetes" {
#     host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
#     cluster_ca_certificate = base64decode("${data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate}")
#     token                  = data.google_client_config.current.access_token
# }

# # Same parameters as kubernetes provider
# provider "kubectl" {
#     load_config_file       = false
#     host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
#     cluster_ca_certificate = base64decode("${data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate}")
#     token                  = data.google_client_config.current.access_token
# }

# # ----------------------------------------------------------------------------------------------------------------------
# # Roll out Yaml
# # ----------------------------------------------------------------------------------------------------------------------
# module "gke_workload" {
#     source = "./modules/gke_workloads"  
#     project_id = var.project_id
#     namespace = var.namespace
#     ksa_name = module.workload_identity.ksa-name
#     iam_ksa = module.workload_identity.iam_ksa

#     sql_user = module.cloud_sql.sql_user
#     sql_pwd = module.cloud_sql.pwd
#     sql_connection_name = module.cloud_sql.sql_connection_name


#     depends_on = [
#       module.gke,
#       module.workload_identity,
#       data.google_container_cluster.gke_cluster
#     ]

# }
  

