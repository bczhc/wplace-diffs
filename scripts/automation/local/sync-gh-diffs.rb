#!/usr/bin/env ruby
require 'set'
require 'shellwords'

# 核心配置
REPO = "bczhc/wplace-diffs"

def log(message)
  puts "[#{Time.now.strftime('%H:%M:%S')}] #{message}"
end

# 封装执行逻辑：静默执行，失败时退出
def execute_quietly(cmd)
  # 运行命令并将 stdout/stderr 保持默认或重定向（根据需要）
  # 这里保持默认输出以便看到 gh-upload-progress 的进度条
  unless system(cmd)
    puts "\n[ERROR] 命令执行失败，脚本已终止。"
    exit 1
  end
end

# 1. 获取已存在的 Release 列表
log "正在同步远程 Release 列表..."
list_cmd = "gh release -R #{REPO.shellescape} list -L 10000 | cut -f1"
remote_output = `#{list_cmd}`
unless $?.success?
  log "错误：无法连接到 GitHub 仓库。"
  exit 1
end

existing_releases = remote_output.split("\n").map(&:strip).to_set

# 2. 扫描本地目录
log "正在扫描本地 diffs 目录..."
unless Dir.exist?("diffs")
  log "错误：找不到 diffs 目录。"
  exit 1
end

local_files = Dir.glob("diffs/*.diff").map { |f| File.basename(f, ".diff") }
to_upload = local_files.reject { |name| existing_releases.include?(name) }.sort

if to_upload.empty?
  log "所有文件均已同步，无需操作。"
  exit 0
end

log "发现 #{to_upload.size} 个新文件待上传。"

# 3. 处理流程
to_upload.each_with_index do |name, index|
  diff_path = File.join("diffs", "#{name}.diff")
  zst_path = File.join("/tmp", "#{name}.diff.zst")
  
  log "[#{index + 1}/#{to_upload.size}] 正在处理: #{name}"

  # A. 压缩
  # 使用 Shellwords.join 确保路径中有特殊字符也能安全执行
  log "   - 正在压缩文件..."
  compress_cmd = "cat #{diff_path.shellescape} | zstd -9 > #{zst_path.shellescape}"
  execute_quietly(compress_cmd)

  # B. 上传
  log "   - 正在上传至 GitHub..."
  upload_cmd = "yes | gh-upload-progress -R #{REPO.shellescape} release create #{name.shellescape} #{zst_path.shellescape}"
  
  begin
    execute_quietly(upload_cmd)
    log "   - 完成。"
  ensure
    # C. 清理临时文件
    if File.exist?(zst_path)
      File.delete(zst_path)
    end
  end
end

log "全部任务处理完毕！"
