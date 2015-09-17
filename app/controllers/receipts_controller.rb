class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show, :search, :tag, :filter, :toggle_favorite]
  before_filter :set_receipts, only:[:index, :search, :tag, :filter]

  def index
    @page.search("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    @right_menu = @page.search("#block-best-topics")
    @right_menu.search(".best-item-r a:nth-child(2) ,.best-item-r a:nth-child(3)").remove
    @right_menu = "<li><label>Найкращі рецепти</label></li>
                   <ul class='tabs' data-tab>
                     <li class='tab-title active'><a href='#panel1'>#{@right_menu.search('.tabs li:nth-child(1)').text }</a></li>
                     <li class='tab-title'><a href='#panel2'>#{@right_menu.search('.tabs li:nth-child(2)').text }</a></li>
                     <li class='tab-title'><a href='#panel3'>#{@right_menu.search('.tabs li:nth-child(3)').text }</a></li>
                   </ul>
                   <div class='tabs-content'>
                     <div class='content active' id='panel1'>
                       #{@right_menu.search('.topics-week').to_html.html_safe }
                     </div>
                     <div class='content' id='panel2'>
                       #{@right_menu.search('.topics-month').to_html.html_safe }
                     </div>
                     <div class='content' id='panel3'>
                       #{@right_menu.search('.topics-total').to_html.html_safe }
                     </div>
                   </div>".html_safe
  end

  def show
    @page.search("#view-topic .content .clear").remove
    title        = @page.search("h1.title").text
    img          = @page.search("#topic-show-avatar").to_html.html_safe
    top_tags     = @page.search(".topic ul.tags.top-tags").to_html.html_safe
    tags         = @page.search("#view-topic ul.tags")[1].to_html.html_safe
    @ingredients = @page.search("table.ingredients .ingridient-group-title:first").remove
    @ingredients = @page.search("table.ingredients").to_html.html_safe
    content      = @page.search("#view-topic .content").to_html.html_safe
    @receipt = Receipt.new(
      title:       title,
      img:         img,
      top_tags:    top_tags,
      tags:        tags,
      ingredients: @ingredients,
      content:     content
    )
    @comments = @page.search(".comments>div[id^=comment_id_], .comments .header h3")
    @comments.search("a").each{|a| a["href"]="#"}
    @comments.search(".info ul li:nth-child(n+2)").remove
    @is_favorite = @page.search(".voting .favorite").first[:class]
    @id = @page.search(".voting .favorite a").first[:onclick].match(/\d+/)
  end

  def search
    @page.search('#pagination a').map {|a| a["href"] = a["href"].gsub("/receipts?", "/receipts/search?")}
    @quantity = @page.search('#content .block-nav li:first').text
    @right_menu = @page.search('#sidebar')
    @right_menu.search("script, .cl .cr h2").remove
    @selected_filters = @right_menu.search(".block-filter-selected").remove
    @selected_filters.search(".remove").remove
    # discard all filters link
    if @selected_filters.search("a span")[1] && @selected_filters.search("a span")[1].text =~ /відмінити/
      @selected_filters.search("a")[0]["href"] = "#{receipts_search_path}?link=#{@selected_filters.search('a')[0]['href'].gsub('?', '&')}"
    end
    # right sideabr filters links
    @right_menu.search(".filter-list ul li").each do |li|
      link_parameters = {}
      link_parameters[:filters] = {"blog": []}
      link_parameters[:filters][:blog] << li.search('a input')[0]['value']
      unless li.search("ul").length == 0
        li.search('ul input').each do |input|
          link_parameters[:filters][:blog] << input["value"]
        end
      end
      if params[:filters]
        link_parameters[:filters][:blog] |= params[:filters][:blog]
      end
      li.search("a")[0]["href"] = [receipts_search_path, params.merge(link_parameters).except("controller", "action").to_query].join("?")
    end
  end

  def tag
    @right_menu = @page.search('.block.tags').to_html.html_safe
  end

  def filter
    @selected_filters = {}
    @page.search("form .filter-item").each do |filter|
      filter.search("option").each {|opt| @selected_filters["#{filter['id']}"] = opt.text if (opt["selected"] && opt["value"]) }
    end
    @page.search('#sidebar form')[0].add_child("<input name='link' value='http://cookorama.net/uk/filter/' type='hidden'>")
    @right_menu = @page.search('#sidebar form')[0]["action"] = "#{receipts_filter_path}"
    @right_menu = @page.search('#sidebar form').to_html.html_safe
  end

  def toggle_favorite
    $agent.post("http://cookorama.net/include/ajax/topicFavourite.php?JsHttpRequest=14424838680402-xml",
      {
        "type": params[:active],
        "idTopic": params[:id],
        "security_ls_key": "0615666d9e39d12529e2daf383e4b97c",
        " family[name]": "hash",
      }
    )
  end
  private

    def set_receipts
      @receipts = []
      @page.search(".topic").each do |topic|
        voting_border = topic.search(".voting-border").first
        voting_border.css(".author a")[0]["href"] = "#"
        id = topic.search(".voting .favorite a").first[:onclick].match(/\d+/)
        is_active = @page.search(".voting .favorite").first[:class] =~ /active/ ? "0" : "1"
        topic.search(".voting-border .voting").first.add_child("<a href='#{receipts_toggle_favorite_path(id: id, active: is_active)}' data-remote='true' id='#{id}'><i class='fi-heart #{voting_border.css('li.favorite')[0]['class']}'></i></a>") unless session[:user].blank?
        if topic.search(".topic-recipe")[0]
          topic.search(".topic-recipe")[0].name = "ul"
          topic.search(".topic-recipe")[0]["class"] = "topic-recipe small-block-grid-1 medium-block-grid-2"
          topic.search(".topic-recipe-content")[0].name = "li"
          topic.search(".topic-recipe-img")[0].name = "li"
          topic.search(".topic-recipe").children.last.add_next_sibling(topic.search(".topic-recipe-content"))
        end
        topic.search(".voting-border .vt-block, li.favorite, .action").remove
        @receipts << topic.to_html.html_safe
      end
    end

    def set_page
      link = params[:link] =~ /\Ahttp:\/\/cookorama\.net/ && params[:link] || "http://cookorama.net"
      link_for_parse = "#{link}?#{params.reject{|e| e =~ /link|controller|action/ }.to_query}"
      link_for_parse = URI.escape(URI.unescape(link_for_parse))
      agent = $agent ? $agent : Mechanize.new
      begin
        @page = agent.get(link_for_parse)
      rescue
        link_for_parse = URI.unescape(link_for_parse)
        puts link_for_parse.gsub!("search/topics/", "search/comments/")
        link_for_parse = URI.escape(URI.unescape(link_for_parse))
        @page = agent.get(link_for_parse)
      end
      @page.search(".topic a, .best-item a, #pagination a, .cloud a").map do |a|
        if a["href"] =~ /\.html/ && a["href"] =~ /\Ahttp:\/\/cookorama\.net/
          a["href"] = "#{receipts_show_path}?link=" + a["href"]
        else
          case a["href"]
            when /\/tag\//
              a["href"] = "#{receipts_tag_path}?link=" + a["href"].gsub("?", "&")
            when /\/filter\//
              a["href"] = "#{receipts_filter_path}?link=" + a["href"].gsub("?", "&")
            else
              a["href"] = "#{receipts_path}?link=" + a["href"].gsub("?", "&")
          end
        end
      end
      @title = @page.search(".title span").text
      @pagination = @page.search('#pagination')
      session[:user] = @page.search("ul li.user-row .author").text
      @is_active = @page.search(".topic .voting .favorite").first[:class] =~ /active/ ? "0" : "1"
    end

end