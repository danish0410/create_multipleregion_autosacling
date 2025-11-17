#!/bin/bash

# Since you are inside multi-region-ec2/, use this base path:
BASE_DIR="regions"

echo "Fetching current public IP..."
IP=$(curl -s ifconfig.me)/32

if [[ -z "$IP" ]]; then
    echo "❌ Could not fetch public IP"
    exit 1
fi

echo "✅ Detected Public IP: $IP"
echo "----------------------------------------"

# First update root-level terraform.tfvars (optional)
if [[ -f "terraform.tfvars" ]]; then
    echo "Updating root terraform.tfvars ..."
    sed -i -E "s|ssh_cidrs *= *\\[\".*\"\\]|ssh_cidrs = [\"$IP\"]|" terraform.tfvars
    sed -i -E "s|cidr_blocks_ingress_bastion *= *\\[\".*\"\\]|cidr_blocks_ingress_bastion = [\"$IP\"]|" terraform.tfvars
    echo "✔ Updated root terraform.tfvars"
fi

# Now update all region-specific terraform.tfvars
for REGION_DIR in "$BASE_DIR"/*; do

    if [[ ! -d "$REGION_DIR" ]]; then
        continue
    fi

    TFVARS_FILE="$REGION_DIR/terraform.tfvars"

    echo "Processing region: $(basename "$REGION_DIR")"

    if [[ ! -f "$TFVARS_FILE" ]]; then
        echo "⚠️ terraform.tfvars not found in $(basename "$REGION_DIR"), skipping"
        continue
    fi

    sed -i -E "s|ssh_cidrs *= *\\[\".*\"\\]|ssh_cidrs = [\"$IP\"]|" "$TFVARS_FILE"
    sed -i -E "s|cidr_blocks_ingress_bastion *= *\\[\".*\"\\]|cidr_blocks_ingress_bastion = [\"$IP\"]|" "$TFVARS_FILE"

    echo "✔ Updated: $TFVARS_FILE"
done

echo "----------------------------------------"
echo "🎉 All regions updated successfully!"
echo "New values: [\"$IP\"]"
echo "----------------------------------------"