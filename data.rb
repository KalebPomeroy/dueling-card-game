require 'active_support/core_ext/hash/indifferent_access'
require "yaml"
require 'pp'

characters = YAML::load(File.open('data/characters.yaml')).with_indifferent_access[:characters]

elements = {}
classes = {}
class_element = {}
skills = {}
health = []
cost = []
speed = []
energy = []
characters.each do | c | 
    elements[c[:element]]||=0
    elements[c[:element]]+=1
    classes[c[:class]]||=0
    classes[c[:class]]+=1

    class_element[c[:class]]||={}
    class_element[c[:class]][c[:element]]||=0
    class_element[c[:class]][c[:element]]+=1
    class_element[c[:class]].keys.sort

    c[:skills].each do | s | 
        skills[s]||=0
        skills[s]+=1
    end

    health[c[:health]]||=0
    health[c[:health]]+=1

    cost[c[:cost]]||=0
    cost[c[:cost]]+=1

    energy[c[:energy]]||=0
    energy[c[:energy]]+=1

    speed[c[:speed]]||=0
    speed[c[:speed]]+=1


end

puts "**************"
puts "* Characters *"
puts "**************"
puts 

puts "Elemental breakdown"
pp elements
puts "Class breakdown"
pp classes
puts "Elements by Class"
pp class_element
puts "Skill breakdown"
pp skills
puts
puts "Health"
health.each_with_index {|count, val| puts "#{val}: #{'*' * (count||0) }" if val > 0}
puts
puts "Speed"
speed.each_with_index {|count, val| puts "#{val}: #{'*' * (count||0) }" if val > 0}
puts
puts "Energy"
energy.each_with_index {|count, val| puts "#{val}: #{'*' * (count||0) }" if val > 0}
puts
puts "Cost"
cost.each_with_index {|count, val| puts "#{val}: #{'*' * (count||0) }" if val > 0}
