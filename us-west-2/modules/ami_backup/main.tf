variable "source_amis" {
  description = "Map of AMIs to copy. Keys must be static (e.g., frontend, backend)"
  type        = map(string)
}

resource "aws_ami_copy" "this" {
  for_each = var.source_amis

  name              = "copied-${each.key}"
  description       = "Copy of ${each.key} from us-east-1"
  source_ami_id     = each.value
  source_ami_region = "us-east-1"
}

output "copied_ami_ids" {
  value = { for k, v in aws_ami_copy.this : k => v.id }
}
