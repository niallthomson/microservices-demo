data "template_file" "catalog_dashboard_elements" {

  template = <<EOF
{
  "type": "text",
  "width": 24,
  "height": 1,
  "properties": {
    "markdown": "\n# Database Client\n"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "ECS/ContainerInsights/Prometheus", "go_sql_stats_connections_idle", "db_name", "db", "TaskDefinitionFamily", "${module.app_service.service_name}", "ClusterName", "${var.cluster_name}" ],
      [ ".", "go_sql_stats_connections_max_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_in_use", ".", ".", ".", ".", ".", "." ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${var.region}",
    "title": "DB Connections",
    "yAxis": {
        "left": {
            "label": "Count",
            "showUnits": false
        }
    }
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "ECS/ContainerInsights/Prometheus", "go_sql_stats_connections_idle", "db_name", "reader_db", "TaskDefinitionFamily", "${module.app_service.service_name}", "ClusterName", "${var.cluster_name}" ],
      [ ".", "go_sql_stats_connections_max_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_in_use", ".", ".", ".", ".", ".", "." ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${var.region}",
    "title": "Reader DB Connections",
    "yAxis": {
        "left": {
            "label": "Count",
            "showUnits": false
        }
    }
  }
}
EOF
}