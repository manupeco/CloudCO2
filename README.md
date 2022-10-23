# CloudCO2

This project includes tools and solutions to reduce your cloud projects' carbon footprint (and of course, costs).

# Requirements

* gcp.json credential file in the project root (be sure to have this in .gitignore)
* Enable Identity and Access Management (IAM) API
* Be sure the service account you use for Terraform has Function Cloud Admin role to assign the role invoker role

## Tools

### Cloud SQL Optimizer

This tool allows to configure a task that will start and stop the Cloud SQL instances following a specific schedule. A typical use case for this would be a developer environment on which we could schedule to turn off the instance every day at 7pm and start it at 8am in the morning (and of course, keep it disabled during the weekend)

#### Configuration

Go to `cloudsql-optimizer/terraform`. Rename the file `variables_template.tf` to `variables.tf` and configure the needed values

* project_id: id of the project where you want to create the infrastructure
* region: the region (ex: europe-west1)
* zone: the zone inside the region (ex: europe-west1-a)
* credentials: the path to the GCP credentials file (ex: ../../gcp.json)
* db_instance_name: the name of the instance to start or stop (ex: test1)

#### Deployment

Go to `cloudsql-optimizer/terraform` and run

`terraform init`

followed by 

`terraform apply`

#### Clean up

From the same folder run the command

`terraform destroy`

### GKE-Optimizer

#### Prepare the app

go to `gke-optimizer` and run `npm install`to add the needed node libraries to the project

#### Deployment

Go to `gke-optimizer/terraform` and run

`terraform init`

followed by 

`terraform apply`

#### Clean up

From the same folder run the command

`terraform destroy`


