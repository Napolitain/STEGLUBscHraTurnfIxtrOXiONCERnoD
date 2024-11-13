class PageViewsController < ApplicationController
  # GET /page_views
  # @return Number of page views per URL, grouped by day, for the past 5 days;
  # { '2017-01-01' : [ { 'url': 'http://apple.com', 'visits': 100 } ] }
  def top_urls
    # Set the cutoff date to 5 days ago; I think it should eventually be querystring parameter
    cutoff_date = 5.days.ago.beginning_of_day

    # Group page views by day and URL, and count visits
    page_views_by_date = PageView
                           .where('viewed_at >= ?', cutoff_date) # Cutoff date
                           .group("date(viewed_at)", :url)
                           .order("date(viewed_at)", :url)
                           .pluck(Arel.sql("date(viewed_at) as date_day"), :url, Arel.sql("COUNT(*) as visits")) # Count + Date

    # Convert to the good format
    result = page_views_by_date.group_by { |date, _url, _visits| date }.each_with_object({}) do |(date, views), hash|
      # Format each date's views to match the desired structure
      hash[date.to_s] = views.map { |_, url, visits| { 'url' => url, 'visits' => visits } }
    end

    render json: result
  end

  # GET /top_referrers_for_top_urls
  # @return Top 5 referrers for the top 10 URLs grouped by day, for the past 5 days.
  # { '2017-01-01' : [ { 'url': 'http://apple.com', 'visits': 100, 'referrers': [ { 'url': 'http://store.apple.com/us', 'visits': 10 } ] } ] }
  def top_referrers
    # Set the cutoff date to 5 days ago; I think it should eventually be querystring parameter
    cutoff_date = 5.days.ago.beginning_of_day

    # Step 1: cutoff the data, and group by day, URL, and referrer
    top_referrers = PageView
                      .where("viewed_at >= ?", cutoff_date)
                      .select("DATE(viewed_at) AS day, url, referrer, COUNT(*) AS views")
                      .group("day, url, referrer")
                      .order("day DESC, url, views DESC")
                      .to_a

    # For each day
    output = top_referrers.group_by(&:day).transform_values do |records|
      # Get the top 10 URLs by total views
      top_urls = records.group_by(&:url)
                        .sort_by { |_, refs| -refs.sum(&:views) } # Sort by total views
                        .first(10) # Top 10 URLs

      # Build output for each top URL
      top_urls.map do |url, refs|
        {
          'url' => url,
          'visits' => refs.sum(&:views),
          'referrers' => refs.sort_by { |ref| -ref.views }
                             .first(5) # Top 5 referrers for each URL
                             .map { |ref| { 'url' => ref.referrer, 'visits' => ref.views } }
        }
      end
    end

    render json: output
  end
end
