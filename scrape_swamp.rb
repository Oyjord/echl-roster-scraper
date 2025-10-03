require 'nokogiri'
require 'open-uri'
require 'json'

url = "https://swamprabbits.com/team/roster"
doc = Nokogiri::HTML(URI.open(url))

players = []

# The roster page has sections for Forwards, Defenders, Goalies
doc.css("div.roster__list").each do |section|
  position_group = section.at_css("h2")&.text&.strip

  section.css("div.roster__player").each do |player|
    name = player.at_css(".roster__player-name")&.text&.strip
    number = player.at_css(".roster__player-number")&.text&.strip
    pos = player.at_css(".roster__player-pos")&.text&.strip
    height = player.at_css(".roster__player-height")&.text&.strip
    weight = player.at_css(".roster__player-weight")&.text&.strip
    shoots = player.at_css(".roster__player-shoots")&.text&.strip
    birthplace = player.at_css(".roster__player-birthplace")&.text&.strip

    players << {
      full_name: name,
      jersey_number: number,
      position: pos || position_group,
      height: height,
      weight: weight,
      shoots_catches: shoots,
      birthplace: birthplace
    }
  end
end

File.write("swamp_roster.json", JSON.pretty_generate(players))
puts "✅ Roster saved to swamp_roster.json"
