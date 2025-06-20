# Terraform AWS VPC Module Tests

This directory contains comprehensive tests for the Terraform AWS VPC module using [Terratest](https://terratest.gruntwork.io/).

## Test Coverage

The test suite verifies the following components:

### 1. VPC Creation (`TestVPCCreated`)
- Verifies VPC is created with correct CIDR block
- Checks VPC state is available
- Validates DNS support and DNS hostnames are enabled
- Confirms proper tagging

### 2. Subnet Creation (`TestSubnetsCreated`)
- Verifies all subnet types are created:
  - Public subnets (2)
  - Private subnets (2)
  - Database subnets (2)
  - Secondary subnets (2)
- Checks subnet states are available
- Validates CIDR blocks and availability zones
- Confirms public subnets have map public IP enabled

### 3. NAT Gateway Creation (`TestNATGatewayCreated`)
- Verifies NAT gateways are created (2 primary + 2 secondary)
- Checks NAT gateway states are available
- Validates Elastic IP allocation
- Confirms proper addressing

### 4. VPC Flow Log Setup (`TestVPCFlowLogSetup`)
- Verifies VPC flow logs are configured
- Checks both CloudWatch and S3 destinations
- Validates S3 bucket existence
- Confirms flow log status is active

### 5. Route Configuration (`TestRoutesConfigured`)
- Verifies route tables are created:
  - Public route table
  - Private route table
  - Database route table
- Checks routes are properly configured:
  - Public routes to Internet Gateway
  - Private routes to NAT Gateway
- Validates route table associations

## Prerequisites

- Go 1.21 or later
- AWS credentials configured
- Terraform installed
- AWS CLI configured

## Running Tests

### Using Make (Recommended)

```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run tests with report generation
make test-report

# Clean test artifacts
make clean

# Install dependencies
make deps

# Format code
make fmt

# Vet code
make vet
```

### Using Go directly

```bash
# Install dependencies
go mod download

# Run tests
go test -v -timeout 60m

# Run tests with coverage
go test -v -timeout 60m -coverprofile=coverage.out
```

## Test Configuration

The tests use the following configuration:

- **AWS Region**: `ap-southeast-1`
- **Test Prefix**: `terratest`
- **Environment**: `test`
- **Timeout**: 60 minutes

## Test Reports

The test suite generates comprehensive reports:

- **JSON Report**: `test-report.json`
- **HTML Report**: `test-report.html`
- **Coverage Report**: `coverage.html` (when using coverage)

## Environment Variables

The following environment variables can be set:

- `AWS_DEFAULT_REGION`: Override the default AWS region
- `AWS_PROFILE`: Specify AWS profile to use
- `TF_VAR_*`: Pass variables to Terraform

## Test Structure

```
tests/
├── terraform_test.go    # Main test file
├── go.mod              # Go module dependencies
├── Makefile           # Build automation
└── README.md          # This file
```

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS credentials are properly configured
2. **Permissions**: Verify IAM permissions for VPC, EC2, S3, and CloudWatch
3. **Region**: Ensure the test region supports all required services
4. **Timeouts**: Increase timeout if tests fail due to slow resource creation

### Debug Mode

To run tests with verbose output:

```bash
go test -v -timeout 60m -args -test.v
```

## Contributing

When adding new tests:

1. Follow the existing test structure
2. Add appropriate assertions
3. Update this README
4. Ensure tests clean up resources
5. Add test to the main test suite

## Dependencies

- [Terratest](https://github.com/gruntwork-io/terratest): Infrastructure testing framework
- [AWS SDK for Go v2](https://github.com/aws/aws-sdk-go-v2): AWS API client
- [Testify](https://github.com/stretchr/testify): Testing toolkit
- [terraform-test-util](https://github.com/oozou/terraform-test-util): Test reporting utilities
