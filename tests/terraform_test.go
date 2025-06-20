package test

import (
	"context"
	"flag"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/oozou/terraform-test-util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Global variables for test reporting
var (
	generateReport bool
	reportFile     string
	htmlFile       string
)

// TestMain enables custom test runner with reporting
func TestMain(m *testing.M) {
	flag.BoolVar(&generateReport, "report", false, "Generate test report")
	flag.StringVar(&reportFile, "report-file", "test-report.json", "Test report JSON file")
	flag.StringVar(&htmlFile, "html-file", "test-report.html", "Test report HTML file")
	flag.Parse()

	exitCode := m.Run()
	os.Exit(exitCode)
}

func TestTerraformAWSVPCModule(t *testing.T) {
	t.Parallel()

	// Record test start time
	startTime := time.Now()
	var testResults []testutil.TestResult

	// Pick a random AWS region to test in
	awsRegion := "ap-southeast-1"

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/terraform-test",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"prefix":      "terratest",
			"environment": "test",
			"custom_tags": map[string]string{"test": "true"},
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		terraform.Destroy(t, terraformOptions)
	}()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// If terraform apply failed, don't run the individual tests
	if t.Failed() {
		t.Fatal("Terraform apply failed, skipping individual tests")
		return
	}

	// Define test cases with their functions
	testCases := []struct {
		name string
		fn   func(*testing.T, *terraform.Options, string)
	}{
		{"TestVPCCreated", testVPCCreated},
		{"TestSubnetsCreated", testSubnetsCreated},
		{"TestNATGatewayCreated", testNATGatewayCreated},
		{"TestVPCFlowLogSetup", testVPCFlowLogSetup},
		{"TestRoutesConfigured", testRoutesConfigured},
	}

	// Run all test cases and collect results
	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			testStart := time.Now()

			// Capture test result
			defer func() {
				testEnd := time.Now()
				duration := testEnd.Sub(testStart)

				result := testutil.TestResult{
					Name:     tc.name,
					Duration: duration.String(),
				}

				if r := recover(); r != nil {
					result.Status = "FAIL"
					result.Error = fmt.Sprintf("Panic: %v", r)
				} else if t.Failed() {
					result.Status = "FAIL"
					result.Error = "Test assertions failed"
				} else if t.Skipped() {
					result.Status = "SKIP"
				} else {
					result.Status = "PASS"
				}

				testResults = append(testResults, result)
			}()

			// Run the actual test
			tc.fn(t, terraformOptions, awsRegion)
		})
	}

	// Generate and display test report
	endTime := time.Now()
	report := testutil.GenerateTestReport(testResults, startTime, endTime)
	report.TestSuite = "Terraform AWS VPC Tests"
	report.PrintReport()

	// Save reports to files
	if err := report.SaveReportToFile("test-report.json"); err != nil {
		t.Errorf("failed to save report to file: %v", err)
	}

	if err := report.SaveReportToHTML("test-report.html"); err != nil {
		t.Errorf("failed to save report to HTML: %v", err)
	}
}

// Helper function to create AWS config
func createAWSConfig(t *testing.T, region string) aws.Config {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	require.NoError(t, err, "Failed to create AWS config")
	return cfg
}

