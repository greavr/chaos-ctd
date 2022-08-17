# ----------------------------------------------------------------------------------------------------------------------
# Configure MCI
# ----------------------------------------------------------------------------------------------------------------------

## Enable API
resource "google_project_service" "mci" {
    project = var.project_id
    service = "multiclusteringress.googleapis.com"
    disable_on_destroy = false

    depends_on = [
      google_gke_hub_membership.anthos-register
    ]
}


## Configure VPC firewall rules
resource "google_compute_firewall" "mci-ingress" {

    name = "allow-glcb-backend-ingress"
    network = var.vpc-name

    allow {
        protocol = "tcp"
        ports    = ["0-65535"]
    }

    source_ranges =  ["130.211.0.0/22","35.191.0.0/16"]
}

# ----------------------------------------------------------------------------------------------------------------------
# Register MCI
# ----------------------------------------------------------------------------------------------------------------------
# resource "google_gke_hub_feature" "mci" {

#     for_each = var.gke_cluster_list

#     provider = google-beta
#     name = "multiclusteringress"
#     location = "global"
#     project  = var.project_id

#     spec {
#         multiclusteringress {
#             config_membership = "projects/${var.project_id}/locations/global/memberships/${each.value.name}"
#         }
#     }


#     depends_on = [
#         google_project_service.mci
#     ]
# }