# locals = values worked out inside the code. They are not inputs.
# Write them once here, then use local.<name> anywhere.
locals {
  name_prefix = "${var.project_name}-${var.environment}" # "terraform-aws-learning-dev"
}
