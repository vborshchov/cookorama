class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show, :search]
  before_filter :set_receipts, only:[:index, :search]

  def index
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
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
    @page.css('#pagination a').map {|a| a["href"] = a["href"].gsub("/receipts?", "/receipts/search?")}
    @quantity = @page.css('#content .block-nav li:first').text
    @right_menu = @page.css('#sidebar')
    @right_menu.css("script, .cl .cr h2").remove
    @selected_filters = @right_menu.css(".block-filter-selected").remove
    @selected_filters.css(".remove").remove
    # discard all filters link
    if @selected_filters.css("a span")[1] && @selected_filters.css("a span")[1].text =~ /відмінити/
      @selected_filters.css("a")[0]["href"] = "#{receipts_search_path}?link=#{@selected_filters.css('a')[0]['href'].gsub('?', '&')}"
    end
    # right sideabr filters links
    @right_menu.css(".filter-list ul li").each do |li|
      link_parameters = {}
      link_parameters[:filters] = {"blog": []}
      link_parameters[:filters][:blog] << li.css('a input')[0]['value']
      unless li.css("ul").length == 0
        li.css('ul input').each do |input|
          link_parameters[:filters][:blog] << input["value"]
        end
      end
      if params[:filters]
        link_parameters[:filters][:blog] |= params[:filters][:blog]
      end
      li.css("a")[0]["href"] = [receipts_search_path, params.merge(link_parameters).except("controller", "action").to_query].join("?")
    end

  end


  private

    def set_receipts
      @receipts = []
      @page.css(".topic").each do |topic|
        topic.css(".voting-border, .action").remove
        if topic.css(".topic-recipe")[0]
          topic.css(".topic-recipe")[0].name = "ul"
          topic.css(".topic-recipe")[0]["class"] = "topic-recipe small-block-grid-1 medium-block-grid-2"
          topic.css(".topic-recipe-content")[0].name = "li"
          topic.css(".topic-recipe-img")[0].name = "li"
          topic.css(".topic-recipe").children.last.add_next_sibling(topic.css(".topic-recipe-content"))
        end
        @receipts << topic.to_html.html_safe
      end
    end

    def set_page
      link = params[:link] =~ /\Ahttp:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      link_for_parse = "#{link}?#{params.reject{|e| e =~ /link|controller|action/ }.to_query}"
      link_for_parse = URI.escape(URI.unescape(link_for_parse))
      begin
        @page = Nokogiri::HTML(open(link_for_parse))
      rescue
        link_for_parse = URI.unescape(link_for_parse)
        puts link_for_parse.gsub!("search/topics/", "search/comments/")
        link_for_parse = URI.escape(URI.unescape(link_for_parse))
        @page = Nokogiri::HTML(open(link_for_parse))
      end
      @page.css(".topic a, .best-item a, #pagination a").map do |a|
        if a["href"] =~ /\.html\z/ && a["href"] =~ /\Ahttp:\/\/cookorama\.net/
          a["href"] = "#{receipts_show_path}?link=" + a["href"]
        else
          a["href"] = "#{receipts_path}?link=" + a["href"].gsub("?", "&")
        end
      end
      @title = @page.css(".title span").text
      @pagination = @page.css('#pagination')
    end

end