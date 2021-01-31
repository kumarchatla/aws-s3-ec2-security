# --------------------------------------------------------------------------------------------------------------
# setup aws credentials in your local and use profile
# --------------------------------------------------------------------------------------------------------------


provider "aws" {
  region     = "us-west-2"
  profile    = "myprofile"
}

# ----------------------------------------------------------------------------------------
# Create S3 bucket
# ----------------------------------------------------------------------------------------
resource "aws_s3_bucket" "s3_open" {
  bucket = "my-code-files"
  acl           = "private"
tags = {
    Name = "Code test S3 Bucket"
  }
}


resource "aws_s3_bucket_policy" "s3_open" {
  bucket = "my-code-files"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action":["s3:Get*"],
      "Resource": "${aws_s3_bucket.s3_open.arn}/*",
      "Condition" : {
          
        "StringNotEquals": {
          "aws:sourceVpce": "vpc-e752ff81"
          
        }
      }
    }
  ]
}
POLICY
}


# ----------------------------------------------------------------------------------------
# setup instance profile
# ----------------------------------------------------------------------------------------
resource "aws_iam_role" "testhost" {
  name        = "s3ec2test"
  description = "privileges for the test instance"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_policy" "s3access" {
  name        = "s3ec2test"
  description = "allow read access to specific bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_open.arn}",
        "${aws_s3_bucket.s3_open.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3access" {
  role       = aws_iam_role.testhost.name
  policy_arn = aws_iam_policy.s3access.arn
}

resource "aws_iam_instance_profile" "testhost" {
  name = aws_iam_role.testhost.name
  role = aws_iam_role.testhost.id
}


# ----------------------------------------------------------------------------------------
# setup an EC2 instance
# ----------------------------------------------------------------------------------------

resource "aws_instance" "testhost" {


  ami           = "ami-0a36eb8fadc976275"
  instance_type = "t2.micro"
  key_name      = "codetestsg"
  subnet_id     = "subnet-007ff55b"
  vpc_security_group_ids = ["sg-01dcb4fed4e2ccfdc"]
  iam_instance_profile = aws_iam_instance_profile.testhost.name

  user_data = <<EOF
#!/bin/bash
yum update -y -q
yum install -y python3-pip
yum update -y aws-cli
pip3 install awscli --upgrade
EOF
}

resource "aws_ebs_volume" "CodeTestEBS" {
  availability_zone = aws_instance.testhost.availability_zone
  size              = 1
  tags = {
    Name = "CodeTestEBS"
  }
}

resource "aws_volume_attachment" "EBSattach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.CodeTestEBS.id
  instance_id = aws_instance.testhost.id
  force_detach = true
}
