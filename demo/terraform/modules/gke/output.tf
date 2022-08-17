output "gke-name" {
    value = values(google_container_cluster.gke-clusters)[*].name 
}

output "gke-region" {
    value = values(google_container_cluster.gke-clusters)[*].location 
}

output "cluster_list" {
    value = google_container_cluster.gke-clusters 
}