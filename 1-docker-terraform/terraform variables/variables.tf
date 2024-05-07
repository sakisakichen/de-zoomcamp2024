variable "location" {
  description = "Location for GCP bucket"
  default     = "US"
}



variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

variable "gcp_storage_class" {
  description = "Storage class for GCP bucket"
  default     = "STANDARD"
}


variable "gcs_bucket_name" {
  description = "Name for GCP bucket"
  default     = "dulcet-bastion-419415-terra-bucket"
}