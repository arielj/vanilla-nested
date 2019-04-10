require 'vanilla_nested/view_helpers'

module VanillaNested
  class Engine < ::Rails::Engine
    initializer "vanilla_nested.initialize" do |app|
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, VanillaNested::ViewHelpers
      end
    end
  end
end