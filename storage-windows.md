# Managing Storage in AWS (Windows)

**Objectives**
After completing this lab, you will be able to:

- Create and maintain snapshots for Amazon EC2 instances.
- Upload files to and download files from Amazon S3.
- Configure lifecycle policies for Amazon S3 data.


**Duration**

This lab will require approximately **1 hour** to complete.

___
## Access The AWS Console

___
## Task 1: Creating Instances


**Scenario**

![](http://us-west-2-aws-training.s3.amazonaws.com/awsu-ilt/AWS-100-SYS/v2.6/lab-3-storage-linux/scripts/architecture.png)

### Task 1.1: Create an Amazon S3 bucket


### Task 1.2: Create an IAM policy

Before creating your instance, you will need to create an IAM role that grants your Amazon S3 instance access to your bucket. In order to do this, you will first create a custom policy that grants access to your Amazon S3 bucket. Then, in the next task you will create an IAM role and attach this policy to that role

### Task 1.3: Create an IAM Role with IAM Policy created in last step

### Task 1.4: Create the security group

In this task, you will create a new security group that allows Remote Desktop Protocol (RDP) access to your instance

### Task 1.5: Creating an Amazon EC2 Instances


	```
	<powershell>

	Set-ExecutionPolicy Unrestricted -Force

	# Download and install latest stable AWS CLI MSI for 64bit
	New-Item -ItemType directory -Path 'C:\temp', 'C:\temp\aws'

	$webclient = New-Object System.Net.WebClient
	$webclient.DownloadFile('https://s3.amazonaws.com/aws-cli/AWSCLI64.msi','C:\temp\aws\AWSCLI64.msi')
	Start-Process 'C:\temp\aws\AWSCLI64.msi' -ArgumentList /qn -Wait

	# Download AWS for .NET SDK so that we have AWS Powershell commands available.
	$webclient.DownloadFile('https://us-west-2-aws-training.s3.amazonaws.com/awsu-ilt/AWS-100-SYS/v2.6/lab-3-storage-windows/scripts/AWSToolsAndSDKForNet_sdk.msi', 'c:\temp\aws\AWSNETSDK.msi')
	Start-Process 'c:\temp\aws\AWSNETSDK.msi' -ArgumentList /qn -Wait

	</powershell>
	```

___
## Task 2: Taking Snapshots of Your Instance


### Task 2.1a: Connecting to Your Existing CommandHost Instance Running A Windows Server 2012 From A Windows Machine


### Task 2.2: Taking an Initial Snapshot


```
aws ec2 describe-instances --filter 'Name=tag:Name,Values=Processor'
```

Get the Volume of the instance to snapshot

```
aws ec2 describe-instances --filter 'Name=tag:Name,Values=Processor' --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.{VolumeId:VolumeId}'
```


```
aws ec2 describe-instances --filters 'Name=tag:Name,Values=Processor' --query 'Reservations[0].Instances[0].InstanceId'
```

```
aws ec2 stop-instances --instance-ids <instance-id>
```


```
aws ec2 describe-instance-status --instance-id <instance-id>
```

```
aws ec2 create-snapshot --volume-id <volume-id>
```

```
aws ec2 describe-snapshots --snapshot-id <snapshot-id>
```

```
aws ec2 start-instances --instance-ids <instance-id>
```

```
aws ec2 describe-instance-status --instance-id <instance-id>
```


### Task 2.3: Schedule Creation of Subsequent Snapshots

```
type c:\Users\Administrator\.aws\config
```
Get the region


```
aws ec2 create-snapshot --volume-id <volume-id> --region <region> >c:\temp\output.txt 2>&1
```

```
net user backupuser passw0rd! /ADD
```

```
c:\temp\ntrights +R SeBatchLogonRight -u backupuser
```

**ntrights.exe** is a command that ships with the Windows Server 2003 Resource Kit; it is provided as part of this lab to simplify the process of granting batch logon privileges to **backupuser**.

```
schtasks /create /sc MINUTE /mo 1 /tn "Volume Backup Task" /ru backupuser /rp passw0rd! /tr c:\temp\backup.bat
```

Wait for a few minutes...

```
aws ec2 describe-snapshots --filters "Name=volume-id,Values=<volume-id>"
```

If this is not working as expected, please ensure the **backup.bat** file is saved as a batch file (not text file). For further assistance, contact your instructor

### Task 2.4: Retaining Only Last Two EBS Volume Snapshots

```
schtasks /Delete /tn "Volume Backup Task"
```

When prompted to remove the task, type `Y` and press **Enter**.


```
aws ec2 describe-snapshots --filters "Name=volume-id, Values=<volume-id>" --query 'Snapshots[*].SnapshotId'
```

```
C:\temp\snapshotter.ps1 <region>
```


```
aws ec2 describe-snapshots --filters "Name=volume-id, Values=<volume-id>" --query 'Snapshots[*].SnapshotId'
```

___
## Task 3: Moving Log Files to Amazon S3

In this section, you will learn about moving files off from an Amazon EC2 instance and onto Amazon S3 by creating a sample log file.

### Task 3.1: RDP into the Processor Instance


```
aws configure
```

111. [111]To download the PowerShell file **loggen.ps1** to your instance, copy the following command and run it from within your instance:

```
(New-Object System.Net.WebClient).DownloadFile("https://us-west-2-aws-training.s3.amazonaws.com/awsu-ilt/AWS-100-SYS/v2.6/lab-3-storage-windows/scripts/loggen.ps1", "c:\temp\loggen.ps1")
```


### Task 3.2: Moving A Log File Into Amazon S3

```
C:\temp\loggen.ps1
```

```
cd \temp
```

```
aws s3 mv timestamp.log "s3://<s3-bucket-name>/logfiles/timestamp-$(Get-Date -Format 'M-d-yyyy-h:m:s')"
```

wait for a few minutes...

```
aws s3 mv timestamp.log "s3://<s3-bucket-name>/logfiles/timestamp-$(Get-Date -Format 'M-d-yyyy-h:m:s')"
```

```
aws s3 ls s3://<s3-bucket-name>
```

```
aws s3 ls s3://<s3-bucket-name>/logfiles/
```

```
aws s3 mv s3://<s3-bucket-name>/logfiles/<file-name> s3://<s3-bucket-name>/logfiles/archive/<file-name>
```

```
aws s3 ls s3://<s3-bucket-name>/logfiles/
```

### Task 3.3: Configuring Amazon Glacier Lifecycle Policy for logfiles USING CONSOLE


___
## Lab Complete
Congratulations! You have completed this lab. 