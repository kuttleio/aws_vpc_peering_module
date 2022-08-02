// a peering connection is established between 2 VPCs.
//  The initiator of the peering connection is known here as "requester"
//  The peering request, once initiated, is sent to the "accepter"

variable "aws_requester_account" {
  description = "identifier for the requester account"
  type        = string
}

variable "aws_accepter_account" {
  description = "identifier for the accepter account"
  type        = string
}

variable "aws_requester_provider_region" {
  description = "region of the requester vpc"
  type        = string
}

variable "aws_requester_role_arn" {
  description = "the role to be assumed to update the resources associated with the request"
  type        = string
}

//  the region of the "accepter" vpc
variable "aws_accepter_provider_region" {
  description = "region of the accepter vpc"
  type        = string
}

variable "aws_accepter_role_arn" {
  description = "role to be assumed to update the resources associated with the accepter"
  type        = string
}

variable "accepter_account_id" {
  description = "account id of the accepter.  It will be the same account id as the requester if both vpc's belong to the same account."
  type        = string
}

variable "requester_vpc_id" {
  description = "id of the requester vpc"
  type        = string
}

variable "accepter_vpc_id" {
  description = "id of the accepter vpc"
  type        = string
}

variable "requestor_route_tables" {
  description = "route tables associated with the requester vpc"
  type        = list
}

variable "accepter_route_tables" {
  description = "route tables associated with the accepter vpc"
  type        = list
}

variable "tags" {
  description = "(optional) tags/metadata for the peering connection (pcx-) ojbect"
  type        = map
  default     = {}
}

variable "requester_dns_resolution" {
  description = "(optional) flag to indicate if dns resolution is turned on in the requester VPC.  This can only be set true if 'enable_dns_hostnames' is turned on in the requester VPC.'"
  type        = string
  default     = "1"
}

variable "accepter_dns_resolution" {
  description = "(optional) flag to indicate if dns resolution is turned on in the accepter VPC.  This can only be set true if 'enable_dns_hostnames' is turned on in the accepter VPC.'"
  type        = string
  default     = "1"
}
