

resource "authentik_flow" "neoception-enrollment-flow" {
  name        = "neoception-enrollment-flow"
  title       = "neoception-enrollment-flow"
  slug        = "neoception-enrollment-flow"
  designation = "enrollment"

}

resource "authentik_policy_binding" "neoception-access" {
  target = authentik_flow.neoception-enrollment-flow.uuid
  policy = authentik_policy_expression.gitlab-neoception.id
  order  = 0

  depends_on = [
    authentik_policy_expression.gitlab-neoception,
    authentik_flow.neoception-enrollment-flow
  ]
}



resource "authentik_flow_stage_binding" "prompt-binding" {
  target = authentik_flow.neoception-enrollment-flow.uuid
  stage  = data.authentik_stage.default-source-enrollment-prompt.id
  order  = 0

  depends_on = [
    authentik_flow.neoception-enrollment-flow,
    data.authentik_stage.default-source-enrollment-prompt
  ]
}

# resource "authentik_policy_binding" "prompt-stage-binding" {
#   target = data.authentik_stage.default-source-enrollment-prompt.id
#   policy = authentik_policy_expression.neoception-if-username.id
#   order  = 0

#   depends_on = [
#     data.authentik_stage.default-source-enrollment-prompt,
#     authentik_policy_expression.neoception-if-username
#   ]
# }

resource "authentik_flow_stage_binding" "write-binding" {
  target = authentik_flow.neoception-enrollment-flow.uuid
  stage  = data.authentik_stage.default-source-enrollment-write.id
  order  = 1

  depends_on = [
    authentik_flow.neoception-enrollment-flow,
    data.authentik_stage.default-source-enrollment-write
  ]
}

resource "authentik_flow_stage_binding" "login-binding" {
  target = authentik_flow.neoception-enrollment-flow.uuid
  stage  = data.authentik_stage.default-source-enrollment-login.id
  order  = 2

  depends_on = [
    authentik_flow.neoception-enrollment-flow,
    data.authentik_stage.default-source-enrollment-login
  ]
}
