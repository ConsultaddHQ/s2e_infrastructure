# Terraform Configuration for AWS Knowledge Base Setup

This Terraform configuration sets up an AWS Knowledge Base with an S3 bucket for data storage, an OpenSearch Serverless (OSS) collection, and web crawler configurations for data ingestion.

## Prerequisites

- **Terraform**: Install Terraform (version 1.5.0 or later).
- **AWS CLI**: Configure the AWS CLI with appropriate credentials.
- **Git**: Clone this repository to your local machine.

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/ConsultaddHQ/s2e_infrastructure.git
   cd s2e_infrastructure/bedrock_knowledge_base
   ```

2. **Configure the Backend**

   Create a `backend.tf` file to specify the Terraform backend for state management. Example for an S3 backend:

   ```hcl
   terraform {
     backend "s3" {
       bucket         = "<your-s3-bucket-name>"
       key            = "terraform/state/terraform.tfstate"
       region         = "<your-region>"
       dynamodb_table = "<your-dynamodb-table>" # Optional, for state locking
     }
   }
   ```

   Replace `<your-s3-bucket-name>`, `<your-region>`, and `<your-dynamodb-table>` with your values.

3. **Create a `terraform.tfvars` File**

   Define the required variables in a `terraform.tfvars` file. Example:

   ```hcl
   region                   = "us-east-1"
   kb_name                  = "hyperflex-s2e"
   kb_s3_bucket_name_prefix = "bedrock-knowledge-base-hf"
   kb_oss_collection_name   = "bedrock-knowledge-base-hf"
   webcrawlers = {
     ecs_mapping = {
       urls        = ["https://www.elastic.co/guide/en/ecs/current/"]
       crawl_depth = 2
     }
     ecs_mapping_with_patterns = {
       urls            = ["https://www.elastic.co/guide/en/ecs/current/"]
       crawl_depth     = 2
       include_patterns = ["https://www.elastic.co/guide/en/ecs/current/*"]
       exclude_patterns = ["https://www.elastic.co/guide/en/current/*"]
     }
   }
   ```

4. **Variable Descriptions**

   Below are the variables you can configure in `terraform.tfvars`:

   - **`region`**  
     - **Description**: The AWS region where resources will be deployed.  
     - **Type**: `string`  
     - **Default**: `"us-east-1"`  
     - **Example**: `"us-west-2"`

   - **`kb_name`**  
     - **Description**: The name of the Knowledge Base.  
     - **Type**: `string`  
     - **Default**: `"hyperflex-s2e"`  
     - **Example**: `"my-knowledge-base"`

   - **`kb_s3_bucket_name_prefix`**  
     - **Description**: The prefix for the S3 bucket name used as the data source for the Knowledge Base.  
     - **Type**: `string`  
     - **Default**: `"bedrock-knowledge-base-hf"`  
     - **Example**: `"my-kb-bucket"`

   - **`kb_oss_collection_name`**  
     - **Description**: The name of the OpenSearch Serverless collection for the Knowledge Base.  
     - **Type**: `string`  
     - **Default**: `"bedrock-knowledge-base-hf"`  
     - **Example**: `"my-oss-collection"`

   - **`webcrawlers`**  
     - **Description**: A map of web crawler configurations, each specifying URLs to crawl, crawl depth, and optional include/exclude patterns.  
     - **Type**: `map(object)`  
     - **Fields**:
       - `urls`: List of URLs to crawl (`list(string)`).  
       - `crawl_depth`: Maximum depth for crawling (`number`).  
       - `include_patterns`: Optional URL patterns to include (`list(string)`, default: `[]`).  
       - `exclude_patterns`: Optional URL patterns to exclude (`list(string)`, default: `[]`). 

5. **Manual Setup: Enable Model Access in Bedrock (One-Time Step)**
  Amazon Bedrock embedding models from third-party providers like Cohere require manual access approval via the AWS Console. This cannot be automated with Terraform or the AWS CLI due to policy restrictions.

  * Open the Bedrock console(model-access)
  * Find the model cohere.embed-english-v3 in the list (under the Cohere section)
  * Click “Manage model access”
  * Check the box for cohere.embed-english-v3 and Llama 3.3 70B Instruct, and click “Save changes”
  * After enabling, you can run terraform apply to complete provisioning