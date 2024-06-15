data "authentik_flow" "default-source-authentication-flow" {
  slug = "default-source-authentication"
}

data "authentik_stage" "default-source-enrollment-prompt" {
  name = "default-source-enrollment-prompt"
}

data "authentik_stage" "default-source-enrollment-write" {
  name = "default-source-enrollment-write"
}

data "authentik_stage" "default-source-enrollment-login" {
  name = "default-source-enrollment-login"
}
