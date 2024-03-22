# Creación de AWS Amplify, servira para mostrar la página en la internet pública
resource "aws_amplify_app" "front" {
  name                     = "${var.common_name}-app"
  repository               = var.repo
  access_token             = var.gh_token
  enable_branch_auto_build = true

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        build:
          commands: []
      artifacts:
        baseDirectory: /ciclo1
        files:
          - '**/*'
      cache:
        paths: []
  EOT


  environment_variables = {
    ENV = var.env
  }
}