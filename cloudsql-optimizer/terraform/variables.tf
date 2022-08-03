variable "project_id" {
    default = "earthapi-351012"
}

variable "region" {
    default = "europe-west1"
}

variable "zone" {
    default = "europe-west1-a" 
}

variable "credentials" {
    default = file("../../gcp.json")
}