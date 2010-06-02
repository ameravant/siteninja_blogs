xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@cms_config['website']['name'])
    xml.link(article_category_url(@article_category, :format => :rss))
    # xml.description("")
    xml.language('en-us')

    for article in @articles
      xml.item do
        xml.title(h(article.title))
        xml.author(h(article.person.name))
        xml.category(h(@article_category.name))
        xml.description(h(article.blurb))
        xml.pubDate(article.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link(article_url(article))
        xml.guid(article_url(article))
      end
    end
  }
}
