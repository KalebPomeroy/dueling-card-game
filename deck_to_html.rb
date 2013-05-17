File.open("decks/#{ARGV[0]}.html", 'w') do |file|

    File.open("decks/#{ARGV[0]}.dek").each_line do | line | 
        count, card = line.split(" ",2)
        card.strip!
        count.to_i.times do 
            file.write "<img src=\"../images/#{card}.jpg\" style='border:1px solid #ccc; width:200px' />\n"
        end
    end
end