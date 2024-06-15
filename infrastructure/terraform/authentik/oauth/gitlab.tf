resource "authentik_source_oauth" "gitlab" {

  name                = "gitlab"
  slug                = "gitlab"
  authentication_flow = data.authentik_flow.default-source-authentication-flow.id
  enrollment_flow     = authentik_flow.neoception-enrollment-flow.uuid

  provider_type       = "openidconnect"
  consumer_key        = var.gitlab_consumer_key
  consumer_secret     = var.gitlab_consumer_secret
  oidc_well_known_url = "https://gitlab.com/.well-known/openid-configuration"
  user_path_template  = "goauthentik.io/users/%(slug)s."

  depends_on = [
    data.authentik_flow.default-source-authentication-flow,
    authentik_flow.neoception-enrollment-flow
  ]

}
