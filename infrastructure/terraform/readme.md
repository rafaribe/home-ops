## Load Minio S3 backend details for Terraform

The `load_minio` function is a Fish shell function that loads the necessary environment variables to interact with the Minio S3 backend for Terraform. This function is useful when you need to configure Terraform to use the Minio S3 backend for state management.
You can view the source for it [here](https://github.com/rafaribe/dotfiles/blob/main/dot_config/fish/functions/custom/minio.fish)

After running `load_minio`, you can use Terraform commands as usual, and Terraform will use the configured Minio S3 backend for state management.


```fish
function load_minio
    set -l MINIO_UUID "4bac1bcd-ef9e-4a60-97b2-af3201766c37" # The UUID of my Minio creds in Bitwarden
    set -gx AWS_ACCESS_KEY_ID "$(bw get item $MINIO_UUID | jq -r '.fields[] | select(.name == "AWS_ACCESS_KEY_ID").value')"
    set -gx AWS_SECRET_ACCESS_KEY "$(bw get item $MINIO_UUID | jq -r '.fields[] | select(.name == "AWS_SECRET_ACCESS_KEY").value')"
    set -gx AWS_ENDPOINT_URL_S3 "$(bw get item $MINIO_UUID | jq -r '.fields[] | select(.name == "AWS_ENDPOINT_URL_S3").value')"
end
```