require 'nokogiri'
require 'open-uri'
require 'json'

url = "https://swamprabbits.com/team/roster"
doc = Nokogiri::HTML(URI.open(url))

players = []

# Each player is in a <tr> with multiple <td> cells
doc.css("tr").each do |row|
  cells = row.css("td")
  next if cells.empty?

  # First cell contains link, image, name, and jersey number
  link = cells[0].at_css("a")&.[]("href")
  img  = cells[0].at_css("img")&.[]("src")
  name = cells[0].at_css("span")&.text&.strip
  number = cells[0].at_css(".text-secondary")&.text&.strip&.delete("#")

  # Remaining cells: position, height, weight, shoots/catches, birthplace
  pos        = cells[1]&.text&.strip
  height     = cells[2]&.text&.strip
  weight     = cells[3]&.text&.strip
  shoots     = cells[4]&.text&.strip
  birthplace = cells[5]&.text&.strip

  # Skip header rows or empty rows
  next unless name && number

  players << {
    full_name: name,
    jersey_number: number,
    position: pos,
    height: height,
    weight: weight,
    shoots_catches: shoots,
    birthplace: birthplace,
    headshot: img,
    profile_url: link
  }
end

File.write("swamp_roster.json", JSON.pretty_generate(players))
puts "✅ Roster saved to swamp_roster.json"
