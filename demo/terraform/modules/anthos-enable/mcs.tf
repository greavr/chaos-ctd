# ----------------------------------------------------------------------------------------------------------------------
# Configure MCS
# ----------------------------------------------------------------------------------------------------------------------
## Enable API
resource "google_project_service" "enable-mcs" {
    project = var.project_id
    service = "multiclusterservicediscovery.googleapis.com"
    disable_on_destroy = false
}

## Enable Multi-cluster service discovery
resource "google_gke_hub_feature" "mcs" {
    provider = google-beta

    project  = var.project_id
    name = "multiclusterservicediscovery"
    location = "global"

    depends_on = [
        google_project_service.enable-mcs
    ]
}

