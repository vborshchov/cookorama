class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show, :search]
  before_filter :right_sidebar, only:[:index, :show, :search]

  def index
    @receipts = []
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    @page.css(".topic").each do |topic|
      topic.css(".voting-border").remove
      @receipts << topic.to_html
    end
    @right_menu = @page.css('#block-best-topics')
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
    puts @page.css("#pagination a").map {|a| a["href"] = "/receipts/search?link=" + a["href"].to_s[/.+(?=\?)/] + "&q=" + "#{params[:q]}" }
    @page.css(".topic").each do |topic|
      topic.css(".voting-border, .action").remove
      @receipts << topic.to_html.html_safe
    end
    @quantity = @page.css('#content .block-nav li:first').text
  end

  def tag

  end

  def ingredient

  end

  private

    def set_page
      link = params[:link] =~ /\Ahttp:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      link = URI::escape("#{link}?q=#{params[:q]}")
      @page = Nokogiri::HTML(open(link))
      @page.css(".topic a, .best-item a, #pagination a").map do |a|
        if a["href"] =~ /\.html\z/ && a["href"] =~ /\Ahttp:\/\/cookorama\.net/
          a["href"] = "/receipts/show?link=" + a["href"].to_s
        else
          a["href"] = "/receipts/?link=" + a["href"].to_s
        end
      end
      @title = @page.css(".title span").text
      @pagination = @page.css('#pagination')
    end

    def right_sidebar
      @right_sidebar = @page.css('#sidebar')
      @right_sidebar.css('script, .cl .cr h2').remove
    end
end
