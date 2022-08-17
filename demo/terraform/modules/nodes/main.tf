# ----------------------------------------------------------------------------------------------------------------------
# Master Nodes
# ----------------------------------------------------------------------------------------------------------------------
# GCE SA
resource "google_service_account" "abm-node-sa" {
    account_id   = "abm-node-sa"
    display_name = "abm-node-sa"
}

resource "google_project_iam_member" "service_account-roles" {
    project = var.project_id
    for_each = toset(var.gce-roles)
    role    = "roles/${each.value}"
    member  = "serviceAccount:${google_service_account.abm-node-sa.email}"
    depends_on = [
        google_service_account.abm-node-sa
    ]
}

resource "google_compute_instance" "masters" {
    count = var.master-node-count
    name  = "abm-master-${count.index}"
    hostname = "abm-master-${count.index}.${var.project_id}"
    machine_type = var.node-spec
    zone         = var.zone
    can_ip_forward = true
    allow_stopping_for_update = true

    tags = ["abm","abm-master"]

    boot_disk {
        initialize_params {
            image = var.node-os
            size = 160
        }
    }

    network_interface {
        network = var.network
        subnetwork = var.subnetwork
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_integrity_monitoring = true
    }

    metadata_startup_script = "${file("${path.module}/scripts/startup.sh")}"

    metadata = {
        ssh-keys = "ubuntu:${var.public-key}"
        vx-ip = var.vx-ip-master + count.index
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = google_service_account.abm-node-sa.email
        scopes = ["cloud-platform"]
    }
    
    depends_on = [
        google_service_account.abm-node-sa
    ]
}


# ----------------------------------------------------------------------------------------------------------------------
# Worker Nodes
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "workers" {
    count = var.worker-node-count
    name  = "abm-worker-${count.index}"
    hostname = "abm-worker-${count.index}.${var.project_id}"
    machine_type = var.node-spec
    zone         = var.zone
    can_ip_forward = true
    allow_stopping_for_update = true

    tags = ["abm","abm-worker"]

    boot_disk {
        initialize_params {
            image = var.node-os
            size = 160
        }
    }

    network_interface {
        network = var.network
        subnetwork = var.subnetwork
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_integrity_monitoring = true
    }

    metadata_startup_script = "${file("${path.module}/scripts/startup.sh")}"

    metadata = {
        ssh-keys = "ubuntu:${var.public-key}"
        vx-ip = var.vx-ip-worker + count.index
    }

    service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = google_service_account.abm-node-sa.email
        scopes = ["cloud-platform"]
    }
    
    depends_on = [
        google_service_account.abm-node-sa
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# IAP Firewall Rule
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "iap" {
  name    = "allow-iap-ssh"
  network = var.network


  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}