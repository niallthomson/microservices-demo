resource "aws_security_group" "provisioner" {
  name        = "${local.full_environment_prefix}-provisioner-sg"
  description = "Allow SSH access to provisioner host and outbound internet access"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  protocol          = "TCP"
  from_port         = 22
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "internet" {
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.provisioner.id
}

data "aws_ami" "default" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

locals {
  bastion_ami_id = data.aws_ami.default.id
  disk_size      = 64
  instance_type  = "t3.micro"
  username       = "ubuntu"
}

resource "aws_eip" "provisioner" {
  vpc      = true
  instance = aws_instance.provisioner.id
}

resource "aws_instance" "provisioner" {
  ami                    = local.bastion_ami_id
  instance_type          = local.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.provisioner.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  root_block_device {
    volume_size           = local.disk_size
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "${local.full_environment_prefix}-bastion"
  }
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.full_environment_prefix}-bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role" "bastion" {
  name               = "${local.full_environment_prefix}-bastion-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bastion_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion.name
}