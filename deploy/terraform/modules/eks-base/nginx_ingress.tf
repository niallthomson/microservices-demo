resource "aws_eip" "nginx_ingress" {
  vpc   = true
  count = length(var.availability_zones)
}

data "template_file" "nginx_config" {
  template = file("${path.module}/templates/nginx-ingress-values.yml")

  vars = {
    eip_allocs   = join(",", aws_eip.nginx_ingress.*.id)
    replicas     = length(var.availability_zones)
    minAvailable = length(var.availability_zones) > 1 ? length(var.availability_zones) - 1 : 1
  }
}

resource "kubernetes_namespace" "nginx_ingress" {
  depends_on = [null_resource.cluster_blocker]

  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  name      = "nginx-ingress"
  namespace = kubernetes_namespace.nginx_ingress.metadata[0].name
  chart     = "stable/nginx-ingress"
  version   = "1.40.2"

  values = [data.template_file.nginx_config.rendered]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}