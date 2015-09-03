module ApplicationHelper

  def left_menu
    page = Nokogiri::HTML(open("http://cookorama.net/uk/"))
    menu = Nokogiri::HTML::DocumentFragment.parse(page.css('.menutree').to_s)
    menu.css('.menutree div').remove
    menu.css('.show_more').remove
    menu.css('li > ul').each {|ul| ul['class'] = "left-submenu"}
    menu.css('li').each do |li|
      li.at_css('a')['href'] = "/receipts/?link=#{li.at_css('a')['href']}" unless li.at_css('a')['href'] == "#"
      unless li.at_css("ul").nil?
        li['class'] = "has-submenu"
        li.at_css("ul").children.first.add_previous_sibling("<li class='back'><a href='#'>Back</a></li>")
      end
    end
    menu.css('.menutree > ul > li').to_html
  end

end
