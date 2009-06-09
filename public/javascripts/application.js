// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function ajax_submit_on_enter(my_field,e)
{	
var keycode;
if (window.event) keycode = window.event.keyCode;
else if (e) keycode = e.which;
else return true;

if (keycode == 13)
   {
   my_field.form.onsubmit();
   return false;
   }
else
   return true;
}

Ajax.InPlaceEditor.prototype.initialize=
function(element, url, options) {
  this.url = url;
  this.element = $(element);

  this.options = Object.extend({
    paramName: "value",
    okButton: true,
    okText: "ok",
    cancelLink: true,
    cancelText: "cancel",
    savingText: "Saving...",
    clickToEditText: "Click to edit",
    okText: "ok",
    rows: 1,
    onComplete: function(transport, element) {
      new Effect.Highlight(element, {startcolor: this.options.highlightcolor});
    },
    onFailure: function(transport) {
      alert("Error communicating with the server: " + transport.responseText.stripTags());
    },
    callback: function(form) {
      return Form.serialize(form);
    },
    handleLineBreaks: true,
    loadingText: 'Loading...',
    savingClassName: 'inplaceeditor-saving',
    loadingClassName: 'inplaceeditor-loading',
    formClassName: 'inplaceeditor-form',
    highlightcolor: Ajax.InPlaceEditor.defaultHighlightColor,
    highlightendcolor: "#FFFFFF",
    externalControl: null,
	hideControls: null,
	invisibleControls: null,
    submitOnBlur: false,
    ajaxOptions: {},
    evalScripts: false
  }, options || {});

  if(!this.options.formId && this.element.id) {
    this.options.formId = this.element.id + "-inplaceeditor";
    if ($(this.options.formId)) {
      // there's already a form with that name, don't specify an id
      this.options.formId = null;
    }
  }
  
  if (this.options.externalControl) {
    this.options.externalControl = $(this.options.externalControl);
  }
  
  this.originalBackground = Element.getStyle(this.element, 'background-color');
  if (!this.originalBackground) {
    this.originalBackground = "transparent";
  }
  
  this.element.title = this.options.clickToEditText;
  
  this.onclickListener = this.enterEditMode.bindAsEventListener(this);
  this.mouseoverListener = this.enterHover.bindAsEventListener(this);
  this.mouseoutListener = this.leaveHover.bindAsEventListener(this);
  Event.observe(this.element, 'click', this.onclickListener);
  Event.observe(this.element, 'mouseover', this.mouseoverListener);
  Event.observe(this.element, 'mouseout', this.mouseoutListener);
  if (this.options.externalControl) {
    Event.observe(this.options.externalControl, 'click', this.onclickListener);
    Event.observe(this.options.externalControl, 'mouseover', this.mouseoverListener);
    Event.observe(this.options.externalControl, 'mouseout', this.mouseoutListener);
  }
}

Ajax.InPlaceEditor.prototype.onEnterEditMode= 
function() {
  if (this.options.hideControls) {
	Element.hide(this.options.hideControls)
  }
  return false;
}

Ajax.InPlaceEditor.prototype.onLeaveEditMode= 
function() {
  if (this.options.hideControls) {
	Element.show(this.options.hideControls)
  }
  if (this.options.invisibleControls) {
	$(this.options.invisibleControls).style.visibility='hidden'
  }
  return false;
}
