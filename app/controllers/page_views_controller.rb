class PageViewsController < ApplicationController
  # GET /page_views
  # @return Number of page views per URL, grouped by day, for the past 5 days;
  # { '2017-01-01' : [ { 'url': 'http://apple.com', 'visits': 100 } ] }
  def top_urls
    result = PageView
               .where('viewed_at >= ?', 5.days.ago.beginning_of_day)
               .group("DATE(viewed_at), url")
               .order("DATE(viewed_at) DESC")
               .count

    render json: result
  end

  # GET /top_referrers_for_top_urls
  # @return Top 5 referrers for the top 10 URLs grouped by day, for the past 5 days.
  # { '2017-01-01' : [ { 'url': 'http://apple.com', 'visits': 100, 'referrers': [ { 'url': 'http://store.apple.com/us', 'visits': 10 } ] } ] }
  def top_referrers
    top_urls = PageView
                 .where('viewed_at >= ?', 5.days.ago.beginning_of_day)
                 .group(:url)
                 .order('count_id DESC')
                 .limit(10)
                 .count(:id)
                 .keys

    result = PageView
               .where(url: top_urls)
               .where('viewed_at >= ?', 5.days.ago.beginning_of_day)
               .group("DATE(viewed_at), url, referrer")
               .order("DATE(viewed_at) DESC")
               .count

    render json: result
  end
end
