output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "update_kubeconfig_command" {
  description = "Run this command to authenticate kubectl with your new EKS cluster"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.main.name}"
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}