require 'net/http'
require 'json'


class RedditScraper
  def initialize(subreddit)
    @subreddit = subreddit
  end

  def scrape
    uri = URI("https://www.reddit.com/r/#{@subreddit}/.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    # request['Authorization'] = "Bearer #{@access_token}"
    # request['Authorization'] = "Bearer LyMWe3PpoPM9_bVNJdvdrA"
    request['User-Agent'] = "Ali Ahmad"

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      extract_posts(data)
    else
      # Print the full response for debugging purposes
      puts "Failed to fetch data from Reddit. Status code: #{response.code}"
      puts "Response body: #{response.body}"
      []
    end
  rescue StandardError => e
    # Print the exception message and backtrace for debugging purposes
    puts "An error occurred while fetching data from Reddit: #{e.message}"
    puts e.backtrace.join("\n")
    []
  end


  private

  def extract_posts(data)
    posts = []
    data['data']['children'].each do |child|
      post_data = child['data']
      title = post_data['title']
      url = post_data['url']
      flair = post_data['link_flair_text'] || 'No flair'
      body = post_data['selftext']
      description = post_data['selftext_html'] # This field might contain HTML
      creation_date = Time.at(post_data['created_utc'])

      flairs = ["Science", "Experience", "Question", "General", "Questions"].freeze
      # Check if post is within the last 24 hours
      next unless (creation_date >= 24.hours.ago && flairs.include?(flair))

        posts << {
          title: title,
          url: url,
          flair: flair,
          body: body,
          description: description,
          creation_date: creation_date
        }
    end
    posts
  end
end
