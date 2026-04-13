# ######################################
# ### ArgoCD Cluster Service Account ###
# ######################################

resource "kubernetes_namespace" "aurora_platform_system" {
  metadata {
    name        = "platform-system"
    labels      = local.aurora_namespace_labels
    annotations = local.aurora_namespace_annotations
  }

  provider = kubernetes.aurora
}

# Manages Kubernetes Cluster Register.
#
# https://github.com/gccloudone-aurora-iac/terraform-kubernetes-cluster-register
#
module "aurora_argocd_cluster_sp" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-kubernetes-cluster-register.git?ref=v1.0.0"

  service_account_name = "argocd-mgmt"
  namespace            = "platform-system"

  role_binding = {
    scope     = "cluster"
    role_name = "cluster-admin"
  }

  providers = { kubernetes = kubernetes.aurora }
}

resource "kubernetes_cluster_role" "aurora_bill_of_landing" {
  metadata {
    name = "bill-of-landing"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  provider = kubernetes.aurora
}

# Manages Kubernetes Cluster Register.
#
# https://github.com/gccloudone-aurora-iac/terraform-kubernetes-cluster-register
#
module "aurora_bill_of_landing_sp" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-kubernetes-cluster-register.git?ref=v1.0.0"

  service_account_name = "bill-of-landing"
  namespace            = "platform-system"

  role_binding = {
    scope     = "cluster"
    role_name = "bill-of-landing"
  }

  providers = { kubernetes = kubernetes.aurora }
}
