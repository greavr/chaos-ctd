# ----------------------------------------------------------------------------------------------------------------------
# Configure Anthos Service Accounts
# ----------------------------------------------------------------------------------------------------------------------
############## ACM ##############
resource "google_service_account" "acm-sa" {
    project  = var.project_id
    account_id   = "acm-service-account"
    display_name = "acm-service-account"
}

resource "google_service_account_iam_binding" "acm-sa-roles" {
    service_account_id = google_service_account.acm-sa.name
    role = "roles/iam.workloadIdentityUser" 

    members = [
        "serviceAccount:${var.project_id}.svc.id.goog[config-management-system/root-reconciler]",
    ]


    depends_on = [
        google_service_account.acm-sa
    ]
}

############## MCI ##############
# resource "google_project_iam_member" "mci_service_account-roles" {
#     project  = var.project_id
#     role    = "roles/container.admin"
#     member  = "serviceAccount:service-${var.project-number}@gcp-sa-multiclusteringress.iam.gserviceaccount.com"

#     depends_on = [
#         google_project_service.mci,
#         google_gke_hub_feature.mci
#     ]
# }

############# MCS ##############
resource "google_project_iam_member" "mcs_service_account-roles" {
    provider = google-beta

    project  = var.project_id
    role    = "roles/compute.networkViewer"
    member  = "serviceAccount:${var.project_id}.svc.id.goog[gke-mcs/gke-mcs-importer]"

    depends_on = [
        google_gke_hub_feature.mcs
        ]
}

