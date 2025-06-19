
terraform {
  backend "s3" {
       bucket         = "hpf-se2-insfra-tf-data-fjdkjflf"
       key            = "terraform/state/terraform.tfstate"
       region         = "us-east-1"
     }
}
 