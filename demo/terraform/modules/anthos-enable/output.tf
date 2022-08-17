output "acm-sa" {
  value = google_service_account.acm-sa.email
}

output "repo-url" {
  value = google_sourcerepo_repository.gke-poc-config-sync.url
}