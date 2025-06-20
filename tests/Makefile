.PHONY: test clean deps fmt vet

# Default target
test: deps
	go test -v -timeout 60m

# Install dependencies
deps:
	go mod download
	go mod tidy

# Format code
fmt:
	go fmt ./...

# Vet code
vet:
	go vet ./...

# Clean test artifacts
clean:
	rm -f test-report.json test-report.html
	go clean -testcache

# Run tests with coverage
test-coverage: deps
	go test -v -timeout 60m -coverprofile=coverage.out
	go tool cover -html=coverage.out -o coverage.html

# Run tests with report generation
test-report: deps
	go test -v -timeout 60m -report -report-file=test-report.json -html-file=test-report.html

# Help target
help:
	@echo "Available targets:"
	@echo "  test         - Run tests"
	@echo "  deps         - Install dependencies"
	@echo "  fmt          - Format code"
	@echo "  vet          - Vet code"
	@echo "  clean        - Clean test artifacts"
	@echo "  test-coverage - Run tests with coverage"
	@echo "  test-report  - Run tests with report generation"
	@echo "  help         - Show this help"
