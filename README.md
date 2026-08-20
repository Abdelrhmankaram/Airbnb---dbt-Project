# Airbnb dbt Project

This repository contains a dbt project for transforming raw Airbnb source data into curated analytics tables for reporting and downstream use. The project follows a layered warehouse design: staging models clean and standardize raw inputs, dimension/fact models build core business entities and event data, and mart models expose business-friendly datasets for analysis.

The project is configured for Snowflake and uses dbt package extensions for utility functions and data-quality tests.

## Project goals

- Standardize raw Airbnb listings, hosts, and reviews data
- Create trusted layer models for analytics and BI
- Enforce data quality with dbt tests and constraints
- Support incremental refreshes for high-volume review data
- Provide a business-oriented mart for analysis use cases

## Data model overview

The source system is modeled as a single `airbnb` source with three raw tables:

- `raw_listings` -> `source('airbnb', 'listings')`
- `raw_hosts` -> `source('airbnb', 'hosts')`
- `raw_reviews` -> `source('airbnb', 'reviews')`

These feeds are transformed into the following model layers:

### Staging layer

Located in `models/stg/`:

- `stg_listings.sql`  
  Extracts listing fields, renames IDs, and normalizes raw listing data.

- `stg_hosts.sql`  
  Pulls host details and standardizes null/anonymous handling where appropriate.

- `stg_reviews.sql`  
  Cleans review payloads and prepares them for downstream fact building.

### Dimension layer

Located in `models/dim/`:

- `dim_listings.sql`  
  Converts listing staging data into a cleaned dimension table with parsed pricing and normalized minimum-night logic.

- `dim_hosts.sql`  
  Builds a host dimension with null-safe naming and standard boolean logic.

- `dim_listings_w_hosts.sql`  
  Joins listing and host data for a denormalized analytics dimension.

### Fact layer

Located in `models/fact/`:

- `fct_reviews.sql`  
  Builds the review fact table, uses a surrogate key on `listing_id + review_date`, filters null review texts, and supports incremental loads.

### Mart layer

Located in `models/mart/`:

- `mart_fullmoon_reviews.sql`  
  Annotates reviews with a `is_full_moon` flag by joining review dates to a seed table of full moon dates.

- `unit_tests.yml`  
  Provides unit-style validation for the mart logic.

## Data quality and testing

This project uses dbt tests to validate core assumptions, including:

- uniqueness and non-null checks on primary keys
- accepted values for room types and sentiment
- relationship checks across dimensions and facts
- table-row comparisons and quantile checks
- row-count validation for core models

The project also uses a configured `data_tests` section that stores failed tests for auditing and troubleshooting.

## Project structure

```text
airbnb/
├── analyses/                 # ad hoc analytical SQL
├── dbt_packages/            # installed dbt packages
├── env_values/              # environment variable + private key files
├── logs/                    # dbt logs
├── macros/                  # reusable dbt macros
├── models/
│   ├── dim/                 # dimensional models
│   ├── fact/                # fact models
│   ├── mart/                # curated downstream models
│   ├── stg/                 # staging models
│   ├── schema.yml           # model and column tests/docs
│   └── sources.yml          # source definitions
├── seeds/                   # seed data such as full moon dates
├── snapshots/               # snapshot configs
├── tests/                   # custom data tests
├── .user.yml                # local dbt user config
├── dbt_project.yml          # dbt project settings
├── packages.yml             # external dbt packages
├── profiles.yml             # Snowflake profile definition
├── README.md                # project documentation
├── .gitignore               # ignored files
└── package-lock.yml         # lockfile for package versions
```

## Prerequisites

Before running this project, make sure you have:

- dbt Core installed
- Access to a Snowflake account
- A database role with the required privileges
- A valid private key file for authentication
- Environment variables for account, role, database, schema, warehouse, and private key path

## Environment configuration

The project reads its Snowflake settings from environment variables defined in `profiles.yml`:

- `ACCOUNT`
- `ROLE`
- `PRIVATE_KEY_PATH`
- `DATABASE`
- `SCHEMA`
- `WAREHOUSE`

Example environment file:

```env
ACCOUNT=YOUR_ACCOUNT
ROLE=TRANSFORM
PRIVATE_KEY_PATH=./env_values/rsa_key.p8
DATABASE=AIRBNB
SCHEMA=DEV
WAREHOUSE=COMPUTE_WH
```

On Windows PowerShell, you can load the variables using the project helper script:

```powershell
Get-Content .\env_values\.env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
    }
}
```

You can also use the provided script in `env_values/load_vars.ps1`.

## Common dbt commands

Run these from the project root:

```bash
dbt debug
```

Check that your Snowflake connection and project configuration are valid.

```bash
dbt deps
```

Install project dependencies (including dbt packages).

```bash
dbt run
```

Build all models defined in the project.

```bash
dbt test
```

Execute the configured dbt tests.

```bash
dbt build
```

Run both models and tests in one workflow.

```bash
dbt run --select mart_fullmoon_reviews
```

Build a specific model.

```bash
dbt test --select dim_listings
```

Run tests for a specific model.

## Incremental processing

The `fct_reviews` model is configured as incremental:

- materialization: `incremental`
- it fails on schema drift (`on_schema_change = 'fail'`)
- only new or newer review dates are loaded in subsequent runs

This makes it suitable for high-volume review data that is refreshed repeatedly without reprocessing the entire history.

## Audit logging

The project defines an `on-run-start` hook that creates or reuses an `audit_log` table in the target schema and inserts a row for each model run. This supports operational visibility into what has been built and when.

## Dependencies

This project includes the following dbt packages:

- `dbt-labs/dbt_utils`
- `metaplane/dbt_expectations`

These provide helper macros, generic tests, and expectation-based validations.

## Typical usage flow

1. Load environment variables
2. Run `dbt deps`
3. Run `dbt debug` to verify the connection
4. Run `dbt build` to compile and test the warehouse model layers
5. Query dimensions/facts/marts from Snowflake for analysis

## Notes

This is a practical, analytics-oriented dbt project built for an Airbnb-style dataset. It demonstrates common warehouse practices such as:

- source abstraction
- layered modeling
- test-driven development
- incremental fact loading
- seed-based enrichment logic
- domain-specific mart creation

## Resources

- dbt Documentation: https://docs.getdbt.com/
- dbt Discourse: https://discourse.getdbt.com/
- dbt Slack Community: https://community.getdbt.com/
- dbt blog: https://blog.getdbt.com/
