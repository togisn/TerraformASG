**Terraform ASG**
-----
Consist of:
1 Region = ap-southeast-1
1 Availability zone = ap-southeast-1a
1 VPC
1 public subnet
1 nat-ed subnet
1 NAT gateway
1 Internet Gateway
1 ELB
1 Security group = allow http
2 ASG policy = cpu alarm up and down at 45% CPUUtilization
2 instance minimum EC2 T2 medium Ubuntu Server 20.04 LTS
5 instance maximum EC2 


Prerequisites
-----
* AWS access key
* AWS secret key
* Terraform 
See the [Terraform website](https://www.terraform.io/) for installation instructions.


Architecture Diagram
-----
![diagram](https://i.imgur.com/wotWiNE.png "diagram")


Run Terraform
-----
Steps to run:
1. Clone this repository

2. Run Terraform apply

        terraform apply

3. Insert AWS access key

4. Insert AWS secret key

5. Type Yes to confirm

6. Estimated in 2 minutes the provisioning will be completed.
![outputs](https://i.imgur.com/6SmLSnp.png "outputs")

7. Open the dns name in a browser
![nginx](https://i.imgur.com/2Xxm86k.png "nginx")

8. Congrats! the ASG has been setup succesfully.
