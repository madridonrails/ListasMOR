# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# FIX: DoS vulnerabilities in REXML - http://feeds.feedburner.com/~r/RidingRails/~3/372559660/dos-vulnerabilities-in-rexml
require 'rexml-expansion-fix'

# Include your application configuration below
require File.join(RAILS_ROOT, 'config', 'local_config.rb')
require File.join(RAILS_ROOT, 'config', 'mailer.rb')
require File.join(RAILS_ROOT, 'lib', 'class_extensions.rb')
require File.join(RAILS_ROOT, 'lib', 'local_text_extensions.rb')
require File.join(RAILS_ROOT, 'lib', 'taggable_extensions.rb')

TagList.delimiter = ' '

module ActionView
  module Helpers
    # Provides a set of helpers for creating JavaScript macros that rely on and often bundle methods from JavaScriptHelper into
    # larger units. These macros also rely on counterparts in the controller that provide them with their backing. The in-place
    # editing relies on ActionController::Base.in_place_edit_for and the autocompletion relies on 
    # ActionController::Base.auto_complete_for.
    module JavaScriptMacrosHelper
      # DEPRECATION WARNING: This method will become a separate plugin when Rails 2.0 ships.
      #
      # Makes an HTML element specified by the DOM ID +field_id+ become an in-place
      # editor of a property.
      #
      # A form is automatically created and displayed when the user clicks the element,
      # something like this:
      #   <form id="myElement-in-place-edit-form" target="specified url">
      #     <input name="value" text="The content of myElement"/>
      #     <input type="submit" value="ok"/>
      #     <a onclick="javascript to cancel the editing">cancel</a>
      #   </form>
      # 
      # The form is serialized and sent to the server using an AJAX call, the action on
      # the server should process the value and return the updated value in the body of
      # the reponse. The element will automatically be updated with the changed value
      # (as returned from the server).
      # 
      # Required +options+ are:
      # <tt>:url</tt>::       Specifies the url where the updated value should
      #                       be sent after the user presses "ok".
      # 
      # Addtional +options+ are:
      # <tt>:rows</tt>::              Number of rows (more than 1 will use a TEXTAREA)
      # <tt>:cols</tt>::              Number of characters the text input should span (works for both INPUT and TEXTAREA)
      # <tt>:size</tt>::              Synonym for :cols when using a single line text input.
      # <tt>:cancel_text</tt>::       The text on the cancel link. (default: "cancel")
      # <tt>:save_text</tt>::         The text on the save link. (default: "ok")
      # <tt>:loading_text</tt>::      The text to display while the data is being loaded from the server (default: "Loading...")
      # <tt>:saving_text</tt>::       The text to display when submitting to the server (default: "Saving...")
      # <tt>:external_control</tt>::  The id of an external control used to enter edit mode.
      # <tt>:hide_controls</tt>::     The id of an element containing controls to hide
      # <tt>:invisible_controls</tt>::The id of an element containing controls to keep not visible after finishing
      # <tt>:load_text_url</tt>::     URL where initial value of editor (content) is retrieved.
      # <tt>:options</tt>::           Pass through options to the AJAX call (see prototype's Ajax.Updater)
      # <tt>:with</tt>::              JavaScript snippet that should return what is to be sent
      #                               in the AJAX call, +form+ is an implicit parameter
      # <tt>:script</tt>::            Instructs the in-place editor to evaluate the remote JavaScript response (default: false)
      # <tt>:click_to_edit_text</tt>::The text shown during mouseover the editable text (default: "Click to edit")
      def in_place_editor(field_id, options = {})
        function =  "new Ajax.InPlaceEditor("
        function << "'#{field_id}', "
        function << "'#{url_for(options[:url])}'"

        js_options = {}
        js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
        js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
        js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
        js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
        js_options['rows'] = options[:rows] if options[:rows]
        js_options['cols'] = options[:cols] if options[:cols]
        js_options['size'] = options[:size] if options[:size]
        js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
        js_options['hideControls'] = "'#{options[:hide_controls]}'" if options[:hide_controls]
        js_options['invisibleControls'] = "'#{options[:invisible_controls]}'" if options[:invisible_controls]
        js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]        
        js_options['ajaxOptions'] = options[:options] if options[:options]
        js_options['evalScripts'] = options[:script] if options[:script]
        js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
        js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
        function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
        
        function << ')'

        javascript_tag(function)
      end
      
    end
  end
end

