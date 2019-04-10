# vanilla-nested
Rails dynamic nested forms using vanilla JS

Similar to cocoon, but with no jquery dependency!

# Installation
For now, it can only be used from github

```gem 'vanilla_nested', git: 'https://github.com/arielj/vanilla-nested', branch: 'master'```

If you already have it installed and need to update it, run `bundle update --source vanilla_nested`.

# Usage

``` HTML+ERB
# orders/_order_item_fields.html.erb
<div class="wrapper-div">
  <%= form.text_field :attr1 %>
  <%= form.select :attr2 ..... %>
  <%= link_to_remove_nested(form) # adds a link to remove the element %>
</div>
```

``` HTML+ERB
# order/form.html.erb
<%= form_for product do |form| %>
  <%= form.text_field :attr %>
  
  <%= link_to_add_nested(form, :order_items, '#order-items') # adds a link to add more items %>
  <div id='order-items'>
    <%= f.fields_for :order_items do |order_item_f| %>
      <%= render 'order_item_fields', form: order_item_f %>
    <% end %>
  </div>
<% end %>
```

Note that:
- `link_to_remove_nested` receives the nested form as a parameter, it adds a hidden `[_destroy]` field
- Nested fields have to be grouped with a container div element and `link_to_remove_nested` must be a direct children! TODO: make it customizable
- `link_to_add_nested` expects the form builder, the name of the association and the selector of the container where the gem will insert the new fields

# Customizing link_to_add_nested
* Link text
The default value is "Add <name of the model associated", but it can be changed using the parameter `link_text`

``` Ruby
link_to_add_nested(form, :order_items, '#order-items', link_text: I18n.t(:some_key))
```
This way you can, for example, internationalize the text.

* Link class
By default, the link to add new fields has the class `vanilla-nested-add` which is required, but you can add more classes passing a string
``` Ruby
link_to_add_nested(form, :order_items, '#order-items', link_classes: 'btn btn-primary')
```
This way you can style the link with no need of targeting the specific vanilla nested class.

* Insert position
By default, new fields are appended to the container, you can chage that with the `insert_method` option. For now, only `:append` and `:prepend` are supported
``` Ruby
link_to_add_nested(form, :order_items, '#order-items', insert_method: :prepend)
```

* Partial name
The default partial's name is infered using the association's class name. If your Order has_many :order_items and the class of those items is OrderItem, then the infered name is `_order_item_fields`. You can use any partial name you like though:
``` Ruby
link_to_add_nested(form, :order_items, '#order-items', partial: '_my_partial')
```

* Form variable used in the partial
`link_to_add_nested` needs to render an empty template in order to later append/prepend it. To do that, it need to render the partial and pass the form as a local variable. If your partial uses `form`, you don't have to do anything, but if you using another variable name, just customize it here.

``` HTML+ERB
# orders/_order_item_fields.html.erb
<div class="wrapper-div">
  <%= ff.text_field :attr1 %>
  <%= ff.select :attr2 ..... %>
  <%= link_to_remove_nested(ff) # adds a link to remove the element %>
</div>
```

``` Ruby
link_to_add_nested(form, :order_items, '#order-items', partial_form_variable: :ff)
```

# Customizing link_to_remove_nested
* Link text
The default value is "X", but it can be changed using the parameter `link_text`

``` Ruby
link_to_remove_nested(form, link_text: "remove")
```
