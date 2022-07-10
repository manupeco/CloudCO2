# CloudCO2

This project includes tools and solutions to reduce your cloud projects' carbon footprint (and of course, costs).

# Requirements

* gcp.json credential file in the project root (be sure to have this in .gitignore)
* Enable Identity and Access Management (IAM) API

## Tools

### Cloud SQL Optimizer

This tool allows to configure a task that will start and stop the Cloud SQL instances following a specific schedule. A typical use case for this would be a developer environment on which we could schedule to turn off the instance every day at 7pm and start it at 8am in the morning (and of course, keep it disabled during the weekend)

It's a work in progress.