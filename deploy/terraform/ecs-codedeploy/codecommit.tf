resource "aws_codecommit_repository" "repo" {
  repository_name = var.environment_name
  description     = "CodeCommit repo for Watchn"
}

resource "aws_iam_role" "codecommit_lambda" {
  name = "${var.environment_name}-codecommit"

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

resource "aws_iam_role_policy" "codecommit_lambda" {
  name = "${var.environment_name}-codecommit-lambda"
  role = aws_iam_role.codecommit_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": "*"
    },
    {
      "Action": [
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:GetRepository",
        "codecommit:GetDifferences"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codecommit_lambda_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.codecommit_lambda.name
}

data "archive_file" "codecommit_lambda" {
  type        = "zip"
  source_file = "${path.module}/templates/codecommit_function.js"
  output_path = "${path.module}/files/codecommit_function.zip"
}

resource "aws_lambda_function" "codecommit_lambda" {
  filename      = "files/codecommit_function.zip"
  function_name = "${var.environment_name}-codecommit"
  role          = aws_iam_role.codecommit_lambda.arn
  handler       = "codecommit_function.handler"

  source_code_hash = data.archive_file.codecommit_lambda.output_base64sha256

  runtime = "nodejs12.x"

  environment {
    variables = {
      ENVIRONMENT_NAME = var.environment_name
    }
  }
}

resource "aws_lambda_permission" "allow_codecommit" {
  statement_id  = "AllowExecutionFromCodeCommit"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.codecommit_lambda.function_name
  principal     = "codecommit.amazonaws.com"
  source_arn    = aws_codecommit_repository.repo.arn
}

/**
* This needs to be done in a single trigger block due to how CodeCommit trigger configuration works.
* If it is done in separate trigger blocks they will overwrite each other.
**/
resource "aws_codecommit_trigger" "trigger" {
  repository_name = aws_codecommit_repository.repo.repository_name

  dynamic "trigger" {
    
    for_each = local.components
    content {
      name            = trigger.value
      events          = ["all"]
      destination_arn = aws_lambda_function.codecommit_lambda.arn
      custom_data     = trigger.value
    }
  }
}