# ----------------------------------------------------------------------------------------------------------------------
# Register Anthos Cluster
# ----------------------------------------------------------------------------------------------------------------------
resource "google_gke_hub_membership" "anthos-register" {
  provider = google-beta

  for_each = var.gke_cluster_list

  membership_id = "${each.value.name}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${each.value.id}"
    }
  }

  authority {
    issuer = "https://container.googleapis.com/v1/projects/${var.project_id}/locations/${each.value.location}/clusters/${each.value.name}"
  }

}