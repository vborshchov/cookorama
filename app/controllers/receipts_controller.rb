class ReceiptsController < ApplicationController

  def index
    params[:link] ||= "http://cookorama.net"
    if params[:link] =~ /^http:\/\/cookorama\.net/
      page = Nokogiri::HTML(open(params[:link]))
      @receipts = []
      page.css('.topic').each_with_index do |t, index|
        t.css('.voting-border').remove
        t[:id] = "to-top" if index == 0
        @receipts << t.to_html
      end
    end
  end

  def show

  end

  # private

  #   def receipt_params
  #     params.require(:receipt).permit(:title, :description, :link, :due_date, :active)
  #   end

end
