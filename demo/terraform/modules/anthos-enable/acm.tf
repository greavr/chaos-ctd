# ----------------------------------------------------------------------------------------------------------------------
# Configure ACM
# ----------------------------------------------------------------------------------------------------------------------

resource "google_project_service" "enable-source-repo" {
    project = var.project_id
    service = "sourcerepo.googleapis.com"
    disable_on_destroy = false
}

resource "google_project_service" "enable-acm" {
    project = var.project_id
    service = "anthosconfigmanagement.googleapis.com"
    disable_on_destroy = false
}

#https://github.com/GoogleCloudPlatform/gke-poc-toolkit/blob/main/terraform/modules/acm/acm.tf
resource "google_gke_hub_feature" "acm" {
    provider = google-beta

    project  = var.project_id
    name = "configmanagement"
    location = "global"

    depends_on = [
        google_project_service.enable-source-repo,
        google_project_service.enable-acm,
        google_sourcerepo_repository.gke-poc-config-sync
    ]
}

# Setup Cloud Repository
resource "google_sourcerepo_repository" "gke-poc-config-sync" {
    provider = google-beta

    name = "gke-poc-config-sync"    
    project  = var.project_id

    depends_on = [
        google_project_service.enable-source-repo
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Register ASM
# ----------------------------------------------------------------------------------------------------------------------
resource "google_gke_hub_feature_membership" "feature_member" {
    provider = google-beta

    for_each = var.gke_cluster_list

    location = "global"

    feature    = "configmanagement"
    membership = "projects/${var.project_id}/locations/global/memberships/${each.value.name}"

    configmanagement {
        version = "1.10.1"
        config_sync {
            git {
                sync_repo = google_sourcerepo_repository.gke-poc-config-sync.url
                policy_dir  = "/"
                sync_branch = "main"
                secret_type = "gcpserviceaccount"
                gcp_service_account_email = google_service_account.acm-sa.email
            }
        }
    }

    depends_on = [
        google_gke_hub_membership.anthos-register
    ]
    
}