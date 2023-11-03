resource "shoreline_notebook" "redis_aof_file_corruption_incident" {
  name       = "redis_aof_file_corruption_incident"
  data       = file("${path.module}/data/redis_aof_file_corruption_incident.json")
  depends_on = [shoreline_action.invoke_redis_aof_restore,shoreline_action.invoke_redis_aof_repair]
}

resource "shoreline_file" "redis_aof_restore" {
  name             = "redis_aof_restore"
  input_file       = "${path.module}/data/redis_aof_restore.sh"
  md5              = filemd5("${path.module}/data/redis_aof_restore.sh")
  description      = "Restore from backup: If a recent backup is available, restore the Redis AOF file from the backup and verify the data integrity."
  destination_path = "/tmp/redis_aof_restore.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "redis_aof_repair" {
  name             = "redis_aof_repair"
  input_file       = "${path.module}/data/redis_aof_repair.sh"
  md5              = filemd5("${path.module}/data/redis_aof_repair.sh")
  description      = "Repair the AOF file: Use Redis tools such as "
  destination_path = "/tmp/redis_aof_repair.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_redis_aof_restore" {
  name        = "invoke_redis_aof_restore"
  description = "Restore from backup: If a recent backup is available, restore the Redis AOF file from the backup and verify the data integrity."
  command     = "`chmod +x /tmp/redis_aof_restore.sh && /tmp/redis_aof_restore.sh`"
  params      = ["PATH_TO_REDIS_AOF_BACKUP_DIRECTORY","PATH_TO_REDIS_DATA_DIRECTORY"]
  file_deps   = ["redis_aof_restore"]
  enabled     = true
  depends_on  = [shoreline_file.redis_aof_restore]
}

resource "shoreline_action" "invoke_redis_aof_repair" {
  name        = "invoke_redis_aof_repair"
  description = "Repair the AOF file: Use Redis tools such as "
  command     = "`chmod +x /tmp/redis_aof_repair.sh && /tmp/redis_aof_repair.sh`"
  params      = ["PATH_TO_AOF_FILE"]
  file_deps   = ["redis_aof_repair"]
  enabled     = true
  depends_on  = [shoreline_file.redis_aof_repair]
}

