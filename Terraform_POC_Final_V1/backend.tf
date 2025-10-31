terraform {
  backend "s3" {
    bucket         = "tfstate-dev-us-east-1-1761850669.35871"
    key            = "state/dev.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
