data "template_file" "cloudwatch_dashboard_elements" {

  template = <<EOF
{
  "type": "text",
  "width": 24,
  "height": 1,
  "properties": {
    "markdown": "\n# Database\n"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${aws_rds_cluster_instance.instance_primary.identifier}", { "label": "Primary" } ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${data.aws_region.current.name}",
    "title": "Connections"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "AWS/RDS", "WriteLatency", "DBInstanceIdentifier", "${aws_rds_cluster_instance.instance_primary.identifier}", { "label": "Primary" } ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${data.aws_region.current.name}",
    "title": "Write Latency"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_rds_cluster_instance.instance_primary.identifier}", { "label": "Primary" } ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${data.aws_region.current.name}",
    "title": "CPU Utilization"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "${aws_rds_cluster_instance.instance_primary.identifier}", { "label": "Primary" } ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${data.aws_region.current.name}",
    "title": "Freeable Memory"
  }
}
EOF
}