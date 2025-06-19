

resource "time_sleep" "aws_iam_role_policy_bedrock_spl_to_esql_kb" {
  create_duration = "20s"
  depends_on      = [aws_iam_role_policy.bedrock_kb_policy_oss]
}

resource "aws_bedrockagent_knowledge_base" "spl_to_esql_kb" {
  name        = var.kb_name
  description = "Knowledge base for spl to esql migration documents"
  role_arn    = aws_iam_role.bedrock_kb_role.arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${var.region}::foundation-model/cohere.embed-english-v3" #data.aws_bedrock_foundation_model.kb.model_arn
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.oss_collection_kb.arn
      vector_index_name = opensearch_index.os_kb.name
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

}

resource "aws_bedrockagent_data_source" "kb_spl_to_esql_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.spl_to_esql_kb.id
  name              = "${var.kb_name}-DataSource"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.kb_s3.arn
    }
  }
}

resource "aws_bedrockagent_data_source" "webcrawlers_spl_to_esql" {
  for_each          = var.webcrawlers_spl_to_esql
  knowledge_base_id = aws_bedrockagent_knowledge_base.spl_to_esql_kb.id
  name              = "crawler-${each.key}"
  description       = "Web crawler for ${each.key}"

  data_source_configuration {
    type = "WEB"

    web_configuration {
      source_configuration {
        url_configuration {
          seed_urls {
            url = each.value.urls[0]
          }
          dynamic "seed_urls" {
            for_each = slice(each.value.urls, 1, length(each.value.urls))
            content {
              url = seed_urls.value
            }
          }
        }
      }
      crawler_configuration {
        crawler_limits {
          rate_limit = 300 # Requests per minute

        }
        inclusion_filters = length(each.value.include_patterns) > 0 ? each.value.include_patterns : null
        exclusion_filters = length(each.value.exclude_patterns) > 0 ? each.value.exclude_patterns : null
      }
    }
  }
}
