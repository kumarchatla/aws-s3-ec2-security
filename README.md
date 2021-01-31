## Code Test Terraform:

### This project is to demonstrate the basis of restricting S3 access to specific EC2 instances Using Terraform
 #### Steps:
 1. Create the keypair and security group, which allows the port 22.
 2. Using terraform, I have created an S3 bucket, IAM Role, and IAM policy that will allow attaching to Ec2 to perform S3 actions and Ec2 instance
 3. Update the keypair, security group, subnetID, VPCID values in main.tf at required places
 4. Now, Run the below commands 
        ```terraform init```
        ```terraform plan```
        ```terraform apply```
 5. Once the Ec2 successfully launches, ssh using the pem key that was created in Step.1
 6. Add any object to the S3 bucket(siva-code-files) to list out from Ec2
 7. Run the following commands to check S3 access from the Ec2
            ```aws s3 ls```  #Will throw Access denied Error.
            ```aws s3 s3://siva-code-files```
                
