resource "helm_release" "jupyterhub_helm" {
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart"
  chart      = "jupyterhub"
  namespace  = "jhub-${var.cluster_name}"
  version    = "3.1.0"
  timeout    = 3600

  cleanup_on_fail  = true
  create_namespace = true

  depends_on = [
    module.eks,
  ]
}
