# Running filebeat with ECS


## Create the AMI with filebeat using Packer

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

## Optional - Launch an instance

Once the instance is launched with this AMI, we can verify if filebeat agent is running after ssh-ing into it.

```
[root@ip-10-0-3-204 ec2-user]# service filebeat status
filebeat-god (pid  2832) is running...
```
Agent log is in `/var/log/filebeat/filebeat`.


## Create the ECS cluster

First, create an ECS cluster using the ECS wizard, unless there is one running already. Locate the launch config, and copy it.

This will be messy as you'd need to copy the cluster's launch config, and modify the copy to use the above AMI. Then update the ECS ASG with this new launch config. Then terminate the container instances so that the new AMI can be picked up by new instances. I know, it sucks. I'll come up with a CLI option to do this soon.

## Launch container(s) in this ECS Cluster

Once you've created an ECS cluster with this AMI, you can define a volume on the host, and mount the container to it. Here is a super simple, non production example with `tomcat` docker image. Notice the `mountPoints` and `volumes` section below.

```json
{
  "executionRoleArn": "arn:aws:iam::*****:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "dnsSearchDomains": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/tomcat8",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": null,
      "portMappings": [
        {
          "hostPort": 0,
          "protocol": "tcp",
          "containerPort": 8080
        }
      ],
      "command": null,
      "linuxParameters": null,
      "cpu": 128,
      "environment": [],
      "ulimits": null,
      "dnsServers": null,
      "mountPoints": [
        {
          "readOnly": null,
          "containerPath": "/usr/local/tomcat/logs",
          "sourceVolume": "logs"
        }
      ],
      "workingDirectory": null,
      "dockerSecurityOptions": null,
      "memory": 128,
      "memoryReservation": null,
      "volumesFrom": [],
      "image": "tomcat",
      "disableNetworking": null,
      "healthCheck": null,
      "essential": true,
      "links": null,
      "hostname": null,
      "extraHosts": null,
      "user": null,
      "readonlyRootFilesystem": null,
      "dockerLabels": null,
      "privileged": null,
      "name": "tomcat8"
    }
  ],
  "placementConstraints": [],
  "memory": "256",
  "taskRoleArn": "arn:aws:iam::****:role/ecsTaskExecutionRole",
  "compatibilities": [
    "EC2"
  ],
  "taskDefinitionArn": "arn:aws:ecs:us-east-1:****:task-definition/tomcat8:3",
  "family": "tomcat8",
  "requiresAttributes": [
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.task-iam-role"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.execution-role-awslogs"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.logging-driver.awslogs"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19"
    }
  ],
  "requiresCompatibilities": [
    "EC2"
  ],
  "networkMode": null,
  "cpu": "128",
  "revision": 3,
  "status": "ACTIVE",
  "volumes": [
    {
      "name": "logs",
      "host": {
        "sourcePath": "/var/log"
      }
    }
  ]
}
```

Once this task is launched, you can see this on the ECS host -

```
[root@ip-10-0-1-53 log]# pwd
/var/log
[root@ip-10-0-1-53 log]# ls -altrh
..
..
-rw-r-----  1 root root    0 Mar 16 10:08 manager.2018-03-16.log
-rw-r-----  1 root root    0 Mar 16 10:08 host-manager.2018-03-16.log
-rw-r-----  1 root root    0 Mar 16 10:08 localhost_access_log.2018-03-16.txt
-rw-r-----  1 root root  459 Mar 16 10:09 localhost.2018-03-16.log
-rw-r-----  1 root root 6.8K Mar 16 10:09 catalina.2018-03-16.log
```

These files will be ingested by the filebeat agent, and we can verify by tailing `/var/log/filebeat/filebeat` on the ECS host.