// testVPCCreated verifies that the VPC is created with correct configuration
func testVPCCreated(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get VPC ID from terraform output
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	require.NotEmpty(t, vpcID, "VPC ID should not be empty")

	// Get VPC CIDR from terraform output
	vpcCIDRBlocks := terraform.OutputList(t, terraformOptions, "vpc_cidr_block")
	require.NotEmpty(t, vpcCIDRBlocks, "VPC CIDR blocks should not be empty")

	// Create AWS config
	cfg := createAWSConfig(t, awsRegion)
	ec2Client := ec2.NewFromConfig(cfg)

	// Describe VPC
	describeVPCInput := &ec2.DescribeVpcsInput{
		VpcIds: []string{vpcID},
	}

	vpcResult, err := ec2Client.DescribeVpcs(context.TODO(), describeVPCInput)
	require.NoError(t, err, "Failed to describe VPC")
	require.Len(t, vpcResult.Vpcs, 1, "Expected exactly one VPC")

	vpc := vpcResult.Vpcs[0]

	// Verify VPC properties
	assert.Equal(t, vpcID, *vpc.VpcId, "VPC ID should match")
	assert.Equal(t, vpcCIDRBlocks[0], *vpc.CidrBlock, "VPC CIDR should match")
	assert.Equal(t, types.VpcStateAvailable, vpc.State, "VPC should be in available state")

	// Verify DNS settings - these need to be checked via DescribeVpcAttribute
	dnsSupport, err := ec2Client.DescribeVpcAttribute(context.TODO(), &ec2.DescribeVpcAttributeInput{
		VpcId:     aws.String(vpcID),
		Attribute: types.VpcAttributeNameEnableDnsSupport,
	})
	require.NoError(t, err, "Failed to describe DNS support")
	assert.True(t, *dnsSupport.EnableDnsSupport.Value, "DNS support should be enabled")

	dnsHostnames, err := ec2Client.DescribeVpcAttribute(context.TODO(), &ec2.DescribeVpcAttributeInput{
		VpcId:     aws.String(vpcID),
		Attribute: types.VpcAttributeNameEnableDnsHostnames,
	})
	require.NoError(t, err, "Failed to describe DNS hostnames")
	assert.True(t, *dnsHostnames.EnableDnsHostnames.Value, "DNS hostnames should be enabled")

	// Verify tags
	tagMap := make(map[string]string)
	for _, tag := range vpc.Tags {
		tagMap[*tag.Key] = *tag.Value
	}
	assert.Equal(t, "true", tagMap["test"], "Test tag should be present")

	t.Logf("VPC %s created successfully with CIDR %s", vpcID, *vpc.CidrBlock)
}

// testSubnetsCreated verifies that all subnets are created correctly
func testSubnetsCreated(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get subnet IDs from terraform outputs
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	databaseSubnetIDs := terraform.OutputList(t, terraformOptions, "database_subnet_ids")
	secondarySubnetIDs := terraform.OutputList(t, terraformOptions, "secondary_subnet_ids")

	// Verify we have the expected number of subnets
	assert.Len(t, publicSubnetIDs, 2, "Should have 2 public subnets")
	assert.Len(t, privateSubnetIDs, 2, "Should have 2 private subnets")
	assert.Len(t, databaseSubnetIDs, 2, "Should have 2 database subnets")
	assert.Len(t, secondarySubnetIDs, 2, "Should have 2 secondary subnets")

	// Create AWS config
	cfg := createAWSConfig(t, awsRegion)
	ec2Client := ec2.NewFromConfig(cfg)

	// Collect all subnet IDs
	allSubnetIDs := append(publicSubnetIDs, privateSubnetIDs...)
	allSubnetIDs = append(allSubnetIDs, databaseSubnetIDs...)
	allSubnetIDs = append(allSubnetIDs, secondarySubnetIDs...)

	// Describe all subnets
	describeSubnetsInput := &ec2.DescribeSubnetsInput{
		SubnetIds: allSubnetIDs,
	}

	subnetsResult, err := ec2Client.DescribeSubnets(context.TODO(), describeSubnetsInput)
	require.NoError(t, err, "Failed to describe subnets")
	require.Len(t, subnetsResult.Subnets, len(allSubnetIDs), "All subnets should exist")

	// Verify each subnet is in available state
	for _, subnet := range subnetsResult.Subnets {
		assert.Equal(t, types.SubnetStateAvailable, subnet.State, "Subnet %s should be available", *subnet.SubnetId)
		assert.NotEmpty(t, *subnet.CidrBlock, "Subnet should have CIDR block")
		assert.NotEmpty(t, *subnet.AvailabilityZone, "Subnet should have availability zone")
	}


	t.Logf("All subnets created successfully: %d public, %d private, %d database, %d secondary",
		len(publicSubnetIDs), len(privateSubnetIDs), len(databaseSubnetIDs), len(secondarySubnetIDs))
}

