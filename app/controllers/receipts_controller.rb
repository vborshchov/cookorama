class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show, :search]

  def index
    @receipts = []
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    @page.css(".topic").each do |topic|
      topic.css(".voting-border").remove
      @receipts << topic.to_html
    end
    @right_menu = @page.css("#block-best-topics")
    @right_menu.css(".best-item-r a:nth-child(2) ,.best-item-r a:nth-child(3)").remove
  end

  def show
    @page.css("#view-topic .content .clear").remove
    title        = @page.css("h1.title").text
    img          = @page.css("#topic-show-avatar").to_html.html_safe
    top_tags     = @page.css(".topic ul.tags.top-tags").to_html.html_safe
    tags         = @page.css("#view-topic ul.tags")[1].to_html.html_safe
    @ingredients = @page.css("table.ingredients .ingridient-group-title:first").remove
    @ingredients = @page.css("table.ingredients").to_html.html_safe
    content      = @page.css("#view-topic .content").to_html.html_safe
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
    @page.css('#pagination a').map {|a| a["href"] = a["href"].gsub("/receipts?", "/receipts/search?")}
    @page.css(".topic").each do |topic|
      topic.css(".voting-border, .action").remove
      @receipts << topic.to_html.html_safe
    end
    @quantity = @page.css('#content .block-nav li:first').text
    @right_menu = @page.css('#sidebar')
    @right_menu.css("script, .cl .cr h2").remove
    @selected_filters = @right_menu.css(".block-filter-selected").remove
    # @right_menu.css(".filter-list ul li").each do |li|
    #   filters = "&filters[blog][]=#{li.css('a input')[0]['value']}"
    #   unless li.css("ul").empty?
    #     values = []
    #     li.css('ul input').each do |input|
    #       values << input["value"]
    #     end
    #     values.join("&filters[blog][]=")
    #     filters += "&filters[blog][]=" + values.join("&filters[blog][]=")
    #   end
    #   li.css("a")[0]["href"] = "#{receipts_search_path}?q=#{params[:q]}&link=#{params[:link]}#{filters}"
    # end
    @right_menu.css(".filter-list ul li").each do |li|
      unless li.css("ul").empty?
        params.merge("filters" => "blog")
        puts params
        li.css('ul input').each do |input|
          input["value"]
        end
      end
      li.css("a")[0]["href"] = [receipts_search_path, params.except("controller", "action").to_query].join("?")
    end

  end

  private

    def set_page
      link = params[:link] =~ /\Ahttp:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      link_for_parse = "#{link}?#{params.reject{|e| e =~ /link|controller|action/ }.to_query}"
      @page = Nokogiri::HTML(open(link_for_parse))
      @page.css(".topic a, .best-item a, #pagination a").map do |a|
        if a["href"] =~ /\.html\z/ && a["href"] =~ /\Ahttp:\/\/cookorama\.net/
          a["href"] = "#{receipts_show_path}?link=" + a["href"]#.split(/\?/).join("&")
        else
          a["href"] = "#{receipts_path}?link=" + a["href"].split(/\?/).join("&")
        end
      end
      @title = @page.css(".title span").text
      @pagination = @page.css('#pagination')
    end

end