# --- 1. THE BRIDGE: OIDC Provider ---
# This tells AWS: "Trust tokens signed by my Athanor cluster"
resource "aws_iam_oidc_provider" "athanor" {
  url             = "https://oidc.athanor.local" # Your k3s OIDC URL
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # The CA thumbprint
}

# --- 2. THE POLICY: What can the pod do? ---
resource "aws_iam_policy" "s3_access" {
  name        = "AthanorS3Access"
  description = "Allows Forgejo to backup to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:PutObject", "s3:GetObject"]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::my-athanor-backups/*"
    }]
  })
}

# --- 3. THE ROLE: The "Private Table" Entry ---
resource "aws_iam_role" "forgejo_role" {
  name = "athanor-forgejo-s3-role"

  # This is the "Trust Relationship" (Who can wear this role?)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_oidc_provider.athanor.arn
      }
      Condition = {
        StringEquals = {
          # Only allow the specific ServiceAccount in the specific namespace
          "${replace(aws_iam_oidc_provider.athanor.url, "https://", "")}:sub" = "system:serviceaccount:git:forgejo-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.forgejo_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# --- 4. THE ATTACHMENT: Kubernetes ServiceAccount ---
resource "kubernetes_service_account" "forgejo_sa" {
  metadata {
    name      = "forgejo-sa"
    namespace = "git"
    annotations = {
      # The "Magic Link" that tells the pod which AWS role to assume
      "eks.amazonaws.com/role-arn" = aws_iam_role.forgejo_role.arn
    }
  }
}
