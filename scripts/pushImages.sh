#!/bin/bash
docker push ${REPOSITORY_PREFIX}/spring-petclinic-api-gateway:latest
docker push ${REPOSITORY_PREFIX}/spring-petclinic-visits-service:latest
docker push ${REPOSITORY_PREFIX}/spring-petclinic-vets-service:latest
docker push ${REPOSITORY_PREFIX}/spring-petclinic-customers-service:latest
docker push ${REPOSITORY_PREFIX}/spring-petclinic-admin-server:latest
docker push ${REPOSITORY_PREFIX}/spring-petclinic-discovery-service:latest
docker push ${REPOSITORY_PREFIX}/spring-petclinic-config-server:latest

