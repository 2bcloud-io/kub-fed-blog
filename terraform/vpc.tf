### VPC for first cluster
module "vpc_1" {
  providers = {
    aws = aws.first
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  name    = "eks-federated-1"
  cidr    = "10.100.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  public_subnets  = ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  public_subnet_tags = {
    "kubernetes.io/cluster/eks-federated-1" = "shared"
    "kubernetes.io/role/elb"                = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-federated-1" = "shared"
    "kubernetes.io/role/internal-elb"       = 1
  }

  tags = local.tags
}

### VPC for second cluster
module "vpc_2" {
  providers = {
    aws = aws.second
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  name    = "eks-federated-2"
  cidr    = "10.110.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.110.1.0/24", "10.110.2.0/24", "10.110.3.0/24"]
  public_subnets  = ["10.110.4.0/24", "10.110.5.0/24", "10.110.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  public_subnet_tags = {
    "kubernetes.io/cluster/eks-federated-2" = "shared"
    "kubernetes.io/role/elb"                = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-federated-2" = "shared"
    "kubernetes.io/role/internal-elb"       = 1
  }

  tags = local.tags
}


data "aws_caller_identity" "peer" {
  provider = aws.second
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  provider      = aws.first
  vpc_id        = module.vpc_1.vpc_id
  peer_vpc_id   = module.vpc_2.vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = "us-west-2"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
  depends_on = [module.vpc_1, module.vpc_2]
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.second
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
  depends_on = [aws_vpc_peering_connection.peer]
}

resource "aws_route" "first_priv" {
  provider                  = aws.first
  route_table_id            = element(module.vpc_1.private_route_table_ids, 1)
  destination_cidr_block    = module.vpc_2.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "second_priv" {
  provider                  = aws.second
  route_table_id            = element(module.vpc_2.private_route_table_ids, 1)
  destination_cidr_block    = module.vpc_1.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

