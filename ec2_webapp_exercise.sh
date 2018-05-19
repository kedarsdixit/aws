#!/bin/bash 
yum -y update 
yum -y install httpd php 
chkconfig httpd on 
wget https://us-west-2-aws-training.s3.amazonaws.com/awsu-ilt/architecting/v4.0/lab-3-working-with-ec2/static/phpapp.zip 
unzip phpapp.zip -d /var/www/html/
sudo service httpd start


#!/bin/bash
# Install Apache Web Server and PHP
yum remove -y httpd php
yum install -y httpd24 php56
# Download Lab files
wget https://us-west-2-tcprod.s3.amazonaws.com/courses/AWS-100-ARC/v5.2.9/lab-1-webapp/scripts/lab1src.zip
unzip lab1src.zip -d /tmp/
mv /tmp/lab1src/*.php /var/www/html/
# Download and install the AWS SDK for PHP
wget https://github.com/aws/aws-sdk-php/releases/download/3.15.9/aws.zip
unzip aws -d /var/www/html
# Determine Region
AZ=`curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone/`
REGION=${AZ::-1}
# Copy files to Amazon S3 bucket with name webapp-*
BUCKET=`aws s3api list-buckets --query "Buckets[?starts_with(Name, 'webapp-ms')].Name | [0]" --output text`
aws s3 cp /tmp/lab1src/jquery/ s3://$BUCKET/jquery/ --recursive --acl public-read --region $REGION
aws s3 cp /tmp/lab1src/images/ s3://$BUCKET/images/ --recursive --acl public-read --region $REGION
aws s3 ls s3://$BUCKET/ --region $REGION --recursive
# Configure Region and Bucket to use
sed -i "2s/%region%/$REGION/g" /var/www/html/*.php
sed -i "3s/%bucket%/$BUCKET/g" /var/www/html/*.php
# Copy data into DynamoDB table
aws dynamodb batch-write-item --request-items file:///tmp/lab1src/scripts/services1.json --region $REGION
aws dynamodb batch-write-item --request-items file:///tmp/lab1src/scripts/services2.json --region $REGION
aws dynamodb batch-write-item --request-items file:///tmp/lab1src/scripts/services3.json --region $REGION
# Turn on web server
chkconfig httpd on
service httpd start



Ip="curl https://169.254.169.254/latest/meta-data/networking/public-ip"
configurations == ip


stress --cpu 2 --timeout 300













