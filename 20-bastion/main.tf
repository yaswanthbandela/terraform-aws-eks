# This module creates a bastion host in the public subnet of the VPC.
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-bastion"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  subnet_id              = local.public_subnet_id
  ami                    = data.aws_ami.ubuntu.id  
  key_name               = var.bastion_ssh_key  # Use SSH key for authentication
  user_data              = file("bastion.sh")

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}
