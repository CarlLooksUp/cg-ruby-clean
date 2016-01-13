#lib/inputs/button_radio_input.rb
class ButtonRadioInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input
    out = <<-HTML

  <div class="btn-group" data-toggle="buttons">
  HTML
    selected_value = object.send(attribute_name)
    input_field = @builder.hidden_field(attribute_name, input_html_options)
    input_id = input_field[/ id="(\w*)/, 1]
    input_name = input_field[/ name="(.*?)"/, 1]
    label_method, value_method = detect_collection_methods
    collection.each { |item|
      value = item.send(value_method)
      label = item.send(label_method)
      on_click = "document.getElementById('#{input_id}').value='#{value}';return false;"
      active = ''
      active = ' active' unless
        out =~ / active/ ||
        selected_value != value
      input_html_options[:value] = value unless active.empty?
      btn_style = 'btn-default'
      btn = 'btn'
      btn = "btn btn-#{item.third}" unless item.third.nil?
      out << <<-HTML
    <label class="#{btn} #{btn_style}#{active}" id="#{input_id}-#{value}">
      <input name="#{input_name}" type="radio" value="#{value}">#{label}</input>
    </label>
  HTML
    }
    value = <<-VAL
  value="#{input_html_options[:value]}"
  VAL

    input_field[/value="[^"]*"/] = value.chomp if input_field =~ /value/
    input_field[/input/] = "input #{value.chomp}" unless input_field =~ /value/
    out << <<-HTML
  </div>
  HTML
    out.html_safe
  end
end
