class FeedItem
  attr_accessor :title, :link, :description, :pubDate, :guid, :author, :isPermaLink
  
  def initialize    
    self.title=self.link=self.description=self.guid=self.author=nil
    self.isPermaLink=false
    self.pubDate=Time.now
  end
end