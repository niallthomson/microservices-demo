resource "aws_kms_key" "ssm_key" {
  description             = "${local.full_environment_prefix} SSM KMS key"
  deletion_window_in_days = 7

  policy = <<EOF
    {
      "Version": "2012-10-17",
      "Id": "key-default-1",
      "Statement": [
        {
          "Sid": "Default IAM policy for KMS keys",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "kms:*",
          "Resource": "*"
        },
        {
          "Sid": "Enable IAM user to perform kms actions as well",
          "Effect": "Allow",
          "Principal": {
            "AWS": "${data.aws_caller_identity.current.arn}"
          },
          "Action": "kms:*",
          "Resource": "*"
        }
      ]
    }
  EOF
}

resource "aws_iam_policy" "ssm_kms" {
  name = "${var.environment_name}-ssm-kms"

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.ssm_key.arn}"
    }
  ]
}
EOF
}