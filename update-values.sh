#!/bin/bash

# Vérifiez si yq est installé, sinon installez-le
if ! command -v yq &> /dev/null; then
    echo "yq could not be found, installing..."
    wget https://github.com/mikefarah/yq/releases/download/v4.16.1/yq_linux_amd64 -O /usr/bin/yq
    chmod +x /usr/bin/yq
fi

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

  # Utilisation de yq pour remplacer le tag de version dans le fichier YAML
  yq eval ".${service_key}.version = \"${image_tag}\"" -i "$values_file"
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
