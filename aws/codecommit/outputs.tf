output "repo_ssh_url" {
  value       = aws_codecommit_repository.main.clone_url_ssh
  description = "SSH url"
}

output "repo_http_url" {
  value       = aws_codecommit_repository.main.clone_url_http
  description = "HTTP url"
}