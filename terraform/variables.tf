variable "subscription_id" {}
variable "tenant_id" {}
variable "access_key" {}
variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "./id_rsa.pub"
}

variable "dns_prefix" {
    default = "k8s-demo-1"
}

variable cluster_name {
    default = "k8s-demo-1"
}

variable resource_group_name {
    default = "k8s-demo-1-rg"
}

variable location {
    default = "Australia East"
}

variable log_analytics_workspace_name {
    default = "k8sDemoWorkspace"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "australiaeast"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}