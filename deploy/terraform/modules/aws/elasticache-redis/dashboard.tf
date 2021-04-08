data "template_file" "cloudwatch_dashboard_elements" {

  template = <<EOF
{
  "type": "text",
  "width": 24,
  "height": 1,
  "properties": {
    "markdown": "\n# Redis\n"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [[
      ${join("],[", formatlist("\"AWS/ElastiCache\", \"CurrConnections\", \"CacheClusterId\", \"%s\"", aws_elasticache_replication_group.cluster.member_clusters))}
    ]],
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
    "metrics": [[
      ${join("],[", formatlist("\"AWS/ElastiCache\", \"CacheHitRate\", \"CacheClusterId\", \"%s\"", aws_elasticache_replication_group.cluster.member_clusters))}
    ]],
    "period": 60,
    "stat": "Sum",
    "region": "${data.aws_region.current.name}",
    "title": "Cache Hit Rate"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [[
      ${join("],[", formatlist("\"AWS/ElastiCache\", \"CPUUtilization\", \"CacheClusterId\", \"%s\"", aws_elasticache_replication_group.cluster.member_clusters))}
    ]],
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
    "metrics": [[
      ${join("],[", formatlist("\"AWS/ElastiCache\", \"FreeableMemory\", \"CacheClusterId\", \"%s\"", aws_elasticache_replication_group.cluster.member_clusters))}
    ]],
    "period": 60,
    "stat": "Sum",
    "region": "${data.aws_region.current.name}",
    "title": "Freeable Memory"
  }
}
EOF
}