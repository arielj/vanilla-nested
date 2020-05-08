# frozen_string_literal: true

module VanillaNested
  module ViewHelpers
    # @param form [FormBuild] builder on a "form_for" block
    # @param association [Symbol] name of the association
    # @param container_selector [String] selector of the element to inser the fields
    # @param link_text [String, nil] text to use for the link tag
    # @param link_classes [String] space separated classes for the link tag
    # @param insert_method [:append, :prepend] tells javascript if the new fields should be appended or prepended to the container
    # @param partial_form_variable [String, Symbol] name of the variable that represents the form builder inside the fields partial
    # @param link_content [Block] block of code for the link content
    # @return [String] link tag
    def link_to_add_nested(form, association, container_selector, link_text: nil, link_classes: '', insert_method: :append, partial: nil, partial_form_variable: :form, &link_content)
      association_class = form.object.class.reflections[association.to_s].klass
      object = association_class.new

      partial_name = partial || "#{association_class.name.underscore}_fields"

      html = capture do
        form.fields_for association, object, child_index: '_idx_placeholder_' do |ff|
          render partial: partial_name, locals: { partial_form_variable => ff }
        end
      end

      method_for_insert = %i[append prepend].include?(insert_method.to_sym) ? insert_method : :append

      classes = "vanilla-nested-add #{link_classes}"
      data = {
        'container-selector': container_selector,
        'html': html,
        'method-for-insert': method_for_insert
      }

      nested_options = form.object.class.nested_attributes_options[association.to_sym]
      data['limit'] = nested_options[:limit] if nested_options[:limit]

      if block_given?
        link_to '#', class: classes, data: data, &link_content
      else
        text = link_text || "Add #{association_class.model_name}"
        link_to text, '#', class: classes, data: data
      end
    end

    # @param form [FormBuilder] builder on a "form_for" block
    # @param link_text [String, nil] text for the link, defaults to 'X'
    # @param fields_wrapper_selector [String] selector for the wrapper of the fields, must be an ancestor
    # @param undo_link_timeout [Integer] time until undo timeouts
    # @param undo_link_text [String] text to show as "undo"
    # @param undo_link_classes [String] space separated list of classes for the "undo" link
    # @param ulink_classes [String] space separated list of classes for the "x" link
    # @param link_content [Block] block of code for the link content
    # @return [String] hidden field and link tag
    def link_to_remove_nested(form, link_text: 'X', fields_wrapper_selector: nil, undo_link_timeout: nil, undo_link_text: 'Undo', undo_link_classes: '', link_classes: '', &link_content)
      data = {
        'fields-wrapper-selector': fields_wrapper_selector,
        'undo-timeout': undo_link_timeout,
        'undo-text': undo_link_text,
        'undo-link-classes': undo_link_classes
      }

      classes = "vanilla-nested-remove #{link_classes}"

      capture do
        concat form.hidden_field(:_destroy, value: 0)
        concat(
          if block_given?
            link_to('#', class: classes, data: data, &link_content)
          else
            link_to(link_text.html_safe, '#', class: classes, data: data)
          end
        )
      end
    end
  end
end
