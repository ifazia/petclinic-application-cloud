#!/bin/bash

# Fonction pour mettre à jour le tag de version dans staging-values.yaml
update_service_version() {
  local service_name="$1"
  local image_tag="$2"
  local values_file="helmchart/staging-values.yaml"
  local service_key

  # Map service name to the key used in the YAML file
  case "$service_name" in
    spring-petclinic-api-gateway)
      service_key="apigateway"
      ;;
    spring-petclinic-customers-service)
      service_key="customersservice"
      ;;
    spring-petclinic-vets-service)
      service_key="vetsservice"
      ;;
    spring-petclinic-visits-service)
      service_key="visitsservice"
      ;;
    *)
      echo "Error: Unknown service name $service_name"
      exit 1
      ;;
  esac

  echo "Updating $service_key in $values_file to tag $image_tag"

  # Utilisation de sed pour remplacer le tag de version dans le fichier YAML
  sed -i "s|\(\s*${service_key}:\s*\n\s*image:\s*public\.ecr\.aws/i7s8l3z4/${service_name}\s*\n\s*version:\s*\).*|\1${image_tag}|" "$values_file"
}

# Liste des microservices à mettre à jour
services=(
  "spring-petclinic-api-gateway"
  "spring-petclinic-customers-service"
  "spring-petclinic-vets-service"
  "spring-petclinic-visits-service"
)

# Parcourir chaque microservice pour récupérer le tag d'image et mettre à jour le tag de version dans staging-values.yaml
for service in "${services[@]}"; do
  # Récupérer le tag d'image pour le service spécifié
  image_tag=$(aws ecr-public describe-images --repository-name "$service" --query "reverse(sort_by(imageDetails, &imagePushedAt))[0].imageTags[0]" --output text)
  if [ -z "$image_tag" ]; then
    echo "Error: Failed to retrieve image tag for $service from ECR Public."
    exit 1
  fi

  update_service_version "$service" "$image_tag"
done

echo "Values updated successfully."
cat helmchart/staging-values.yaml
