# My AWS Infrastructure

This project contains [terraform](https://terraform.io) code for the AWS infrastructure that I use for my mini projects. This is organized into several subfolders, but the most useful one is the `vpc`.

My `10.0.0.0/16` VPC contains 2 `/24` private subnets (`us-east-1a`, `us-east-1d`) and 1 `/24` public subnet (`us-east-1a`).

If you want to re-use these templates, please rename the S3 backend bucket name to whatever you like. You should also have `~/.aws/credentials` file containing the key and secret with VPC Full Access policy. Obviously, you should also have terraform installed.

> **Careful** - do not use this on existing infrastructure, or if you've imported any existing resources into terraform, or have somehow put a state file in `.terraform` folder. Proceed if you know what you're doing, and are fairly familiar with Terraform and AWS.

After cloning the repo -

```
bash-3.2$ cd my-aws-infrastructure/vpc
bash-3.2$ terraform init
Initializing the backend...


Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your environment. If you forget, other
commands will detect it and remind you to do so if necessary.

bash-3.2$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

....
....
....

Plan: 7 to add, 0 to change, 0 to destroy.

bash-3.2$ terraform apply
....
....
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

bash-3.2$ terraform show

bash-3.2$ terraform destroy

```

Feel free to modify any of the settings as you deem necessary.
