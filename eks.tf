#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group" "mc_instance_k8s_api_access" {
  name        = "unity-ads-${var.cluster_name}-mc-sg"
  description = "Security group to allow access to K8s API from MC instance"

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  tags = {
    Name = "unity-ads-${var.cluster_name}-mc-sg"
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow from variable defined input port
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.external.current_ip.result.ip}/32"]
  }

}

#tfsec:ignore:aws-ec2-no-public-egress-sgr tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = data.aws_ssm_parameter.vpc_id.value
  subnet_ids = local.subnet_map["private"]

  enable_irsa                   = true
  create_iam_role               = true
  iam_role_name                 = "unity-ads-${var.cluster_name}-EKSClusterRole"
  iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    create_iam_role               = true
    iam_role_name                 = "unity-ads-${var.cluster_name}-EKSNodeRole"
    iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
    ami_id                        = data.aws_ssm_parameter.ami_id.value

    # This seemes necessary so that MCP EKS ami images can communicate with the EKS cluster
    enable_bootstrap_user_data = true
    pre_bootstrap_user_data    = <<-EOT
      sudo sed -i 's/^net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf && sudo sysctl -p |true
    EOT

    # Ensure that cost tags are applied to dynamically allocated resources
    launch_template_tags = local.cost_tags
  }

  eks_managed_node_groups = {
    jupyter = {
      instance_types = ["t3.xlarge", "t3.medium"]
      disk_size      = 100
      min_size       = 2
      max_size       = 10
      desired_size   = 4
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  #access_entries = {
  #  # One access entry with a policy associated
  #  example = {
  #    kubernetes_groups = []
  #    principal_arn     = "arn:aws:iam::123456789012:role/something"

  #    policy_associations = {
  #      example = {
  #        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #        access_scope = {
  #          namespaces = ["default"]
  #          type       = "namespace"
  #        }
  #      }
  #    }
  #  }
  #}

  # add MC instance access to K8s API
  cluster_additional_security_group_ids = [aws_security_group.mc_instance_k8s_api_access.id]

  tags = local.cost_tags
}

resource "null_resource" "kubectl" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name}"
  }
}
