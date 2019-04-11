module VanillaNested
  module ViewHelpers
    def link_to_add_nested(form, association, container_selector, link_text: nil, link_classes: '', insert_method: :append, partial: nil, partial_form_variable: :form)
      association_class = form.object.class.reflections[association.to_s].klass
      object = association_class.new

      partial_name = partial ? partial : "#{association_class.name.downcase}_fields"

      html = capture do
        form.fields_for association, object, child_index: "_idx_placeholder_" do |ff|
          render partial: partial_name, locals: {partial_form_variable => ff}
        end
      end

      methodForInsert = [:append, :prepend].include?(insert_method.to_sym) ? insert_method : :append

      classes = "vanilla-nested-add #{link_classes}"
      link_to '#', class: classes, data: {'container-selector': container_selector, html: html, 'method-for-insert': methodForInsert} do
        link_text || "Add #{association_class.model_name}"
      end
    end

    def link_to_remove_nested(form, link_text: 'X', fields_wrapper_selector: nil, undo_link_timeout: nil, undo_link_text: 'Undo', undo_link_classes: '')
      capture do
        concat form.hidden_field(:_destroy, value: 0)
        concat link_to(link_text, '#', class: 'vanilla-nested-remove', data: {'fields-wrapper-selector': fields_wrapper_selector, 'undo-timeout': undo_link_timeout, 'undo-text': undo_link_text, 'undo-link-classes': undo_link_classes})
      end
    end
  end
end