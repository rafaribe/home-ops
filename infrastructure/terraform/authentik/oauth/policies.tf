resource "authentik_policy_expression" "neoception-if-username" {
    name = "neoception-source-enrollment-if-username"
    expression = <<EOF
# Check if we''ve not been given a username by the external IdP
# and trigger the enrollment flow
return 'username' not in context.get('prompt_data', {})
EOF
}



resource "authentik_policy_expression" "gitlab-neoception" {
  name       = "gitlab-neoception-backup"
  expression = <<EOF
ALLOWED_GROUP = 'neoception'
def check_if_exists(email, groups):

    ak_logger.info(f'This email is {email}')
    if ak_user_by(email=email):
        ak_logger.info(
            f'Someone tried to register with the same email address as one user already exists, {email}'
        )
        ak_message(
            'Someone tried to register with the same email address as one user already exists'
        )
        return False
    else:
        return validate_group(groups)


def validate_group(groups):
    try:
        if ALLOWED_GROUP in groups:
            ak_message('User belongs to {ALLOWED_GROUP}')
            return True
        else:
            ak_logger.info(f'The user does not belong to group {ALLOWED_GROUP}')
            ak_message(f'The user does not belong to Gitlab Group {ALLOWED_GROUP}')
            return False
    except Exception as e:
        ak_logger.error(
            f'The email validation has occurred an exception during execution. The exception: {e}'
        )
        ak_message('Validation failed')
        return False
return check_if_exists(context['oauth_userinfo']['email'],context['oauth_userinfo']['groups'])

EOF
}
