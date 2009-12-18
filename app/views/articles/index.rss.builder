xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@cms_config['website']['name'])
    xml.link(articles_url(:format => :rss))
    # xml.description("")
    xml.language('en-us')

    for article in @articles
      xml.item do
        xml.title(h(article.title))
        xml.category(h(article.article_categories.first.name)) unless article.article_categories.empty?
        xml.description(h(article.blurb))
        xml.pubDate(article.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link(article_url(article))
        xml.guid(article_url(article))
      end
    end
  }
}
