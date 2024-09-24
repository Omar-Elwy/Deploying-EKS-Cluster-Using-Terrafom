# Existing module from Terraform Website..
module "eks" {
    // all variables declared here is ""specific"" to that module---- check the module Doc (input attributes)#####################
  source  = "terraform-aws-modules/eks/aws"
  version = "18.21.0"
  
  cluster_name = "myapp-eks-cluster"  
  // Kubernetes Version..
  cluster_version = "1.22"

   // For sure worker nodes operate in private subnets..
  // (private_subnets & vpc_id) : 
  // is the (output) attibutes names from
  // the actual VPC Imported Module
  // we can navigate it in terraform reg website
  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }
}
