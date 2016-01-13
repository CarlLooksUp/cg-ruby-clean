module SimpleForm
  module Components
    module Tooltip
      def tooltip
        if options[:tooltip].present?
          tooltip = options[:tooltip]
          tooltip_content = tooltip.is_a?(String) ? tooltip : ''
          tooltip_content.html_safe if tooltip_content

          template.content_tag(:span, :class => 'help-inline') do
            template.content_tag(:span, '',
                                 :class => 'glyphicon glyphicon-question-sign form-tooltip-icon',
                                 :title => tooltip_content,
                                 :"data-toggle" => 'tooltip',
                                 :"data-html" => 'true',
                                 :"data-placement" => 'right')
          end
        end
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Tooltip)
