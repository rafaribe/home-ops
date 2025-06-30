# ChartDB

ChartDB is a powerful, web-based database diagramming editor that allows you to instantly visualize your database schema with a single "Smart Query."

## Features

- **Instant Schema Import**: Run a single query to instantly retrieve your database schema as JSON
- **AI-Powered Export**: Generate DDL scripts in different database dialects for easy migration
- **Interactive Editing**: Fine-tune your database schema using the intuitive editor
- **No Account Required**: Access all features without creating an account

## Supported Databases

- PostgreSQL (+ Supabase + Timescale)
- MySQL
- SQL Server
- MariaDB
- SQLite (+ Cloudflare D1)
- CockroachDB
- ClickHouse

## Configuration

The deployment uses:
- **Image**: `ghcr.io/chartdb/chartdb:1.13.0`
- **Chart**: bjw-s app-template via OCI repository (`oci://ghcr.io/bjw-s-labs/helm/app-template:4.1.2`)
- **Namespace**: `development`

### Optional AI Features

To enable AI-powered features, you can uncomment and configure the `OPENAI_API_KEY` environment variable in the HelmRelease.

## Access

Once deployed, ChartDB will be available at: `https://chartdb.rafaribe.com`

## Resources

- [ChartDB GitHub Repository](https://github.com/chartdb/chartdb)
- [Official Demo](https://app.chartdb.io)
- [Documentation](https://chartdb.io)
- [bjw-s app-template](https://github.com/bjw-s-labs/helm-charts)
