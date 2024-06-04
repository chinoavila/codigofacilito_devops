provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

resource "aws_eks_cluster" "avatares" {
  name     = "avatares-cluster"
  role_arn = aws_iam_role.avatares.arn

  vpc_config {
    subnet_ids = ["subnet-03cd00d8fec17e483", "subnet-0c5c36da334fea7f9", "subnet-079ced7d25230d8ba"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.avatares-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.avatares-AmazonEKSServicePolicy,
  ]
}

resource "aws_iam_role" "avatares" {
  name = "avatares-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "avatares-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.avatares.name
}

resource "aws_iam_role_policy_attachment" "avatares-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.avatares.name
}

resource "aws_subnet" "avatares" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.avatares.id
}

resource "aws_vpc" "avatares" {
  cidr_block = "10.0.0.0/16"
}

resource "kubernetes_deployment" "avatares" {
  metadata {
    name = "avatares"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "avatares"
      }
    }

    template {
      metadata {
        labels = {
          app = "avatares"
        }
      }

      spec {
        container {
          name  = "backend-api"
          image = "033445731182.dkr.ecr.us-east-1.amazonaws.com/avatares-backend-api:latest"

          port {
            container_port = 5000
          }

          env {
            name  = "FLASK_APP"
            value = "app.py"
          }

          env {
            name  = "FLASK_ENV"
            value = "development"
          }

          command = ["flask", "run", "--host=0.0.0.0", "--port=5000"]
        }

        container {
          name  = "frontend-web"
          image = "033445731182.dkr.ecr.us-east-1.amazonaws.com/avatares-frontend-web:latest"

          port {
            container_port = 5173
          }

          env {
            name  = "VITE_HOST"
            value = "0.0.0.0"
          }

          env {
            name  = "VITE_PORT"
            value = "5173"
          }

          command = ["npm", "run", "dev"]
        }
      }
    }
  }
}



resource "kubernetes_service" "avatares" {
  metadata {
    name = "avatares"
  }

  spec {
    selector = {
      app = "avatares"
    }

    port {
      name        = "backend-api"
      port        = 5000
      target_port = 5000
    }

    port {
      name        = "frontend-web"
      port        = 5173
      target_port = 5173
    }

    type = "LoadBalancer"
  }
}
