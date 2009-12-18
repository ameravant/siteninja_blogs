class CommentMailer < ActionMailer::Base

  def notification_to_author(comment, article)
    setup_email(article.person.email, "New comment posted in response to article: #{article.title}")
    body :comment => comment, :article => article
  end

  def notification_to_mentioned_commenter(comment, article, commenter)
    setup_email(commenter.email, "You were mentoned in a comment on the article: #{article.title}")
    body :comment => comment, :article => article, :commenter => commenter
  end

  
  private
  
  def setup_email(email, subject)
    cms_config ||= YAML::load_file("#{RAILS_ROOT}/config/cms.yml")
    recipients   email.strip
    from         "#{cms_config['website']['name']} <mailer@#{cms_config['website']['domain']}>"
    headers      'Reply-to' => "mailer@#{cms_config['website']['domain']}"
    subject      subject.strip
    sent_on      Time.now
  end

end
  