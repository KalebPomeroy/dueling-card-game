require 'rubygems'
require 'active_support/core_ext/hash/indifferent_access'
require "yaml"
require 'RMagick'

#
# Pass an image name and a list of attributes. An attribute has [:text, :x, :y] and 
# optionally can have [:font_size, :container_height, :container_width, :centered, 
# :color ]. It creates a jpeg image in ./images/#{image_name}.jpg
#
def make_card(image_name, things_to_put_on_it, type=nil)    
    
    card = Magick::ImageList.new
    card.new_image(300, 400)
    
    background = Magick::Draw.new
    background.fill = "#EEE"

    background.roundrectangle(5,5,290,30,8,8)
    
    if type==:character
        background.roundrectangle(70,200,290,390,8,8)
    elsif type==:item
        background.roundrectangle(10,200,290,390,8,8)
    end
    background.draw(card)


    puts "Doing #{image_name}..."
    things_to_put_on_it.each do | thing |
        text = Magick::Draw.new
        text_x = (thing[:x] || 0)
        text_y = (thing[:y] || 0)
        rotation = (thing[:rotation] || 0)
        game_text =  (thing[:text])
        game_text = game_text.to_s
        game_text = " " if game_text == ""

        color = (thing[:color] || "black")
        container_width = (thing[:container_width] || 0)
        container_height = (thing[:container_height] || 0)
        
        text.pointsize = (thing[:font_size] || 14)    
        text.gravity = Magick::CenterGravity if thing[:centered]

        text.annotate(card, container_width, container_height, text_x, text_y, game_text) {
            self.fill = color
            self.rotation = rotation
        }
    end
    
    card.write("images/#{image_name}.jpg")    
end

def wordwrap(txt, col=28)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n") if txt
end

def get_helper(kw)
    return "(This skill can be triggered at any time)" if kw =="Interrupt"
# Level Up - Play a duplicate skill to get the next level effect
# Critical - When you activate this skill, discard a copy of the spell you are using: bonus
    return "(This skill cannot be executed from hand)\n " if kw=="Arcane"
    return "(This skill cannot be put into play from hand)\n " if kw=="Trickshot"
    return "(You may play an additional copy of this skill to gain a level)\n " if kw=="Level"

end

YAML::load(File.open('data/skills.yaml')).with_indifferent_access[:skills].each do | card | 

    things_to_add = [
            { :text => card[:name], :x => 70, :y => 25, :font_size => 20 },
            { :text => "Skill", :x => 250, :y => 45, :font_size => 15 },


            { :text => card[:cooldown], :x => 25, :y => 275, :font_size => 40, :color=>"#B0C4DE" },
            { :text => "(cooldown)", :x => 25, :y => 290, :font_size => 10 , :color=>"#B0C4DE"},

            { :text => card[:energy], :x => 25, :y => 325, :font_size => 40, :color=>"orange"},
            { :text => "(enery)", :x => 20, :y => 340, :font_size => 10 , :color=>"orange"},
            

        ]

    # loaded_keywords
    if(card[:loaded_keyword]) 
        if card[:loaded_keyword].is_a? Array
            helper = ""
            card[:loaded_keyword].each do | kw |
                if(card[:keywords])
                    card[:keywords] = card[:keywords] + " \u2022  " + kw
                else
                    card[:keywords] = kw
                end 
                helper = get_helper(kw) + helper
            end
        else
            if(card[:keywords])
                card[:keywords] = card[:keywords] + " \u2022  " + card[:loaded_keyword]
            else
                card[:keywords] = card[:loaded_keyword]
            end
            helper = get_helper(card[:loaded_keyword])
        end

        things_to_add << {:text => wordwrap(helper,33), :x => 100, :y => 345, :font_size => 12}
    end

    if(card[:levels])
        card[:text] = "Level One: "+card[:text]
        card[:levels].each_pair do |level, text|

            card[:text] += "\nLevel #{level}: #{text}"
        end
    end

    things_to_add << { :text => wordwrap(card[:keywords]), :container_width => 100, :x=>125, :container_height => 20, :y => 230, :centered =>true  }
    things_to_add << { :text => wordwrap(card[:text]), :container_width => 100, :x=>125, :container_height => 20, :y => 290, :centered =>true  }
    
    make_card(card[:name], things_to_add, :character)
        # levels
end

YAML::load(File.open('data/characters.yaml')).with_indifferent_access[:characters].each do | card | 

    full_text = wordwrap(card[:disadvantage])+ "\n" + wordwrap(card[:advantage])
    things_to_add = [
            { :text => card[:name], :x => 70, :y => 25, :font_size => 20 },

            { :text => card[:intelligence], :x => 25, :y => 225, :font_size => 40 , :color=>"blue"},
            { :text => "(intelligence)", :x => 4, :y => 240, :font_size => 10, :color=>"blue"},

            { :text => card[:luck], :x => 25, :y => 275, :font_size => 40, :color=>"green" },
            { :text => "(luck)", :x => 25, :y => 290, :font_size => 10 , :color=>"green"},

            { :text => card[:energy], :x => 25, :y => 325, :font_size => 40, :color=>"orange"},
            { :text => "(enery)", :x => 20, :y => 340, :font_size => 10 , :color=>"orange"},
            
            { :text => full_text, :x=>75, :y => 240  }
        ]
    make_card(card[:name], things_to_add, :character)
end
YAML::load(File.open('data/conditions.yaml')).with_indifferent_access[:conditions].each do | card | 

    things_to_add = [
            { :text => card[:name], :x => 70, :y => 25, :font_size => 20 },
            { :text => "Condition", :x => 210, :y => 45, :font_size => 15 },

            { :text => card[:cooldown], :x => 25, :y => 275, :font_size => 40, :color=>"#B0C4DE" },
            { :text => wordwrap(card[:keywords]), :container_width => 100, :x=>125, :container_height => 20, :y => 240, :centered =>true  },
            { :text => (card[:cooldown] ? "(cooldown)" : ""), :x => 25, :y => 290, :font_size => 10 , :color=>"#B0C4DE"},
            
            { :text => wordwrap(card[:text]), :container_width => 100, :x=>125, :container_height => 50, :y => 260, :centered =>true  },
        ]
    make_card(card[:name], things_to_add, :character)
end
YAML::load(File.open('data/items.yaml')).with_indifferent_access[:items].each do | card | 

    things_to_add = [
            { :text => card[:name], :x => 70, :y => 25, :font_size => 20 },
            { :text => "Item", :x => 250, :y => 45, :font_size => 15 },

            { :text => wordwrap(card[:type]), :container_width => 300, :container_height => 20, :y => 220, :centered =>true  },
            { :text => wordwrap(card[:keywords]), :container_width => 300, :container_height => 20, :y => 240, :centered =>true  },
            
            { :text => wordwrap(card[:text]), :container_width => 300, :container_height => 50, :y => 260, :centered =>true  },
        ]
    make_card(card[:name], things_to_add, :item)
end
