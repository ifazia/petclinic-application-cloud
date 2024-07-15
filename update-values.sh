#!/bin/bash

# Function to get the latest image tag from ECR
get_latest_image_tag() {
  local repository_name=$1
  aws ecr-public describe-images --repository-name "$repository_name" --query "reverse(sort_by(imageDetails, &imagePushedAt))[0].imageTags[0]" --output text
}

# Repositories and services
declare -A services=(
  ["apigateway"]="public.ecr.aws/i7s8l3z4/spring-petclinic-api-gateway"
  ["customersservice"]="public.ecr.aws/i7s8l3z4/spring-petclinic-customers-service"
  ["vetsservice"]="public.ecr.aws/i7s8l3z4/spring-petclinic-vets-service"
  ["visitsservice"]="public.ecr.aws/i7s8l3z4/spring-petclinic-visits-service"
)

# Ensure the script runs from the correct directory
cd "$(dirname "$0")"

# Iterate over services and update staging-values.yaml
for service in "${!services[@]}"; do
  repository="${services[$service]}"
  latest_tag=$(get_latest_image_tag "$repository")
  if [ "$latest_tag" != "None" ]; then
    echo "Updating $service in staging-values.yaml to tag $latest_tag"
    yq e -i ".${service}.version = \"${latest_tag}\"" helmchart/staging-values.yaml
  else
    echo "No tag found for $repository"
  fi
done
