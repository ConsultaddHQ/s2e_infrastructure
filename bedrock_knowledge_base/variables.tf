variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "kb_name" {
  description = "The knowledge base name."
  type        = string
  default     = "hyperflex-s2e"
}

variable "kb_s3_bucket_name_prefix" {
  description = "The name prefix of the S3 bucket for the data source of the knowledge base."
  type        = string
  default     = "bedrock-knowledge-base-hf"
}

variable "kb_oss_collection_name" {
  description = "The name of the OSS collection for the knowledge base."
  type        = string
  default     = "bedrock-knowledge-base-hf"
}

variable "webcrawlers" {
  description = "Map of web crawler configs with multiple URLs"
  type = map(object({
    urls            = list(string)
    crawl_depth     = number
    include_patterns = optional(list(string), [])
    exclude_patterns = optional(list(string), [])
  }))

  default = {
    ecs_mapping = {
      urls            = ["https://www.elastic.co/guide/en/ecs/current/", "https://www.elastic.co/guide/en/ecs/current/"]
      crawl_depth     = 2
    }
  }
  # Example
  # webcrawlers = {
  #   ecs_mapping = {
  #     urls            = ["https://www.elastic.co/guide/en/ecs/current/", "https://www.elastic.co/guide/en/ecs/current/"]
  #     crawl_depth     = 2
  #   }
  #   ecs_mapping_with_patterns = {
  #     urls            = ["https://www.elastic.co/guide/en/ecs/current/", "https://www.elastic.co/guide/en/ecs/current/"]
  #     crawl_depth     = 2
  #     include_patterns = ["https://www.elastic.co/guide/en/ecs/current/*", "https://www.elastic.co/guide/en/current/*"]
  #     exclude_patterns = ["https://www.elastic.co/guide/en/current/*"]
  #   }
  # }
}

