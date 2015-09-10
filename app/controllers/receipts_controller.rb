class ReceiptsController < ApplicationController
  before_filter :set_page, only:[:index, :show, :search]
  before_filter :set_receipts, only:[:index, :search]

  def index
    @page.css("script, .topic-user-info, #ingridient-header, .share-buttons, .action, div[id^='div-gpt-ad'], .content>.clear>a").remove # remove all unneeded content
    case params[:link]
      when params[:link] && /\/index\/|\/blog\//
        @right_menu = @page.css("#block-best-topics")
        @right_menu.css(".best-item-r a:nth-child(2) ,.best-item-r a:nth-child(3)").remove
        @right_menu = "<li><label>Найкращі рецепти</label></li>
                       <ul class='tabs' data-tab>
                         <li class='tab-title active'><a href='#panel1'>#{@right_menu.css('.tabs li:nth-child(1)').text }</a></li>
                         <li class='tab-title'><a href='#panel2'>#{@right_menu.css('.tabs li:nth-child(2)').text }</a></li>
                         <li class='tab-title'><a href='#panel3'>#{@right_menu.css('.tabs li:nth-child(3)').text }</a></li>
                       </ul>
                       <div class='tabs-content'>
                         <div class='content active' id='panel1'>
                           #{@right_menu.css('.topics-week').to_html.html_safe }
                         </div>
                         <div class='content' id='panel2'>
                           #{@right_menu.css('.topics-month').to_html.html_safe }
                         </div>
                         <div class='content' id='panel3'>
                           #{@right_menu.css('.topics-total').to_html.html_safe }
                         </div>
                       </div>".html_safe
      when /\/tag\//
        @right_menu = @page.css('.block.tags').to_html.html_safe
      when /\/filter\//
        @right_menu = "<form action='http://cookorama.net/uk/filter/' method='get'>
                        <div id='speed' class='filter-item'>
                            <span class='speed'>Швидкість приготування</span>
                            <select name='blog[]' id='speed-select'>
                                <option selected='></option>
                                                <option value='987'>Дуже швидко (до 30 хвилин)</option>
                                                <option value='988'>Швидко (до 1 години)</option>
                                                <option value='989'>Нормально (до 3 годин)</option>
                                                <option value='990'>Довго (до 1 дня)</option>
                                                <option value='991'>Дуже довго (понад 1 дня)</option>
                                        </select>
                        </div>

                        <div id='difficulty' class='filter-item'>
                            <span class='difficulty'>Складність приготування</span>
                            <select name='blog[]' id='speed-difficulty'>
                                <option selected='></option>
                                                <option selected=' value='983'>Легко</option>
                                                <option value='984'>Нормально</option>
                                                <option value='985'>Важко</option>
                                        </select>
                        </div>

                        <div id='way' class='filter-item'>
                            <span class='way'>Спосіб приготування</span>
                            <select name='blog[]' id='speed-way'>
                                <option selected='></option>
                                                <option value='413'>Готуємо в горшочках</option>
                                                <option value='178'>Кулінарія в мікрохвильовці</option>
                                                <option value='35'>Страви для гриля, барбекю та мангалу</option>
                                                <option value='3133'>Рецепти для мультиварки</option>
                                                <option value='1031'>Без спеціального приготування</option>
                                                <option value='1027'>Рецепти для плити</option>
                                                <option value='1001'>Рецепти для духовки</option>
                                                <option value='1000'>Рецепти для пароварки</option>
                                                <option value='999'>Рецепти для хлібопічки</option>
                                                <option value='3520'>Рецепти для аерогрилю</option>
                                        </select>
                        </div>
                        <br>
                        <input value='Фільтрувати' class='left filter-button' type='submit'>
                    </form>".html_safe
      else
        @right_menu = @page.css('#sidebar')
    end

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

    def set_right_menu

    end

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
      @page.css(".topic a, .best-item a, #pagination a, .cloud a").map do |a|
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