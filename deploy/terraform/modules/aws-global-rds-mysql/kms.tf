resource "aws_kms_key" "kms" {
  description             = "KMS key for encrypting aurora"
  deletion_window_in_days = 10

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