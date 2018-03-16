provider "aws" {
  region = "${var.region}"
}

# This is where we store the state
terraform {
  backend "s3" {
    bucket = "lobster1234-infrastructure"
    key    = "ecs/terraform.tfstate"
    region = "us-east-1"
  }
}
# Since we want to create our ECS cluster in the existing VPC, we refer to it here
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "lobster1234-infrastructure"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Our ECS cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

# Next, we will create a launch config for the ECS cluster
resource "aws_launch_configuration" "ecs_launch_config" {
  name_prefix   = "my-ecs-launch-config"
  image_id      = "${var.ecs_ami_id}"
  instance_type = "t2.small"
  associate_public_ip_address = false
  lifecycle {
    create_before_destroy = true
  }
  user_data    = <<EOF
                  #!/bin/bash
                  echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
                  EOF
}

# Now for the auto scaling group
resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "my-ecs-asg"
  vpc_zone_identifier = ["${data.terraform_remote_state.vpc.private-1a_subnet_id}","${data.terraform_remote_state.vpc.private-1d_subnet_id}"]
  health_check_type         = "EC2"
  launch_configuration = "${aws_launch_configuration.ecs_launch_config.name}"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  lifecycle {
    create_before_destroy = true
  }
  tag {
   key                 = "type"
   value               = "ecs"
   propagate_at_launch = true
 }
}
