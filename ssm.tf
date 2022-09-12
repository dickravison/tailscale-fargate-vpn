#SSM Parameter to hold the state value, ignore changes to the value as it will be managed in the console
resource "aws_ssm_parameter" "state" {
  name  = "/tailscale/state"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value, ]
  }
}

#SSM Parameter to hold the authkey value, ignore changes to the value as it will be managed in the console
resource "aws_ssm_parameter" "authkey" {
  name  = "/tailscale/authkey"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value, ]
  }
}