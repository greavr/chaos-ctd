# ----------------------------------------------------------------------------------------------------------------------
# Organization policy
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_organization_policy" "gke-vpc-peering" {
    project = var.project_id
    constraint = "compute.restrictVpcPeering"

    list_policy {
        allow {
            all = true
        }
    }
}
resource "google_project_organization_policy" "enable-ip-forward" {
    project = var.project_id
    constraint = "compute.vmCanIpForward"

    list_policy {
        allow {
            all = true
        }
    }
}

resource "google_project_organization_policy" "enable-key-creation" {
    project = var.project_id
    constraint = "iam.disableServiceAccountKeyCreation"

    boolean_policy {
        enforced = false
    }
}


resource "time_sleep" "wait_X_seconds" {
    depends_on = [
        google_project_organization_policy.gke-vpc-peering,
        google_project_organization_policy.enable-ip-forward,
        google_project_organization_policy.enable-key-creation
        ]

    create_duration = var.time_sleep
}