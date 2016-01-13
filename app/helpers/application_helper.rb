module ApplicationHelper
  
  #returns the page title based on input from template
  def full_title(page_title)
    base_title = "Cognate - Trademark Listing and Search"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  #create sortable column header
  def sortable(column, title=nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"

    link_to title, params.merge(:sort => column, :direction => direction, :page => nil)
  end

  #add protocol to url if not included
  def url_with_protocol(url)
    /^http/.match(url) ? url : "http://#{url}"
  end
end
