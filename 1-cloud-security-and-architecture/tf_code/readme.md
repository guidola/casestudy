# IaC Code for the Provided Architecture

## Pre Requisites

Ensure that terraform is installed and properly configured in your system. Do the same for aws-cli.

Run the following command to create the `rds_password` that will be used when running `terrraform plan` and `terraform apply`:

```shell
aws ssm put-parameter --name "rds_password" --value "your_rds_password" --type "SecureString"
```

Run the following commands to create a self-signed certificate to use to configure the ALB:

1. Generate private key

```shell
openssl genrsa 2048 > my-private-key.pem
```

2. Generate certificate using a private key, you will be prompted to fill some fields. Fill required fields randomly, except for Common Name fill it with *.amazonaws.com or your valid domain name

```shell
openssl req -new -x509 -nodes -sha256 -days 365 -key my-private-key.pem -outform PEM -out my-certificate.pem
```

3. Upload certificate & its private key to Amazon Certificate Manager

```shell
aws acm import-certificate --certificate file://my-certificate.pem --private-key file://my-private-key.pem
```

Certificate should now show up in AWS Console and be ready to configure towards the ALB. Copy the prompted arn and set it in `terraform.tfvars` as the value for `certificate_arn`.

## Run and Test

To create the infrastructure:

- Go through the pre-requisites
- Ensure that `terraform.tfvars` has the correct values as per your setup
- Run `terraform init`
- Run `terraform apply`

To ensure things work as expected:

- Ensure `terraform apply` works without errors
- Deploy or ensure you can get cli access to a workload within each security group
- Test connectivity between the different security groups and ensure they match the specification in the definition of the security groups.
- The rest is hard to test functionally as we have no application, domain, path, etc.. knowledge and nothing is running in the cluster nor the databases are initialized.

## Asumptions

- It is assumed that the requested scope of implementation for the IaC code exercise is the reference architecture provided for analysis purposes. Henceforth, the resource hereby defined are restricted to those of the original architecture defined in the original architecture and will not include any modifications made on the RFC analysis as the scope of those can extend outside the intended scope of this exercise.

## Considerations

The implementation is trying to keep the complexity of the solution low to reduce implementation time and complexity:
- It is not considering this solution will grow but that it will rather be a contained and structured architecture we will only iterate for maintenance purposes.
- It is not introducing terraform wrappers or other complimentary tools that ease the development using terrraform code.
- It is not modularizing the code for reusability as it is treated as a one time thing where we prioritise delivery speed and matching the expected functionality and not the maintainability of the solution. Encapsulating logically related parts of the architecture for abstracting defaults and encouraging reusability of those standards as well as to remove unnecessary code duplication and structure the code to foster maintainability.