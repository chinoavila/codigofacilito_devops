terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "17.0.0"

    cluster_name = "cluster_avatares"
    cluster_version = "1.21"

    vpc_id = "vpc-0b413255a51931828"
    subnets = ["subnet-03cd00d8fec17e483","subnet-0c5c36da334fea7f9","subnet-079ced7d25230d8ba"]

    worker_groups = [
        {
            instance_type = "t2.micro"
            asg_desired_capacity = 2
        }
    ]
}
