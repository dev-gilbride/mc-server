data "aws_key_pair" "mc_key" {
  key_name = var.key_name
}

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

resource "aws_security_group" "allow_minecraft" {
  name        = "minecraft-server"
  description = "Allows the minecraft port"

  ingress {
    description      = "Allows SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allows Minecraft"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "minecraft-server"
    Managed = "Terraform"
  }
}

resource "aws_ebs_volume" "server_ssd" {
  availability_zone = var.availability_zone
  size              = 20
  type              = "gp3"

  tags = {
    Name    = "MinecraftServer"
    Managed = "Terraform"
  }
}

resource "aws_instance" "mc_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = data.aws_key_pair.mc_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_minecraft.id]
  availability_zone = var.availability_zone

  tags = {
    Managed = "Terraform"
    Purpose = "Temp-for-AMI-creation"
  }
}

resource "aws_volume_attachment" "mc_server_attachment" {
  device_name                    = var.device_name
  volume_id                      = aws_ebs_volume.server_ssd.id
  instance_id                    = aws_instance.mc_server.id
  stop_instance_before_detaching = true
}

#resource "aws_network_interface" "minecraft_ip" {
#  subnet_id       = aws_subnet.public_a.id
#  ipv4_prefix_count = 1
#  security_groups = [aws_security_group.allow_minecraft.id]
#
#  attachment {
#    instance     = aws_instance.mc_server.id
#    device_index = 1
#  }
#}