require 'nokogiri'
require 'open-uri'
require 'json'

url = "https://swamprabbits.com/team/roster"
doc = Nokogiri::HTML(URI.open(url))

players = []
current_group = nil

doc.css("h2, p").each do |node|
  text = node.text.strip
  next if text.empty?

  # Detect section headers
  if ["Forwards", "Defenders", "Goalies"].include?(text)
    current_group = text
    next
  end

  # Skip glossary/staff
  next if text.start_with?("Glossary") || text.start_with?("Staff")

  # Player lines contain a jersey number like "#10"
  if current_group && text =~ /#\d+/
    parts = text.split
    number_index = parts.find_index { |p| p.start_with?("#") }
    jersey_number = parts[number_index].delete("#")
    name = parts[0...number_index].join(" ")
    pos = parts[number_index + 1]
    height = parts[number_index + 2]
    weight = parts[number_index + 3]
    shoots = parts[number_index + 4]
    birthplace = parts[(number_index + 5)..].join(" ")

    players << {
      full_name: name,
      jersey_number: jersey_number,
      position: pos || current_group[0],
      height: height,
      weight: weight,
      shoots_catches: shoots,
      birthplace: birthplace,
      group: current_group
    }
  end
end

File.write("swamp_roster.json", JSON.pretty_generate(players))
puts "✅ Roster saved to swamp_roster.json"
