require 'nokogiri'
require 'open-uri'
require 'json'

url = "https://swamprabbits.com/team/roster"
doc = Nokogiri::HTML(URI.open(url))

players = []

# The page has sections like "Forwards", "Defenders", "Goalies"
# Each section is followed by multiple <div> or <p> blocks with player info
current_position_group = nil

doc.css("h2, p").each do |node|
  text = node.text.strip

  # Detect section headers
  if ["Forwards", "Defenders", "Goalies"].include?(text)
    current_position_group = text
    next
  end

  # Skip glossary or staff sections
  next if text.start_with?("Glossary") || text.start_with?("Staff")

  # Player rows look like: "Brent Pedersen #10 F 6-2 220 L Arthur, ON"
  if current_position_group && text =~ /#\d+/
    parts = text.split
    # Extract jersey number
    number_index = parts.find_index { |p| p.start_with?("#") }
    jersey_number = parts[number_index]&.delete("#")
    name = parts[0..(number_index - 1)].join(" ")
    pos = parts[number_index + 1]
    height = parts[number_index + 2]
    weight = parts[number_index + 3]
    shoots = parts[number_index + 4]
    birthplace = parts[(number_index + 5)..-1].join(" ")

    players << {
      full_name: name,
      jersey_number: jersey_number,
      position: pos || current_position_group[0], # fallback to group initial
      height: height,
      weight: weight,
      shoots_catches: shoots,
      birthplace: birthplace
    }
  end
end

File.write("swamp_roster.json", JSON.pretty_generate(players))
puts "✅ Roster saved to swamp_roster.json"
