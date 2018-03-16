variable "region" {
  description = "The AWS Region"
  default = "us-east-1"
}
# amzn-ami-2017.09.j-amazon-ecs-optimized is the latest	as of the date of writing
variable "ecs_ami_id" {
  description = "The ECS AMI ID"
  default = "ami-cad827b7"
}
