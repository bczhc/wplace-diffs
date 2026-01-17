#!/usr/bin/env ruby

# 获取命令行参数
latest_name = ARGV[0]

if latest_name.nil? || latest_name.empty?
  puts "用法: ruby urls.rb <latest_name>"
  exit 1
end

# 1. 执行命令并读入数组
# gh release list 的结果通过管道处理后，每行一个版本号
cmd = "gh release -R murolem/wplace-archives list -L 2000 | cut -f1 | sort"
releases = `#{cmd}`.split("\n")

if releases.empty?
  puts "未找到任何 release。"
  exit 1
end

# 2. 把最后一个删掉 (即数组中最后一行)
releases.pop

# 3. 寻找 latest_name 的位置
index = releases.index(latest_name)

if index.nil?
  puts "错误: 在列表中未找到 '#{latest_name}' (注意：最后一个已被剔除)"
  exit 1
end

# 4. 把此位置前的所有（不包括 latest_name 本身）再删掉
# 这里的 index 是 latest_name 的新下标，我们保留从 index 开始到末尾的所有元素
final_list = releases[index..-1]

File.open("./names.txt", "w") do |f|
  f.puts final_list
end

puts "处理完成，结果已写入 ./names.txt (共 #{final_list.size} 行)"
