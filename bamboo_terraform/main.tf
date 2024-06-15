provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform_aws_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "bamboo_demo" {
  ami             = "ami-0a91cd140a1fc148a" # Ubuntu Server 24.04 LTS (HVM)
  instance_type   = "t2.micro"
  availability_zone = "us-east-1b"
  key_name        = aws_key_pair.deployer.key_name

  tags = {
    Name = "bamboo-demo"
  }
}

resource "aws_eip" "bamboo_demo_eip" {
  instance = aws_instance.bamboo_demo.id
}

resource "aws_route53_record" "bamboo_demo" {
  zone_id = "YOUR_ROUTE53_ZONE_ID" # Replace with your actual Route 53 zone ID
  name    = "bamboo_demo.climacs.net"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bamboo_demo_eip.public_ip]
}

output "instance_id" {
  value = aws_instance.bamboo_demo.id
}

output "public_ip" {
  value = aws_eip.bamboo_demo_eip.public_ip
}

output "dns_name" {
  value = aws_route53_record.bamboo_demo.fqdn
}
