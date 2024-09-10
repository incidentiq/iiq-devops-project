# IIQ DevOps Demo Application

The repository contains a two tier applicaiton that is used for demonstrating different build and deployment techniques.

- [Todo api](api/Readme.md)
- [Web UI](web/Readme.md)

To test the application you can use Docker compose and access the application on http://localhost:8080/

```bash
docker compose up
```

Steps for provisioning this project's infrastructure in Azure and deploying the web and api services to the AKS cluster (based off of macOS, steps will be different if using different OS):

Required Dependencies:
- Home Brew: [/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"](https://brew.sh/)
- Docker: https://formulae.brew.sh/formula/docker
- Azure CLI: https://formulae.brew.sh/formula/azure-cli
- Kubectl: https://formulae.brew.sh/formula/kubernetes-cli
- Terraform: https://formulae.brew.sh/formula/terraform

First: Provision the infrastructure
- Execute the following commands from the ./infra folder to spin up the required Azure resources
    1. az login
    2. terraform init
    3. terraform apply (input 'yes' when asked for input)

Second: Configure Azure resources and local machine for accessing the AKS hosted site
- Execute the below commands to connect the Azure Container Registery with the AKS cluster and populate the ACR with the Docker images for web/api services
    1. az aks get-credentials --resource-group iis-devops-project-rg --name iis-devops-project-aks-cluster
    2. az aks update --name iis-devops-project-aks-cluster --resource-group iis-devops-project-rg --attach-acr iisdevopsprojectcontainerregistry

    3. Execute these commands from the ./api/TodoApi folder
        - docker build -t iisdevopsprojectcontainerregistry.azurecr.io/iiq-devops-project-api:latest .
        - docker push iisdevopsprojectcontainerregistry.azurecr.io/iiq-devops-project-api:latest

    4. Execute these commands from the ./web/todo-ui folder
        - docker build -t iisdevopsprojectcontainerregistry.azurecr.io/iiq-devops-project-web:latest .
        - docker push iisdevopsprojectcontainerregistry.azurecr.io/iiq-devops-project-web:latest


Third: Configure the AKS cluster to use an Nginx ingress conroller, setup local DNS for ingress routing, and create the k8s resources
    1. kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml

    2. sudo vim /etc/hosts
        - This is crucial, you need to add a mapping of the AKS cluster ingress' IP address to the host provided in the ingress yaml file [ie. IP address : Hostname]

    3. kubectl apply -f api-deployment.yaml,api-service.yaml,ingress.yaml,web-deployment.yaml,web-service.yaml -n ingress-nginx

    4. kubectl logs <nginx-controller-pod-name> -n ingress-nginx --since 5m
        - If running into issues, use this command to debug the nginx controller pod by looking at its logs

    5. kubectl delete -f api-deployment.yaml,api-service.yaml,ingress.yaml,web-deployment.yaml,web-service.yaml -n ingress-nginx
        - If things seem borked, tear down the k8s resources and start from step 3 of this section again 

Fourth: Configure Monitoring/Dashboards for the AKS cluster using Prometheus and Grafana
- The Azure monitoring resources are partially provisioned from the Terraform modules, but some additional manual steps are needed to enable Azure managed Prometheus and Grafana
    1. In the Azure portal, go to the AKS cluster page, click the "Monitoring" menu dropdown, click "Insights"
    2. Click "Enable Prometheus"
    3. Enable each of the monitoring options available (this takes a few minutes to spin up)
    4. Start using the app, adding notes, refreshing the page, etc.
    5. Review the monitoring dashboards on the "Insights" page