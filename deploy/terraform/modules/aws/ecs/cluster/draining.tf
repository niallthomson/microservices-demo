resource "aws_lambda_permission" "drain_lambda_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asg_drain.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.drain_lambda_sns.arn
}

resource "aws_sns_topic" "drain_lambda_sns" {
  name = "${var.environment_name}-asg-drain"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.drain_lambda_sns.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.asg_drain.arn
}

resource "aws_iam_role" "asg_drain_lambda" {
  name = "${var.environment_name}-asg-drain"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "asg_drain_lambda" {
  name = "${var.environment_name}-asg-drain"
  role = aws_iam_role.asg_drain_lambda.name

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:CompleteLifecycleAction",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecs:ListContainerInstances",
        "ecs:DescribeContainerInstances",
        "ecs:UpdateContainerInstancesState",
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "asg_drain_lambda" {
  role       = aws_iam_role.asg_drain_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
}

resource "aws_lambda_function" "asg_drain" {
  filename      = data.archive_file.lambda_zip_inline.output_path
  function_name = "${var.environment_name}-asg-drain"
  role          = aws_iam_role.asg_drain_lambda.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip_inline.output_base64sha256

  runtime = "python3.6"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/watchn_lambda_zip_inline.zip"
  source {
    content  = <<EOF
import json
import time
import boto3
CLUSTER = '${aws_ecs_cluster.cluster.name}'
REGION = '${var.region}'
ECS = boto3.client('ecs', region_name=REGION)
ASG = boto3.client('autoscaling', region_name=REGION)
SNS = boto3.client('sns', region_name=REGION)
def find_ecs_instance_info(instance_id):
    paginator = ECS.get_paginator('list_container_instances')
    for list_resp in paginator.paginate(cluster=CLUSTER):
        arns = list_resp['containerInstanceArns']
        desc_resp = ECS.describe_container_instances(cluster=CLUSTER,
                                                      containerInstances=arns)
        for container_instance in desc_resp['containerInstances']:
            if container_instance['ec2InstanceId'] != instance_id:
                continue
            print('Found instance: id=%s, arn=%s, status=%s, runningTasksCount=%s' %
                  (instance_id, container_instance['containerInstanceArn'],
                    container_instance['status'], container_instance['runningTasksCount']))
            return (container_instance['containerInstanceArn'],
                    container_instance['status'], container_instance['runningTasksCount'])
    return None, None, 0
def instance_has_running_tasks(instance_id):
    (instance_arn, container_status, running_tasks) = find_ecs_instance_info(instance_id)
    if instance_arn is None:
        print('Could not find instance ID %s. Letting autoscaling kill the instance.' %
              (instance_id))
        return False
    if container_status != 'DRAINING':
        print('Setting container instance %s (%s) to DRAINING' %
              (instance_id, instance_arn))
        ECS.update_container_instances_state(cluster=CLUSTER,
                                              containerInstances=[instance_arn],
                                              status='DRAINING')
    return running_tasks > 0
def lambda_handler(event, context):
    msg = json.loads(event['Records'][0]['Sns']['Message'])
    if 'LifecycleTransition' not in msg.keys() or \
        msg['LifecycleTransition'].find('autoscaling:EC2_INSTANCE_TERMINATING') == -1:
        print('Exiting since the lifecycle transition is not EC2_INSTANCE_TERMINATING.')
        return
    if instance_has_running_tasks(msg['EC2InstanceId']):
        print('Tasks are still running on instance %s; posting msg to SNS topic %s' %
              (msg['EC2InstanceId'], event['Records'][0]['Sns']['TopicArn']))
        time.sleep(5)
        sns_resp = SNS.publish(TopicArn=event['Records'][0]['Sns']['TopicArn'],
                                Message=json.dumps(msg),
                                Subject='Publishing SNS msg to invoke Lambda again.')
        print('Posted msg %s to SNS topic.' % (sns_resp['MessageId']))
    else:
        print('No tasks are running on instance %s; setting lifecycle to complete' %
              (msg['EC2InstanceId']))
        ASG.complete_lifecycle_action(LifecycleHookName=msg['LifecycleHookName'],
                                      AutoScalingGroupName=msg['AutoScalingGroupName'],
                                      LifecycleActionResult='CONTINUE',
                                      InstanceId=msg['EC2InstanceId'])
EOF
    filename = "main.py"
  }
}

resource "aws_iam_role" "asg_drain_lifecycle" {
  name = "${var.environment_name}-asg-lifecycle"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "asg_drain_lifecycle" {
  name = "${var.environment_name}-asg-drain"
  role = aws_iam_role.asg_drain_lifecycle.name

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.drain_lambda_sns.arn}"
    }
  ]
}
EOF
}