#!/bin/bash

# Vérifiez si yq est installé, sinon installez-le
if ! command -v yq &> /dev/null; then
    echo "yq could not be found, installing..."
    wget https://github.com/mikefarah/yq/releases/download/v4.16.1/yq_linux_amd64 -O /usr/bin/yq
    chmod +x /usr/bin/yq
fi

# Fonction pour mettre à jour l'image et le tag de version dans staging-values.yaml
update_service_version() {
  local service_name="$1"
  local image_tag="$2"
  local values_file="helmchart/staging-values.yaml"
  local service_key
  local image_repo
  local image_version

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

  # Séparer l'image et la version de l'argument image_tag
  image_version="${image_tag##*:}"  # Extrait la partie après le `:`
  
  if [[ "$image_tag" == *":"* ]]; then
    image_repo="${image_tag%:*}"  # Extrait la partie avant le `:`
  else
    image_repo="$image_tag"  # Pas de `:`, tout est l'image
  fi

  # Pour vérifier que image_repo contient la partie du dépôt d'image
  echo "Extracted image repository: ${image_repo}"
  echo "Extracted image version: ${image_version}"

  echo "Updating $service_key in $values_file to image $image_repo and tag $image_version"

  # Utilisation de yq pour remplacer le champ image et version dans le fichier YAML
  yq eval ".${service_key}.image = \"${image_repo}\"" -i "$values_file"
  if [ -n "$image_version" ]; then
    yq eval ".${service_key}.version = \"${image_version}\"" -i "$values_file"
  else
    # Conserver la version existante si aucune nouvelle version n'est fournie
    echo "No version provided. The existing version will be kept unchanged."
  fi
}

# Paramètres du script
service_name="$1"
image_tag="$2"

# Vérifiez que les paramètres ne sont pas vides
if [ -z "$service_name" ] || [ -z "$image_tag" ]; then
  echo "Usage: $0 <service_name> <image_tag>"
  exit 1
fi

# Mettre à jour l'image et la version du service spécifié
update_service_version "$service_name" "$image_tag"

echo "Values updated successfully for $service_name."
cat helmchart/staging-values.yaml