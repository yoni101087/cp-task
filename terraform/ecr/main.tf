resource "aws_ecr_repository" "app1" {
  name = "app1"

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_ecr_repository" "app2" {
  name = "app2"

  image_scanning_configuration {
    scan_on_push = true
  }

}