#!/bin/bash

# Fonction pour mettre à jour le tag de version dans staging-values.yaml
update_service_version() {
  local service_name="$1"
  local values_file="helmchart/staging-values.yaml"

  # Récupérer le tag d'image pour le service spécifié
  local image_tag=$(aws ecr-public describe-images --repository-name "$service_name" --query "reverse(sort_by(imageDetails, &imagePushedAt))[0].imageTags[0]" --output text)

  if [ -z "$image_tag" ]; then
    echo "Error: Failed to retrieve image tag for $service_name from ECR Public."
    exit 1
  fi

  echo "Updating $service_name in $values_file to tag $image_tag"

  # Utilisation de sed pour remplacer le tag de version dans le fichier YAML
  sed -i "s|^\(\s*${service_name}:\s*\n\s*image:\s*public.ecr.aws/i7s8l3z4/${service_name}\s*\n\s*version:\s*\).*|\1${image_tag}|" "$values_file"
}

# Liste des microservices à mettre à jour
services=(
  "spring-petclinic-api-gateway"
  "spring-petclinic-customers-service"
  "spring-petclinic-vets-service"
  "spring-petclinic-visits-service"
)

# Parcourir chaque microservice et mettre à jour le tag de version dans staging-values.yaml
for service in "${services[@]}"; do
  update_service_version "$service"
done

echo "Values updated successfully."
