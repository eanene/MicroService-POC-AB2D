variable "aws_region" {
    type = string
  
}
variable "aws_account_number" {
    type = string
  
}
variable "vpc_name_tag" {
    type = string
  
}
variable "private_subnet_name_tag_a" {
    type = string
  
}
variable "private_subnet_name_tag_b" {
    type = string
  
}
variable "public_subnet_name_tag_a" {
    type = string
  
}
variable "public_subnet_name_tag_b" {
    type = string
  
}
variable "environment" {
    type = string
  
}

variable "contract_service_image" {
    type = string 

}
variable "aggregator_service_image" {
    type = string 

}
variable "coverage_service_image" {
    type = string 

}
variable "api_service_image" {
    type = string 

}
variable "audit_service_image" {
    type = string 

}
variable "eob_fetcher_service_image" {
    type = string 

}
variable "events_service_image" {
    type = string 

}
variable "jobs_service_image" {
    type = string 

}
variable "parameter_service_image" {
    type = string 

}
variable "env" {
    type = string
    description = "for the name policy associated with ecs task definition"
  
}
variable "database_name" {
    type =string
  
}