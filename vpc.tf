provider "aws" {
    region = "eu-west-2"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

// To fetch the AZs dynamically from the AWS Region we provided up there in line 2 in the provider block..
// We didnt specify the region because it takes the region specified in the provider block..
data "aws_availability_zones" "available" {}


/* CloudFormation Template is insfrustucure provisinoing
tool to work like Terraform to create only the VPC and 
its associated only with AWS So Terraform Is much better
to use because it is general infrustructure provisiong
tool */

# Existing module from Terraform Website..
module "myapp-vpc" {
  // all variables declared here is ""specific"" to that module---- check the module Doc (input attributes)#####################
    source = "terraform-aws-modules/vpc/aws"
    version = "2.64.0"

    name = "myapp-vpc"
    cidr = var.vpc_cidr_block

    // Private and public subnets to be deployed
    // in all availablity zones..

    // Private For the actual workload (worker nodes)
    // Nat Gateway
    private_subnets = var.private_subnet_cidr_blocks   // List of private_subnets // We assign their values in .tfvars file

    // Public For external resources like load balancer
    // Intrenet Gateway
    public_subnets = var.public_subnet_cidr_blocks	// List of public_subnets // We assign their values in .tfvars file
    
    // Check the AZs Doc in Terraform website to know the available attributes you can refernce here lke (names)
    azs = data.aws_availability_zones.available.names 
    
    // its enabled by default
    enable_nat_gateway = true
    
    // all private subnets will route their internet traffic to this nat gateway
    single_nat_gateway = true
    
    /*for example when an ec2 will be created it will 
    be assigned with public and private IPs and when
    we enable that it will get public and private
    DNS names as a resault to theis IPs*/
    enable_dns_hostnames = true

    /* tags also for refrecing components from other
    components (programatically)*/

    /* one of the process of the control plane is 
    kubernets cloud controller manager,, it comes
    from AWS.. hwa elli byzbt el connection to
    VPCs,, Worker nodes,, subnets
    Basicly talking to resources in our AWS account*/

    /* cloud controller manager needs to know which 
    resources to talk to and which VPC and Subnets
    should be used
    so we need to tag all of them VPC and Private,Public
    Subnets*/

    // tag the VPC
    tags = {
        // myapp-eks-cluster Equal to the one in eks-cluster.tf  //cluster_name = "myapp-eks-cluster"
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    }

    // tag the public_subnets
    public_subnet_tags = {
    // myapp-eks-cluster Equal to the one in eks-cluster.tf  //cluster_name = "myapp-eks-cluster"
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        // Cloud native loadbalancer OR elasic loadbalancer
        // cause its the entry point for the cluster
        // so we should tell kubernetes whic one will be the public subnet
        // by differentiating between public and private like this ( elb for public & internal-elb for private )      
        "kubernetes.io/role/elb" = 1 
    }
 
    // tag the private_subnets
    private_subnet_tags = {  
    // myapp-eks-cluster Equal to the one in eks-cluster.tf  //cluster_name = "myapp-eks-cluster"      
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"   
        "kubernetes.io/role/internal-elb" = 1 
    }
    // all these tags are required
}
