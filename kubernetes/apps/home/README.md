# Home Automation Apps - Akeyless Secrets Configuration

This document outlines the required secrets that need to be configured in Akeyless for the home automation applications.

## Required Akeyless Secret Keys

### `/zigbee2mqtt`
MQTT credentials for Zigbee2MQTT to connect to your MQTT broker.

```json
{
  "MQTT_USERNAME": "zigbee2mqtt_user",
  "MQTT_PASSWORD": "super_secure_mqtt_password_123"
}
```

### `/scrypted`
Scrypted application secrets and configuration.

```json
{
  "SCRYPTED_WEBHOOK_UPDATE_AUTHORIZATION": "Bearer your_webhook_token_here_abc123",
  "SCRYPTED_ADMIN_PASSWORD": "admin_password_456",
  "SCRYPTED_API_KEY": "scrypted_api_key_789"
}
```

### `/esphome`
ESPHome dashboard and API configuration.

```json
{
  "ESPHOME_USERNAME": "esphome_admin",
  "ESPHOME_PASSWORD": "esphome_secure_password_321",
  "ESPHOME_API_PASSWORD": "esphome_api_password_654"
}
```

## Notes

- Replace all example values with your actual credentials
- Ensure your MQTT broker is accessible from the Kubernetes cluster
- The webhook authorization token for Scrypted should match your update webhook configuration
- ESPHome credentials are used for dashboard authentication and API access
- All secrets are automatically injected into the respective applications via External Secrets Operator

## Verification

After configuring the secrets in Akeyless, you can verify they're being pulled correctly by checking the External Secret status:

```bash
kubectl get externalsecrets -n home
kubectl describe externalsecret zigbee2mqtt -n home
kubectl describe externalsecret scrypted -n home
kubectl describe externalsecret esphome -n home
```
