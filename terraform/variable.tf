variable "project_id" {
  description = "ID du projet Google Cloud"
  type        = string
  default	  = "refined-gravity-448109-m7"
}

variable "region" {
  description = "Région de déploiement"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone de déploiement"
  type        = string
  default     = "europe-west1-b"
}

variable "credentials_file" {
  description = "Chemin du fichier de credentials GCP"
  type        = string
  default     = "C:/Users/ndoubli/AppData/Local/Google/Cloud SDK/credentials.json"
}
