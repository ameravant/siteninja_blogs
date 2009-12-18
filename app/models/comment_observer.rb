class CommentObserver < ActiveRecord::Observer

  def after_create(comment)
    article = comment.article
    
    # Send notification to the blog author that a new comment was posted
    CommentMailer.deliver_notification_to_author(comment, article) if article.notify_author_of_comments?

    # Check if this commenter mentioned another poster by name.
    # If so, notify the mentioned person via email, if possible.
    name_mentions = comment.comment.match(/^([^:]+):\s/).to_a # "Bob: bla bla bla" --> "Bob"
    unless name_mentions.empty?
      # A name was mentioned, so find comments by anyone matching that name.
      mentioned_commenters = comment.article.comments.find_all_by_name(name_mentions[1].strip)
      unless mentioned_commenters.empty?
        for commenter in mentioned_commenters.reject { |commenter| commenter.email.blank? }
          CommentMailer.deliver_notification_to_mentioned_commenter(comment, article, commenter) rescue nil
        end
      end
    end

  end # after_save

end
