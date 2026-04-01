# Provider Auth, Region, and Tags

## Provider Baseline

```hcl
provider "aws" {
  region = "us-east-1"
}
```

## Authentication Patterns

Preferred:
- Use environment-based credentials or role assumption.
- Use named profile only when that profile is managed and valid.

Profile example:

```hcl
provider "aws" {
  region  = "us-west-2"
  profile = "customprofile"
}
```

Assume role example:

```hcl
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/ROLE_NAME"
    session_name = "terraform-session"
    external_id  = "external-id"
  }
}
```

Web identity example:

```hcl
provider "aws" {
  region = "us-east-1"
  assume_role_with_web_identity {
    role_arn     = "arn:aws:iam::123456789012:role/MyWebRole"
    session_name = "TerraformWebSession"
  }
}
```

Notes:
- With explicit `profile`, invalid profile credentials can fail auth instead of falling back.
- Keep credential sourcing predictable per environment.

## Default and Ignored Tags

Default tags:

```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
```

Ignore tag prefixes:

```hcl
provider "aws" {
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}
```

Guidance:
- Put organization-wide required tags in `default_tags`.
- Keep overrides local to resources that truly differ.
- Use `ignore_tags` only for tags owned by external controllers.

## Retry and Timeout Controls

Use provider retry settings for API transient behavior:

```hcl
provider "aws" {
  region      = "us-east-1"
  max_retries = 25
  retry_mode  = "standard"
}
```

Do not hide ordering/configuration problems with retries.
