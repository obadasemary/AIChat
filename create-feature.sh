#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: ./create-feature.sh FeatureName"
    exit 1
fi

FEATURE="$1"
FEATURE_LOWER="$(echo ${FEATURE:0:1} | tr '[:upper:]' '[:lower:]')${FEATURE:1}"
DIR="AIChat/Core/$FEATURE"

if [ -d "$DIR" ]; then
    echo "Error: Feature already exists!"
    exit 1
fi

mkdir -p "$DIR"

for file in View ViewModel UseCase Builder Router; do
    sed -e "s/___VARIABLE_productName:identifier___/$FEATURE/g" \
        -e "s/___VARIABLE_camelCasedProductName:identifier___/$FEATURE_LOWER/g" \
        -e "s/___VARIABLE_coreName:identifier___/Core/g" \
        -e "s|___FILEHEADER___|//  ${FEATURE}${file}.swift|" \
        "XcodeTemplate/MVVMTemplate.xctemplate/___FILEBASENAME___${file}.swift" \
        > "$DIR/${FEATURE}${file}.swift"
done

echo "✅ Created $FEATURE feature!"
echo "📁 Location: $DIR"
echo ""
echo "Next: Add to Xcode"
echo "1. Right-click 'Core' folder"
echo "2. 'Add Files to AIChat...'"
echo "3. Select the '$FEATURE' folder"
echo "4. UNCHECK 'Copy items'"
echo "5. Click 'Add'"
