# ----------------------------------------------------------------------------------------------------------------------
# Enable ASM
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-asm" {
    project = var.project_id
    service = "meshconfig.googleapis.com"
    disable_on_destroy = false
}

resource "google_gke_hub_feature" "feature" {
  provider = google-beta
  project  = var.project_id

  name = "servicemesh"
  location = "global"

  depends_on = [
    google_project_service.enable-asm
  ]
}