// testNATGatewayCreated verifies that NAT gateways are created and configured
func testNATGatewayCreated(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get NAT Gateway IDs from terraform outputs
	natGatewayIDs := terraform.OutputList(t, terraformOptions, "natgw_ids")
	secondaryNatGatewayIDs := terraform.OutputList(t, terraformOptions, "secondary_natgw_ids")

	// Verify we have NAT gateways (should be 2 since single NAT gateway is disabled)
	assert.Len(t, natGatewayIDs, 2, "Should have 2 NAT gateways")
	assert.Len(t, secondaryNatGatewayIDs, 2, "Should have 2 secondary NAT gateways")

	// Create AWS config
	cfg := createAWSConfig(t, awsRegion)
	ec2Client := ec2.NewFromConfig(cfg)

	// Collect Public NAT gateway IDs
	allNatGatewayIDs := append(natGatewayIDs)

	// Describe NAT gateways
	describeNatGatewaysInput := &ec2.DescribeNatGatewaysInput{
		NatGatewayIds: allNatGatewayIDs,
	}
	natGatewaysResult, err := ec2Client.DescribeNatGateways(context.TODO(), describeNatGatewaysInput)
	require.NoError(t, err, "Failed to describe NAT gateways")
	require.Len(t, natGatewaysResult.NatGateways, len(allNatGatewayIDs), "All NAT gateways should exist")
	t.Logf("NATGatewayresult: %+v", natGatewaysResult.NatGateways)
	// Verify each NAT gateway is available
	for _, natGateway := range natGatewaysResult.NatGateways {
		assert.Equal(t, types.NatGatewayStateAvailable, natGateway.State, "NAT Gateway %s should be available", *natGateway.NatGatewayId)
		assert.NotEmpty(t, natGateway.NatGatewayAddresses, "NAT Gateway should have addresses")
		// Verify NAT gateway has an Elastic IP
		for _, address := range natGateway.NatGatewayAddresses {
			assert.NotNil(t, address.PublicIp, "Public IP should not be nil")
			assert.NotNil(t, address.AllocationId, "Allocation ID should not be nil")
			assert.NotEmpty(t, aws.ToString(address.PublicIp), "Public IP should not be empty")
			assert.NotEmpty(t, aws.ToString(address.AllocationId), "Allocation ID should not be empty")
		}
	}

	t.Logf("NAT Gateways created successfully: %d primary, %d secondary", len(natGatewayIDs), len(secondaryNatGatewayIDs))
}

// testVPCFlowLogSetup verifies that VPC flow logs are configured
func testVPCFlowLogSetup(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get VPC ID and flow log details from terraform outputs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	flowLogCloudWatchID := terraform.Output(t, terraformOptions, "flow_log_cloudwatch_dest_id")

	require.NotEmpty(t, vpcID, "VPC ID should not be empty")
	require.NotEmpty(t, flowLogCloudWatchID, "CloudWatch flow log ID should not be empty")

	// Create AWS config
	cfg := createAWSConfig(t, awsRegion)
	ec2Client := ec2.NewFromConfig(cfg)


	// Describe flow logs
	describeFlowLogsInput := &ec2.DescribeFlowLogsInput{
		Filter: []types.Filter{
			{
				Name:   aws.String("resource-id"),
				Values: []string{vpcID},
			},
		},
	}

	flowLogsResult, err := ec2Client.DescribeFlowLogs(context.TODO(), describeFlowLogsInput)
	require.NoError(t, err, "Failed to describe flow logs")
	require.NotEmpty(t, flowLogsResult.FlowLogs, "VPC should have flow logs configured")

	// Verify flow logs are active
	activeFlowLogs := 0
	for _, flowLog := range flowLogsResult.FlowLogs {
		if *flowLog.FlowLogStatus == "ACTIVE" {
			activeFlowLogs++
			assert.Equal(t, vpcID, *flowLog.ResourceId, "Flow log should be for the correct VPC")
			assert.Contains(t, []string{"ALL", "ACCEPT", "REJECT"}, string(flowLog.TrafficType), "Flow log should have valid traffic type")
		}
	}
	assert.Greater(t, activeFlowLogs, 0, "Should have at least one active flow log")

	t.Logf("VPC Flow logs configured successfully: CloudWatch ID %s", flowLogCloudWatchID)
}

