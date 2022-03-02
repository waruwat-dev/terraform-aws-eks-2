data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "eks_manifest" {
  template = file("${path.module}/templates/eks-manifest-file.yml")
  vars = {
    node_group_role_arn = var.node_group_role_arns[0]
    admin_role_arn      = var.admin_role_arn
    dev_role_arn        = var.dev_role_arn
    readonly_role_arn   = var.readonly_role_arn
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")
  vars = {
    aws_access_key_id     = var.aws_account.access_key
    aws_secret_access_key = var.aws_account.secret_key
    region                = var.aws_account.region
    cluster_name          = var.cluster_name
    eks_manifest_file     = data.template_file.eks_manifest.rendered
  }
}