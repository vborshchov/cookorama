class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show, :search]

  def index
    @receipts = []
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    @page.css(".topic").each_with_index do |topic, index|
      topic.css(".voting-border").remove
      @receipts << topic.to_html
    end
    # @pagination = @page.css('#pagination').to_html

    # right menu
    @right_menu = Nokogiri::HTML::DocumentFragment.parse(@page.css('#block-best-topics').to_s)
    @right_menu.css('.best-item-r a:nth-child(2) ,.best-item-r a:nth-child(3)').remove
  end

  def show
    @page.css('#view-topic .content .clear').remove
    title        = @page.css('h1.title').text
    img          = @page.css('#topic-show-avatar').to_html.html_safe
    top_tags     = @page.css('.topic ul.tags.top-tags').to_html.html_safe
    tags         = @page.css('#view-topic ul.tags')[1].to_html.html_safe
    @ingredients = @page.css('table.ingredients .ingridient-group-title:first').remove
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

  def search
    @receipts = []
    # link = URI::escape("#{params[:link]}?q=#{params[:q]}")
    # page = Nokogiri::HTML(open(link))
    # @page.css(".topic a").map do |a|
    #   if a["href"] =~ /\.html\z/
    #     a["href"] = "/receipts/show?link=" + a["href"].to_s
    #   else
    #     a["href"] = "/receipts/?link=" + a["href"].to_s
    #   end
    # end
    @page.css("#pagination a").map {|a| a["href"] = "/receipts/search?link=" + a["href"].to_s[/.+(?=\?)/] + "&q=" + "#{params[:q]}" }
    @page.css(".topic").each do |topic|
      topic.css(".voting-border, .action").remove
      @receipts << topic.to_html.html_safe
    end
    # @pagination = @age.css('#pagination').to_html
  end

  def tag

  end

  def ingredient

  end

  private

    # def set_search_params
    #   page = Nokogiri::HTML(open("http://cookorama.net/uk/ingredients"))
    #   @ingredients = page.css('.ingridients-list ')
    # end

    def set_page
      link = params[:link] =~ /^http:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      # This code below is the same as line above
      # link = if params[:link] =~ /^http:\/\/cookorama\.net/
      #           params[:link]
      #         else
      #           "http://cookorama.net"
      #         end
      link = URI::escape("#{link}?q=#{params[:q]}")
      # link = URI::escape(link)
      @page = Nokogiri::HTML(open(link))
      @page.css(".topic a").map do |a|
        if a["href"] =~ /\.html\z/
          a["href"] = "/receipts/show?link=" + a["href"].to_s
        else
          a["href"] = "/receipts/?link=" + a["href"].to_s
        end
      end
      @title = @page.css(".title span").text
      @pagination = @page.css('#pagination').to_html
    end

end
