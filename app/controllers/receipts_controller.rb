class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show]

  def index
    @receipts = []
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    @page.css(".topic").each_with_index do |t, index|
      t.css(".voting-border").remove
      t[:id] = "to-top" if index == 0
      @receipts << t.to_html
    end
    @pagination = @page.css('#pagination').to_html

    # right menu
    @right_menu =  if @page.css('.topic-ingridients-table').empty?
                    right_menu = Nokogiri::HTML::DocumentFragment.parse(@page.css('#block-best-topics').to_s)
                    (
                        "<li><label>Найкращі рецепти</label></li>" +
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

  def show
    @page.css('#view-topic .content .clear').remove
    title        = @page.css('h1.title').text
    img          = @page.css('#topic-show-avatar').to_html.html_safe
    top_tags     = @page.css('.topic ul.tags.top-tags').to_html.html_safe
    tags         = @page.css('#view-topic ul.tags')[1].to_html.html_safe
    @ingredients = @page.css('table.ingredients').to_html.html_safe
    content      = @page.css('#view-topic .content').to_html.html_safe
    @receipt = Receipt.new(
      title:       title,
      img:         img,
      top_tags:    top_tags,
      tags:        tags,
      ingredients: @ingredients,
      content:     content
    )
  end

  def tag

  end

  def ingredient

  end

  private

    def set_search_params
      page = Nokogiri::HTML(open("http://cookorama.net/uk/ingredients"))
      @ingredients = page.css('.ingridients-list ')
    end

    def set_page
      link = params[:link] =~ /^http:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      # This code below is the same as line above
      # link = if params[:link] =~ /^http:\/\/cookorama\.net/
      #           params[:link]
      #         else
      #           "http://cookorama.net"
      #         end
      link = URI::escape(link)
      @page = Nokogiri::HTML(open(link))
      @page.css("a").map do |a|
        if a["href"] =~ /\.html\z/
          a["href"] = "/receipts/show?link=" + a["href"].to_s
        else
          a["href"] = "/receipts/?link=" + a["href"].to_s
        end
      end
      @title = @page.css(".title span").text
    end

end
