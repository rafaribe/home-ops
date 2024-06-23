## Load Minio S3 backend details for Terraform

The `load_minio` function is a Fish shell function that loads the necessary environment variables to interact with the Minio S3 backend for Terraform. This function is useful when you need to configure Terraform to use the Minio S3 backend for state management.
You can view the source for it [here](https://github.com/rafaribe/dotfiles/blob/main/dot_config/fish/functions/custom/minio.fish)

After running `load_minio`, you can use Terraform commands as usual, and Terraform will use the configured Minio S3 backend for state management.
