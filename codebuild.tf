provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA2GV7V4IAC4WJPIGC"
  secret_key = "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"
}
resource "aws_iam_role" "Cpsoft" {
  name = "Cpsoft"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "CpsoftRolePolicy" {
  role = aws_iam_role.Cpsoft.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "ecs:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "*"
         ]
      }
  ]
}
POLICY
}

resource "aws_codebuild_project" "Cpsoft" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "Cpsoft-app-build"
  queued_timeout = 480
  service_role   = aws_iam_role.Cpsoft.arn
  tags = {
    Environment = "Env"
  }

  artifacts {
    encryption_disabled = false
    # name                   = "container-app-code-${var.env}"
    # override_artifact_name = false
    type      = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

   environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "701555401216"
    }
  environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "cpsoftecr2"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    #buildspec           = "bs/buildspec.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "GITHUB"
   location        = "https://github.com/kari-venkatesh/codebuildproject.git"
  }
}

resource "aws_codebuild_webhook" "exampleCpsoft" {
  project_name = aws_codebuild_project.Cpsoft.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "master"
    }
  }
}
resource "aws_ecr_repository" "cpsoftecr2" {
  name                 = "cpsoftecr2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
