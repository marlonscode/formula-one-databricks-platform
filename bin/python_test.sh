#!/usr/bin/env bash
set -eu

main() {
    export TOP_DIR=$(git rev-parse --show-toplevel)

    echo "Running pytest..."

    # Run pytest with verbose output and coverage
    pytest "${TOP_DIR}/orchestration/tests/" \
        -v \
        --tb=short \
        --strict-markers

    echo "All tests passed! ✅"
}

main