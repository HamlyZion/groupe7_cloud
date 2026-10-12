variable "ami" {
    type = string
    default = "ami-0c809358d149b3ca3"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "security_groups" {
    type = list
    default = ["sg-0c8d1babe3860ff58"]
}

variable "ec2_iam_profile_name" {
    type = string
    default = "profil_iam_ec2"
}

variable "email_endpoint" {
    type = string
    default = "rufin.theo@gmail.com"
}
