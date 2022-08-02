# module: aws_vpc_peering
# this module creates a peering connection between two VPC's



## 1  from main: create the VPC peering from the primary VPC

###  peer_vpc_id  = the  accepter VPC id
###  vpc_id       = the  request VPC id
resource "aws_vpc_peering_connection" "main" {
  provider      = aws.requester
  peer_owner_id = var.accepter_account_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_region   = var.aws_accepter_provider_region
  vpc_id        = var.requester_vpc_id
  tags          = merge(var.tags, tomap({"Name", "VPC Peering between ${var.aws_requester_account} [${var.requester_vpc_id}-${var.aws_requester_provider_region}] and ${var.aws_accepter_account} [${var.accepter_vpc_id}-${var.aws_accepter_provider_region}]"}))
  auto_accept   = false
}

## 2  from accepter: accept the connection created

resource "aws_vpc_peering_connection_accepter" "main" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept               = true
  tags                      = merge(var.tags, tomap({"Name", "VPC Peering between ${var.aws_requester_account} [${var.requester_vpc_id}] and ${var.aws_accepter_account} [${var.accepter_vpc_id}]"}))
}

/*
  This null_resource delay protects against AWS VPC Peering
  APIs responding with lazy "active" status responses
  (AWS API supports eventually consistent read instead of read-after-write consistency)
  Start the count after
  (1) the peering request is initiated by the requester and
  (2) the peering request is accepted by the accepter
*/

resource "null_resource" "delay" {
  depends_on = [aws_vpc_peering_connection.main, aws_vpc_peering_connection_accepter.main]

  provisioner "local-exec" {
    command = "/bin/sleep 5"
  }
}

## 3 from both: create the connection options

resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.requester
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  requester {
    allow_remote_vpc_dns_resolution = var.requester_dns_resolution
  }

  depends_on = [null_resource.delay]
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  accepter {
    allow_remote_vpc_dns_resolution = var.accepter_dns_resolution
  }

  depends_on = [null_resource.delay]
}

# 4 update the route tables for both main and accepter VPC's
data "aws_vpc" "main" {
  provider = aws.requester
  id       = var.requester_vpc_id
}

data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.accepter_vpc_id
}

resource "aws_route" "requestor_routes" {
  provider                  = aws.requester
  count                     = length(var.requestor_route_tables)
  route_table_id            = element(var.requestor_route_tables, count.index)
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "accepter_routes" {
  provider                  = aws.accepter
  count                     = length(var.accepter_route_tables)
  route_table_id            = element(var.accepter_route_tables, count.index)
  destination_cidr_block    = data.aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
