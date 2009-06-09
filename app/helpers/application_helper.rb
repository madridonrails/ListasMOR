# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # The application logo as an image tag.
  def application_logo
    image_tag 'logo.png', :alt => local_text(:global,:logo_title), :title => local_text(:global,:logo_title)
  end
  
  # Returns the logo of the application already linked to the (public) home.
  def application_logo_linked_to_home
    link_to application_logo, '/'
  end
  
  def icon_with_text(icon,title,span_class='Title12Orange',show_title=true,size=nil,id=nil)
    options = {:alt=>title, :title=>title, :border=>0, :align=>'absmiddle', :size=>size}
    options.merge!(:id=>id) unless id.blank?
    image_tag_content=image_tag(icon, options)
    title='' if !show_title
    if span_class.nil?      
      "#{image_tag_content}#{show_title ? ('&nbsp;'+title) : ''}"
    else
      "#{image_tag_content}&nbsp;<span class='#{span_class}'>#{title}</span>"
    end    
  end
  
  # If the object has validation errors on method, returns the list of messages.
  # We prepend a BR to each error message and the list is wrapped in a SPAN with
  # class "error" and id "errors_for_object_method". If there's no error message
  # the SPAN is still returned so that it is available to Ajax forms.
  #
  # This helper is thought for displaying error messages below their corresponding
  # fields.
  #
  # The HTML is coupled with the one generated by create_for_invoice.rjs.
  def errors_for_attr(object, method)
    err_list = ''
    err = instance_variable_get("@#{object}").send(:errors).on(method)
    if err
      err = [err] if err.is_a?(String)
      err_list = %Q{<br />#{err.join("<br />")}}
    end
    return %Q(<span id="errors_for_#{object}_#{method}" class="error">#{err_list}</span>)
  end
  
  def label_for_attr(object,method,text,html_tag='strong')
    label_string="<label for='#{object.to_s}_#{method.to_s}'>_REPLACE_TEXT_</label>"
    text = "<#{html_tag}>#{text}</#{html_tag}>" unless html_tag.blank? 
    label_string.sub('_REPLACE_TEXT_',text)
  end
  
  def cloud_tags_and_classes(user_id=nil,tagging_type=nil) 
    classes=['Tag12Grey','Tag14Grey','Tag16Grey']
    class_obj = tagging_type.nil? ? TaskList : eval(tagging_type.to_s)
    all_tags = tagging_type.nil?
    
    tags=if user_id && logged_in?      
      current_user.send(class_obj.to_s.tableize).tag_counts(:limit=>TAGS_TO_SHOW,:all_tags=>all_tags,:order=>'count DESC')
    else  
      conditions=logged_in? ? "(public=1 OR user_id=#{current_user.id})" : "(public=1)"
      class_obj.tag_counts(:limit=>TAGS_TO_SHOW,:all_tags=>all_tags,:conditions=>conditions,:order=>'count DESC')
    end
    
    return if tags.nil? || tags.empty?
    max=tags.first.count
    min=tags.last.count
    divisor = ((max - min) / classes.size) + 1
    tags=tags.sort_by{|x| x.name}    
  
    tags.each { |t|
      yield t.name, classes[(t.count - min) / divisor]
    }   
    
  end
  
  # Renders the header of tables for listings, taking into account order and direction.
  # This helper had initially no embedded styles, but some CSS classes where added with
  # the final designs. Does not feel too clean but we will put them here by now.
  def table_header_remote(options)
    options = {
      :non_orderable     => [],
      :current_order_by  => @current_order_by,
      :current_direction => @current_direction
    }.merge(options)
    
    options[:url]    ||= {}
    options[:update] ||= 'list'
    html = '<tr class="table-row-head">'
    options[:labels].each_with_index do |label, c|
      html << '<td class="TextTable13White" nowrap="nowrap">'
      if options[:non_orderable].include?(c)
        html << label
      else
        options[:url][:order_by] = c
        icon = ''
        if c == options[:current_order_by]          
          options[:url][:direction] = (options[:current_direction] == 'ASC' ? 'DESC' : 'ASC')
        else
          options[:url][:direction] = 'ASC'
        end
        icon = '&nbsp;' + (options[:url][:direction] == 'ASC' ? image_tag('ico_arrow_up.png', :height => 11, :width => 11) : image_tag('ico_arrow_down.png', :height => 11, :width => 11))
        html << link_to_remote(
          "#{label}#{icon}",
          :update  => options[:update],
          :url     => options[:url]
        )
      end
      html << '</td>'
    end
    html << '</tr>'
    html
  end
  
  # Encapsulates the paid/unpaid toggler generation. If the current user has write
  # permissions the real toggler is returned, otherwise you get the corresponding
  # fake checkbox image, either checked or unchecked
  def user_admin_toggler(user)
    options = {:onclick => "new Ajax.Request('/users/toggle_admin_user/#{user.id}', {asynchronous:true, evalScripts:true})"}
    check_box_image(user.is_admin?, options)
  end
  
   # Returns the image we use as fake checkbox for toggling on lists
  def check_box_image(checked, options={})
    source = checked ? 'check_box_checked.png' : 'check_box_unchecked.png'
    image_tag(source, options)
  end
  

  def video_tag(filename, width, height, options={})
    if filename =~ /\.flv$/
      flash_video(filename, width, height, options)
    else
      quicktime_video(filename, width, height, options)
    end
  end

  # Based on the output of Pageot (http://www.qtbridge.com/pageot/pageot.html).
  def quicktime_video(filename, width, height, options={})
    url = "/videos/#{filename}"
    return <<-HTML
    <object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" width="#{width}" height="#{height}" codebase="http://www.apple.com/qtactivex/qtplugin.cab">
      <param name="src" value="#{url}" />
      <param name="controller" value="true" />
      <param name="autoplay" value="false" />
      <param name="showlogo" value="false" />
      <param name="cache" value="false" />
      <param name="href" value="#{url}" />
      <param name="SaveEmbedTags" value="true" />
      <embed
       src="#{url}"
       width="#{width}" height="#{height}"
       controller="true"
       autoplay="false"
       showlogo="false"
       cache="false"
       href="#{url}"
       SaveEmbedTags="true"
       type="video/quicktime"
       pluginspage="http://www.apple.com/quicktime/download/">
      </embed>
    </object>
    HTML
  end
  
  # Based on http://labnol.blogspot.com/2006/08/how-to-embed-flv-flash-videos-in-your.html.
  # We use the same stuff but put the player and the skin in our tree to avoid generating
  # traffic in the website pointed by the blog entry.
  def flash_video(filename, width, height, options={})
    url = CGI.escape("/videos/#{filename}")
    return <<-HTML
      <object width="#{width}" height="#{height}" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0">
        <param name="salign" value="lt">
        <param name="quality" value="high">
        <param name="scale" value="noscale">
        <param name="wmode" value="transparent"> 
        <param name="movie" value="/flash/flvplay.swf">
        <param name="FlashVars" value="&amp;streamName=#{h(url)}&amp;skinName=/flash/flvskin&amp;autoPlay=true&amp;autoRewind=false">
        <embed width="#{width}" height="#{height}" 
          flashvars="&amp;streamName=#{h(url)}&amp;autoPlay=true&amp;autoRewind=false&amp;skinName=/flash/flvskin"
          quality="high"
          scale="noscale"
          salign="LT"
          type="application/x-shockwave-flash"
          pluginspage="http://www.macromedia.com/go/getflashplayer"
          src="/flash/flvplay.swf"
          wmode="transparent">
        </embed>
      </object>
    HTML
  end
  
  # Returns a link to a hot editable template.
  def link_to_hot_editable(name, action, section=nil, html_options={})
    link_to(name, {:controller => 'public', :action => action, :section => section}, html_options)
  end
  
  def get_locked_icon(is_locked)
    image_tag(is_locked ? 'check_box_checked.png' : 'check_box_unchecked.png', :title=>local_html(:global,is_locked ? :unlock : :lock), :align=>'absmiddle')
  end

  def get_banner_partial_name(user)
    if user == :false || user.beruby_visited? || rand(2) == 0
      return 'google'
    else
      return 'beruby'
    end  
  end

end
