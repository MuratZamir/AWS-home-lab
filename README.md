# AWS ~ TerraForm

Automated the whole setup by using Terraform 

--> Step by step project creation;
* Virtual Private Cloud 
* Internet Gateway
* Subnet
* Routing Table
* Security Groups
* Network Interface Card
* Elastic IP
* Ubuntu AMI / Apache2 Web Server
-------------------------------------


How to run it:
* After you have created the file and structure your code as intended;

  * initializes a working directory containing configuration files and installs plugins for required providers
  
  * creates or updates infrastructure depending on the configuration files

```
terraform init && terraform apply
```


* if you are using the Free Tier, its good to destroy after you're done
```
terraform destroy
```
