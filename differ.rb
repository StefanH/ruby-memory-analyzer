require 'set'
require 'json'


class AllocationLine < Struct.new(:json)
  %w(generation type name file line method 
    value frozen flags).each do |attrib|
    define_method attrib do
      json[attrib]
    end
  end

  def line_report
    "#{type} #{name} #{file}:#{line} #{value}"
  end
end

if ARGV.length != 2
  puts 'Usage diff_heaps [ORIG.json] [AFTER.json]'
  exit 1
end

origs = Set.new

File.open(ARGV[0], 'r').each_line do |line|
  parsed = JSON.parse(line)
  origs << parsed['address'] if parsed && parsed['address']
end

diff = []

File.open(ARGV[1], 'r').each_line do |line|
  parsed = JSON.parse(line)

  if parsed && parsed['address']
    diff << AllocationLine.new(parsed) unless origs.include? parsed['address']
  end
end

diff.each {|d| puts(d.line_report) }

diff.group_by do |x|
  [x.type, x.file, x.line]
end.map { |x,y|
  [x, y.count]
}.sort { |a,b|
  b[1] <=> a[1]
}.each {|x,y|
  if y >= 5
    puts "Leaked #{y} #{x[0]} objects at: #{x[1]}:#{x[2]}"
  end
}
