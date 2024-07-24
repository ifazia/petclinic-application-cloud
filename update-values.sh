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

  # Map service name to the key used in the YAML file and image repository
  case "$service_name" in
    spring-petclinic-api-gateway)
      service_key="apigateway"
      image_repo="public.ecr.aws/y6x2k4a9/spring-petclinic-api-gateway"
      ;;
    spring-petclinic-customers-service)
      service_key="customersservice"
      image_repo="public.ecr.aws/y6x2k4a9/spring-petclinic-customers-service"
      ;;
    spring-petclinic-vets-service)
      service_key="vetsservice"
      image_repo="public.ecr.aws/y6x2k4a9/spring-petclinic-vets-service"
      ;;
    spring-petclinic-visits-service)
      service_key="visitsservice"
      image_repo="public.ecr.aws/y6x2k4a9/spring-petclinic-visits-service"
      ;;
    *)
      echo "Error: Unknown service name $service_name"
      exit 1
      ;;
  esac

  # Séparer l'image et la version de l'argument image_tag
  image_version="${image_tag##*:}"  # Extrait la partie après le `:`

  echo "Updating $service_key in $values_file to image $image_repo and tag $image_version"

  # Utilisation de yq pour remplacer le champ image.repository et version dans le fichier YAML
  yq eval ".${service_key}.version = \"${image_version}\"" -i "$values_file"
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
