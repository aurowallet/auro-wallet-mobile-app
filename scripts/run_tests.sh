#!/bin/bash

# Auro Wallet Test Runner Script
# 
# Usage:
#   ./scripts/run_tests.sh           # Run all tests
#   ./scripts/run_tests.sh wallet    # Run wallet related tests
#   ./scripts/run_tests.sh coverage  # Run tests and generate coverage report

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "========================================"
echo "  Auro Wallet Unit Tests"
echo "========================================"
echo ""
echo "Project directory: $PROJECT_DIR"
echo ""

case "$1" in
  "wallet")
    echo "Running wallet related tests..."
    echo ""
    flutter test test/wallet_store_test.dart test/wallet_multi_wallet_test.dart test/wallet_seed_storage_test.dart --reporter=expanded
    ;;
    
  "coverage")
    echo "Running tests and generating coverage report..."
    echo ""
    flutter test --coverage
    
    if command -v genhtml &> /dev/null; then
      echo ""
      echo "Generating HTML coverage report..."
      genhtml coverage/lcov.info -o coverage/html --quiet
      echo "Report generated: coverage/html/index.html"
      
      # Auto open on macOS
      if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage/html/index.html
      fi
    else
      echo ""
      echo "Tip: Install lcov to generate HTML report"
      echo "  macOS: brew install lcov"
      echo "  Linux: sudo apt-get install lcov"
    fi
    ;;
    
  "quick")
    echo "Running quick data structure tests..."
    echo ""
    flutter test test/wallet_store_test.dart --reporter=compact
    ;;
    
  *)
    echo "Running all tests..."
    echo ""
    flutter test --reporter=expanded
    ;;
esac

echo ""
echo "========================================"
echo "  Tests Complete"
echo "========================================"
