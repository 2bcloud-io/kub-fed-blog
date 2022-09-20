module "eks_1" {
  providers = {
    aws = aws.first
  }
  source           = "terraform-aws-modules/eks/aws"
  version          = "15.1.0"
  cluster_name     = "eks-federated-1"
  cluster_version  = "1.22"
  subnets          = concat(module.vpc_1.private_subnets, module.vpc_1.public_subnets)
  write_kubeconfig = false
  enable_irsa      = true
  manage_aws_auth  = false
  vpc_id           = module.vpc_1.vpc_id

  node_groups = {

    ng-1 = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3
      instance_types   = ["t3.medium"]
      subnets          = module.vpc_1.private_subnets
      additional_tags = {
        Automation  = "Terraform"
        Owner       = "Arsen Hovhannisyan"
        Environment = "testing"
      }
    }
  }

  depends_on = [module.vpc_1]

  tags = local.tags

}

module "eks_2" {
  providers = {
    aws = aws.second
  }
  source           = "terraform-aws-modules/eks/aws"
  version          = "15.1.0"
  cluster_name     = "eks-federated-2"
  cluster_version  = "1.22"
  subnets          = concat(module.vpc_2.private_subnets, module.vpc_2.public_subnets)
  write_kubeconfig = false
  enable_irsa      = true
  manage_aws_auth  = false
  vpc_id           = module.vpc_2.vpc_id

  node_groups = {

    ng-1 = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3
      instance_types   = ["t3.medium"]
      subnets          = module.vpc_2.private_subnets
      additional_tags = {
        Automation  = "Terraform"
        Owner       = "Arsen Hovhannisyan"
        Environment = "testing"
      }
    }
  }

  depends_on = [module.vpc_2]

  tags = local.tags

}