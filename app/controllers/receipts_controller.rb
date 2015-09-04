class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index]

  def index
    @receipts = []
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    @page.css("a").map { |a| a["href"] = "/receipts/?link=" + a["href"].to_s}
    @page.css(".topic").each_with_index do |t, index|
      t.css(".voting-border").remove
      t[:id] = "to-top" if index == 0
      @receipts << t.to_html
    end
    @pagination = @page.css('#pagination').to_html

    # right menu
    @right_menu =  if @page.css('.topic-ingridients-table').empty?
                    right_menu = Nokogiri::HTML::DocumentFragment.parse(@page.css('#block-best-topics').to_s)
                    ( "<li><label>Найкращі рецепти</label></li>" +
                      "<ul class='tabs' data-tab>
                        <li class='tab-title active'><a href='#panel1'>#{right_menu.css('.tabs li:nth-child(1)').text}</a></li>
                        <li class='tab-title'><a href='#panel2'>#{right_menu.css('.tabs li:nth-child(2)').text}</a></li>
                        <li class='tab-title'><a href='#panel3'>#{right_menu.css('.tabs li:nth-child(3)').text}</a></li>
                      </ul>
                      <div class='tabs-content'>
                        <div class='content active' id='panel1'>
                          #{right_menu.css('.topics-week').to_html}

                        </div>
                        <div class='content' id='panel2'>
                          #{right_menu.css('.topics-month').to_html}
                        </div>
                        <div class='content' id='panel3'>
                          #{right_menu.css('.topics-total').to_html}
                        </div>
                      </div>"
                    ).html_safe
                  else
                    right_menu = Nokogiri::HTML::DocumentFragment.parse(@page.css('.topic-ingridients-table').to_s)
                    ( "<li><label>Інгредієнти</label></li>" +
                      "#{right_menu.css('.ingredients').to_html}"
                    ).html_safe
                  end

  end

  private

    def set_page
      link = params[:link] =~ /^http:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      # This code below is the same as line above
      # link = if params[:link] =~ /^http:\/\/cookorama\.net/
      #           params[:link]
      #         else
      #           "http://cookorama.net"
      #         end
      puts link
      link = URI::escape(link)
      puts link
      @page = Nokogiri::HTML(open(link))
      @title = @page.css(".title span").text
    end

end
