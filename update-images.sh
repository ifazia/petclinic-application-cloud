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

# Backup the original file
cp staging-values.yaml staging-values.yaml.bak

# Iterate over services and update staging-values.yaml
for service in "${!services[@]}"; do
  repository="${services[$service]}"
  latest_tag=$(get_latest_image_tag "$repository")
  if [ "$latest_tag" != "None" ]; then
    echo "Updating $repository to tag $latest_tag"
    sed -i "s|\(${repository}:\).*|\1${latest_tag}|g" staging-values.yaml
  else
    echo "No tag found for $repository"
  fi
done