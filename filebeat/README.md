# Packer file to create an ECS optimized AMI with Filebeat Agent

> This filebeat agent uses logstash output on localhost. Please modify the `filebeat.yml` file for desired output. This AMI does not run logstash.

```
$ packer build packer.json
amazon-ebs output will be in this color.

==> amazon-ebs: Prevalidating AMI Name: ecs-with-filebeat 1521191665
    amazon-ebs: Found Image ID: ami-cad827b7
==> amazon-ebs: Creating temporary keypair: packer_5aab8af1-cedf-a234-64be-0a53b9747537
==> amazon-ebs: Creating temporary security group for this instance: packer_5aab8af5-6486-3d5a-2f01-b14984b71e24
==> amazon-ebs: Authorizing access to port 22 from 0.0.0.0/0 in the temporary security group...
==> amazon-ebs: Launching a source AWS instance...
==> amazon-ebs: Adding tags to source instance
    amazon-ebs: Adding tag: "Name": "Packer Builder"
    amazon-ebs: Instance ID: i-092fe876957eab55e
==> amazon-ebs: Waiting for instance (i-092fe876957eab55e) to become ready...
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Uploading filebeat.yml => /tmp/filebeat.yml
==> amazon-ebs: Provisioning with shell script: filebeat.sh
    amazon-ebs:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    amazon-ebs:                                  Dload  Upload   Total   Spent    Left  Speed
    amazon-ebs: 100 12.1M  100 12.1M    0     0  15.8M      0 --:--:-- --:--:-- --:--:-- 15.8M
    amazon-ebs: warning: filebeat-6.2.2-x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID d88e42b4: NOKEY
    amazon-ebs: Preparing packages...
    amazon-ebs: filebeat-6.2.2-1.x86_64
==> amazon-ebs: Stopping the source instance...
    amazon-ebs: Stopping instance, attempt 1
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating the AMI: ecs-with-filebeat 1521191665
    amazon-ebs: AMI: ami-***
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
us-east-1: ami-****
```

Once the instance is launched, we can verify if filebeat agent is running after ssh-ing into it.

```
[root@ip-10-0-3-204 ec2-user]# service filebeat status
filebeat-god (pid  2832) is running...
```
Agent log is in `/var/log/filebeat/filebeat`.
