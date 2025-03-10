######################################
### ArgoCD Cluster Service Account ###
######################################

## aurora-dev ##

resource "kubernetes_namespace" "aurora_dev_cc_00_platform_system" {
  metadata {
    name        = "platform-system"
    labels      = local.aurora_namespace_labels
    annotations = local.aurora_namespace_annotations
  }

  provider = kubernetes.aurora_dev
}

module "aurora_dev_cc_00_argocd_cluster_sp" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-kubernetes-cluster-register?ref=v1.0.0"

  service_account_name = "argocd-mgmt"
  namespace            = "platform-system"

  role_binding = {
    scope     = "cluster"
    role_name = "cluster-admin"
  }

  providers = { kubernetes = kubernetes.aurora_dev }
}

resource "kubernetes_cluster_role" "aurora_dev_cc_00_bill_of_landing" {
  metadata {
    name = "bill-of-landing"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  provider = kubernetes.aurora_dev
}

module "aurora_dev_cc_00_bill_of_landing_sp" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-kubernetes-cluster-register?ref=v1.0.0"

  service_account_name = "bill-of-landing"
  namespace            = "platform-system"

  role_binding = {
    scope     = "cluster"
    role_name = "bill-of-landing"
  }

  providers = { kubernetes = kubernetes.aurora_dev }
}
