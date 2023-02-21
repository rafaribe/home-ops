# We need this data source for the remote terraform state file
data "terraform_remote_state" "project_instances" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces = {
      name = "home-doppler"
    }
  }
}

# output "doppler_service_tokens" {
#   value = merge(flatten([
#     for instance_state in data.terraform_remote_state.project_instances.outputs : [
#       for environment, config in instance_state.service_tokens : {
#         "${instance_state.project_name}-${environment}" = {
#           project       = instance_state.project_name
#           environment   = environment
#           service_token = config.name
#         }
#       }
#     ]
#   ]))
# }

