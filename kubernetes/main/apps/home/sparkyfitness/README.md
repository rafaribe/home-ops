# SparkyFitness

SparkyFitness is a comprehensive self-hosted fitness tracking and management application designed as an alternative to MyFitnessPal. It provides tools for daily progress tracking, goal setting, and insightful reports to support a healthy lifestyle.

## Features

- **Nutrition Tracking**: Log daily meals, create custom foods and categories, view summaries with interactive charts
- **Exercise Logging**: Record workouts, browse exercise database, track fitness progress
- **Water Intake Monitoring**: Track daily hydration goals with simple logging
- **Body Measurements**: Record body metrics with custom measurement types and progress visualization
- **Goal Setting**: Set and manage fitness and nutrition goals with progress tracking
- **Daily Check-Ins**: Monitor daily activity and habit tracking
- **AI Nutrition Coach (SparkyAI)**: Log food via chat, upload food images, personalized guidance
- **User Authentication & Profiles**: Secure login system with family access support
- **Comprehensive Reports**: Generate nutrition and body metric summaries with trend tracking
- **Customizable Themes**: Light and dark mode with minimal interface

## Configuration

### Required Akeyless Secrets

Add the following JSON structure to Akeyless at path `/sparkyfitness`:

```json
{
  "SPARKY_FITNESS_API_ENCRYPTION_KEY": "your-64-character-hex-encryption-key-here",
  "JWT_SECRET": "your-secure-jwt-secret-here",
  "SPARKY_FITNESS_DISABLE_SIGNUP": "false",
  "SPARKY_FITNESS_ADMIN_EMAIL": "admin@rafaribe.com"
}
```

**Note**: Database credentials are automatically pulled from the existing `/cloudnativepg` secret:
- `POSTGRES_GENERIC_APP_PASSWORD` - Used for the application database password
- `POSTGRES_SUPER_PASS` - Used for database initialization

The database will be automatically created as:
- **Database Name**: `sparkyfitness`
- **Database User**: `sparkyfitness`
- **Database Host**: `home-ops-storage-rw.storage.svc.cluster.local`

### Generating Secure Keys

Generate the encryption key:
```bash
openssl rand -hex 32
```

Generate the JWT secret:
```bash
openssl rand -base64 32
```

## Database

The application uses PostgreSQL as its database backend. The deployment includes:

- Automatic database initialization using the `postgres-init` container
- Database connection configuration through environment variables
- Persistent storage for application data

## Access

- **Frontend URL**: https://sparkyfitness.rafaribe.com
- **Admin Panel**: Available to users with the configured admin email
- **API Documentation**: Disabled in production for security

## Notes

- The application is under heavy development and may have breaking changes
- Auto-upgrades are not recommended - check release notes for breaking changes
- Multi-user support and AI features are currently in beta
- Family & Friends access and Apple Health integration are experimental features

## Resources

- **GitHub Repository**: https://github.com/CodeWithCJ/SparkyFitness
- **Discord Support**: https://discord.gg/vcnMT5cPEA
- **Docker Images**: 
  - Frontend: `codewithcj/sparkyfitness:latest`
  - Backend: `codewithcj/sparkyfitness_server:latest`
