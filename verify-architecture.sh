#!/bin/bash

# verify-architecture.sh
# Verifies that all features in AIChat/Core follow the MVVM + Clean Architecture pattern

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Verifying AIChat Architecture Pattern..."
echo "=========================================="
echo ""

CORE_DIR="AIChat/Core"
ISSUES_FOUND=0

# Expected file patterns for each feature
declare -a EXPECTED_FILES=(
    "View.swift"
    "ViewModel.swift"
    "UseCase.swift"
    "Builder.swift"
    "Router.swift"
)

# Iterate through each feature directory
for feature_dir in "$CORE_DIR"/*; do
    if [ -d "$feature_dir" ]; then
        feature_name=$(basename "$feature_dir")

        echo "📦 Checking: $feature_name"

        # Skip TabBar, AppView, and Onboarding as they have different structures
        # Onboarding is a composite feature with sub-features (IntroView, ColorView, etc.)
        if [[ "$feature_name" == "TabBar" || "$feature_name" == "AppView" || "$feature_name" == "Onboarding" ]]; then
            echo "   ⏭️  Skipped (special structure)"
            echo ""
            continue
        fi

        missing_files=()

        # Check for each expected file
        for file_suffix in "${EXPECTED_FILES[@]}"; do
            expected_file="${feature_name}${file_suffix}"

            if [ ! -f "$feature_dir/$expected_file" ]; then
                missing_files+=("$expected_file")
            fi
        done

        # Report results
        if [ ${#missing_files[@]} -eq 0 ]; then
            echo "   ✅ Complete (all 5 files present)"
        else
            echo -e "   ${RED}❌ Missing files:${NC}"
            for missing in "${missing_files[@]}"; do
                echo "      - $missing"
            done
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi

        # Check for extra files (excluding delegates and models)
        extra_files=$(find "$feature_dir" -maxdepth 1 -name "*.swift" ! -name "${feature_name}View.swift" ! -name "${feature_name}ViewModel.swift" ! -name "${feature_name}UseCase.swift" ! -name "${feature_name}Builder.swift" ! -name "${feature_name}Router.swift" ! -name "*Delegate.swift" ! -name "*Models.swift" ! -name "*Configuration.swift" ! -name "*Interactor.swift")

        if [ -n "$extra_files" ]; then
            echo -e "   ${YELLOW}⚠️  Additional files found:${NC}"
            echo "$extra_files" | while read -r file; do
                if [ -n "$file" ]; then
                    echo "      - $(basename "$file")"
                fi
            done
        fi

        echo ""
    fi
done

echo "=========================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ All features follow the MVVM pattern!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ISSUES_FOUND feature(s) with missing files${NC}"
    echo ""
    echo "💡 To fix:"
    echo "   1. Use the MVVMTemplate in Xcode to generate missing files"
    echo "   2. Or manually create files following the pattern in AIChat/Core/About"
    exit 1
fi
