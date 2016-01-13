# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # you need an updated simple_form gem for this to work, I'm referring to the git repo in my Gemfile
  config.input_class = "form-control"
  
  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'col-md-6' do |inner|
      inner.use :input
      inner.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
      inner.use :hint, wrap_with: { tag: 'span', class: 'help-block' }
    end
    b.use :tooltip
  end
   
   config.wrappers :group, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
     b.use :html5
     b.use :placeholder
     b.use :label
     b.use :input, wrap_with: { class: "input-group" }
     b.use :hint, wrap_with: { tag: 'span', class: 'help-block' }
     b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
   end
    
  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
