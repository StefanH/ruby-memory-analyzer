require 'rubygems'
require "bundler/setup"
require 'pry'
require 'active_support'
require 'active_support/core_ext'

require 'json'

class Analyzer
  def initialize(filename)
    @filename = filename
  end

  def analyze
    @data = []
    File.open(@filename) do |f|
      f.each_line do |line|
        @data << AllocationLine.new(JSON.parse(line))
      end
    end

    @generations = @data.group_by(&:generation).map {|number, lines| Generation.new(number.to_i, lines) }.sort_by(&:number)

    binding.pry
  end

  def generation_count_report
    @generations.sort_by(&:number).each {|g| puts "#{g.number} #{g.lines.count}"}
  end

  def generation number
    @generations.find {|g| g.number == number }
  end
end


class Generation < Struct.new(:number, :lines)
  def lines_report
    lines.map(&:line_report)
  end
end

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

Analyzer.new(ARGV[0]).analyze