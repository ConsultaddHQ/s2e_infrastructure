resource "aws_opensearchserverless_collection" "oss_collection_kb" {
  name = var.kb_oss_collection_name
  type = "VECTORSEARCH"
  depends_on = [
    aws_opensearchserverless_access_policy.oss_policy_access,
    aws_opensearchserverless_security_policy.oss_policy_encryption,
    aws_opensearchserverless_security_policy.oss_policy_network
  ]
}


provider "opensearch" {
  url         =  aws_opensearchserverless_collection.oss_collection_kb.collection_endpoint
  healthcheck = false
}

resource "opensearch_index" "os_kb" {
  name                           = var.kb_oss_collection_name
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<EOF
    {
        "properties": {
            "bedrock-knowledge-base-default-vector": {
                "type": "knn_vector",
                "dimension": 1024,
                "method": {
                "name": "hnsw",
                "engine": "faiss",
                "parameters": {
                    "m": 16,
                    "ef_construction": 512
                },
                "space_type": "l2"
                }
            },
            "AMAZON_BEDROCK_METADATA": {
                "type": "text",
                "index": false
            },
            "AMAZON_BEDROCK_TEXT_CHUNK": {
                "type": "text",
                "index": true
            }
        }
    }
  EOF
  force_destroy                  = true
  depends_on                     = [aws_opensearchserverless_collection.oss_collection_kb]
}
