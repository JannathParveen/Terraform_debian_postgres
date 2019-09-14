
variable "aws_region" {
  description = "AWS region N.Virginia"
  default = "us-east-1"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default = "Debian 9 nginx"
}

variable "aws_vpc" {
  description = "VPC created in the other module"
  default = ""
  #vpc-0545c31c6870fbbbf"
}

variable "aws_subnet" {
  description = "subnet for instances"
  default = ""
  #default = "subnet-062f29b2da31a2715"
}

variable "instance_count" {
  default = "2"
}

################

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "MyKeyPair"
}

#variable "aws_region" {
#  description = "AWS region to launch servers."
#  default     = "us-east-2"
#}

# Ubuntu 9 AMI (x64)
variable "ami_id" {   # "aws_amis" {
    #type = "list"
    #default = "ami-0ed2d2283aa1466df"
    #}

    type = "map"

   default = {
     "us-east-1" = "ami-0ed2d2283aa1466df"
     "us-east-2" = "ami-07a0560634acb945f"
     "us-west-1" = "ami-0ff3a5bef845ec04f"
     "us-west-2" = "ami-0fdf2e9fd534f1b2f"
   }
  }

  #{  us-east-1 = "ami-0ed2d2283aa1466df"
  #  us-east-2 = "ami-07a0560634acb945f"
  #  us-west-1 = "ami-0ed2d2283aa1466df"
  #  us-west-2 = "ami-0ed2d2283aa1466df"
  #}

variable "public_key_path" {
 default = "/Users/rafi/.ssh/id_rsa" #.pub"
}
