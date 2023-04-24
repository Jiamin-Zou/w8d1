require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)

    @req = req
    @res = res

  end

  # Helper method to alias @already_built_response
  def already_built_response?

    @already_built_response ||= false

    
  end

  # Set the response status code and header
  def redirect_to(url)

    raise "already rendered" if @already_built_response

    @res.status = 302 
    @res["Location"] = url
    @already_built_response = true
    nil


  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)

    raise "already rendered" if @already_built_response

    @res.write(content)
    @res["Content-Type"] = content_type
    @already_built_response = true
    nil

  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)

    raise "already rendered" if @already_built_response

    controller_name = self.to_s

    array = []

    template_path = ['views', controller_name, "#[template_name}.html.erb"].join("/")    
    
    template = ERB.new(File.read(template_path))

    #render the template the the current binding 
    html = template.result(binding)

    #pass the HTML to the render content method 

    render_content(html, 'text/html')

    @already_built_response = true

  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