// testRoutesConfigured verifies that route tables are created and configured correctly
func testRoutesConfigured(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get route table IDs from terraform outputs
	publicRouteTableID := terraform.Output(t, terraformOptions, "route_table_public_id")
	privateRouteTableID := terraform.Output(t, terraformOptions, "route_table_private_id")
	databaseRouteTableID := terraform.Output(t, terraformOptions, "route_table_database_id")

	require.NotEmpty(t, publicRouteTableID, "Public route table ID should not be empty")
	require.NotEmpty(t, privateRouteTableID, "Private route table ID should not be empty")
	require.NotEmpty(t, databaseRouteTableID, "Database route table ID should not be empty")

	// Get other required IDs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	igwID := terraform.Output(t, terraformOptions, "igw_id")
	natGatewayIDs := terraform.OutputList(t, terraformOptions, "natgw_ids")

	// Create AWS config
	cfg := createAWSConfig(t, awsRegion)
	ec2Client := ec2.NewFromConfig(cfg)

	// Test public route table
	publicRouteTableResult, err := ec2Client.DescribeRouteTables(context.TODO(), &ec2.DescribeRouteTablesInput{
		RouteTableIds: []string{publicRouteTableID},
	})
	require.NoError(t, err, "Failed to describe public route table")
	require.Len(t, publicRouteTableResult.RouteTables, 1, "Should have one public route table")

	publicRouteTable := publicRouteTableResult.RouteTables[0]
	assert.Equal(t, vpcID, *publicRouteTable.VpcId, "Public route table should belong to correct VPC")

	// Verify public route table has route to Internet Gateway
	hasIGWRoute := false
	for _, route := range publicRouteTable.Routes {
		if route.GatewayId != nil && *route.GatewayId == igwID {
			hasIGWRoute = true
			assert.Equal(t, "0.0.0.0/0", *route.DestinationCidrBlock, "IGW route should be for 0.0.0.0/0")
			break
		}
	}
	assert.True(t, hasIGWRoute, "Public route table should have route to Internet Gateway")

	// Test private route table
	privateRouteTableResult, err := ec2Client.DescribeRouteTables(context.TODO(), &ec2.DescribeRouteTablesInput{
		RouteTableIds: []string{privateRouteTableID},
	})
	require.NoError(t, err, "Failed to describe private route table")
	require.Len(t, privateRouteTableResult.RouteTables, 1, "Should have one private route table")

	privateRouteTable := privateRouteTableResult.RouteTables[0]
	assert.Equal(t, vpcID, *privateRouteTable.VpcId, "Private route table should belong to correct VPC")

	// Verify private route table has route to NAT Gateway
	hasNATRoute := false
	for _, route := range privateRouteTable.Routes {
		if route.NatGatewayId != nil {
			for _, natGwID := range natGatewayIDs {
				if *route.NatGatewayId == natGwID {
					hasNATRoute = true
					assert.Equal(t, "0.0.0.0/0", *route.DestinationCidrBlock, "NAT route should be for 0.0.0.0/0")
					break
				}
			}
			if hasNATRoute {
				break
			}
		}
	}
	assert.True(t, hasNATRoute, "Private route table should have route to NAT Gateway")

	// Test database route table
	databaseRouteTableResult, err := ec2Client.DescribeRouteTables(context.TODO(), &ec2.DescribeRouteTablesInput{
		RouteTableIds: []string{databaseRouteTableID},
	})
	require.NoError(t, err, "Failed to describe database route table")
	require.Len(t, databaseRouteTableResult.RouteTables, 1, "Should have one database route table")

	databaseRouteTable := databaseRouteTableResult.RouteTables[0]
	assert.Equal(t, vpcID, *databaseRouteTable.VpcId, "Database route table should belong to correct VPC")

	t.Logf("Route tables configured successfully: Public %s, Private %s, Database %s",
		publicRouteTableID, privateRouteTableID, databaseRouteTableID)
}
