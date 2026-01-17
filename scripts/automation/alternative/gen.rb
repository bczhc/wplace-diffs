#!/bin/env ruby

# gen_diff_script.rb

# 配置文件名和路径
NAMES_FILE = 'names.txt'
DOWNLOAD_CMD = './download'
DIFF_TOOL = '~/wt/archive-tool diff'
DIFF_DIR = './diffs'

# 检查文件是否存在
unless File.exist?(NAMES_FILE)
  warn "Error: #{NAMES_FILE} not found."
  exit 1
end

# 读取所有行并去重/去空
lines = File.readlines(NAMES_FILE).map(&:strip).reject(&:empty?)

puts "#!/bin/bash"
puts "mkdir -p #{DIFF_DIR}"
puts "set -e"
puts ""

# 使用 sliding window (each_cons) 处理两两相邻的文件
lines.each_cons(2) do |prev_raw, curr_raw|
  # 提取去掉 'world-' 前缀的文件名（用于 .tar 和 .diff）
  prev_name = prev_raw.sub(/^world-/, '')
  curr_name = curr_raw.sub(/^world-/, '')
  
  prev_tar = "#{prev_name}.tar"
  curr_tar = "#{curr_name}.tar"
  diff_file = "#{DIFF_DIR}/#{curr_name}.diff"

  puts "### Processing: #{prev_raw} -> #{curr_raw} ###"
  
  # 1. 确保上一个文件存在（如果是第一次循环则下载）
  puts "if [ ! -f \"#{prev_tar}\" ]; then"
  puts "  #{DOWNLOAD_CMD} #{prev_raw}"
  puts "fi"

  # 2. 下载当前文件
  puts "if [ ! -f \"#{curr_tar}\" ]; then"
  puts "  #{DOWNLOAD_CMD} #{curr_raw}"
  puts "fi"

  # 3. 执行 Diff
  puts "#{DIFF_TOOL} \"#{prev_tar}\" \"#{curr_tar}\" \"#{diff_file}\""

  # 4. 删除不再需要的上一个 tar 包（释放空间）
  puts "rm -f \"#{prev_tar}\""
  puts ""
end

# 最后可以选择是否删除最后一个 tar 包
# puts "rm -f \"#{lines.last.sub(/^world-/, '')}.tar\""
