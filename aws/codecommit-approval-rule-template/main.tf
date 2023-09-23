resource "aws_codecommit_approval_rule_template" "main" {
  name        = var.repository_name
  description = "This is an approval rule template"

  content = jsonencode({
    Version               = "2018-11-08"
    DestinationReferences = ["refs/heads/master"]
    Statements = [{
      Type                    = "Approvers"
      NumberOfApprovalsNeeded = "${var.number_approvals}"
      ApprovalPoolMembers     = "${var.approval_pool_members}"
    }]
  })
}
resource "aws_codecommit_approval_rule_template_association" "main" {
  approval_rule_template_name = aws_codecommit_approval_rule_template.main.name
  repository_name             = var.repository_name
}