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
- `link_to_add_nested` expects the form builder, the name of the association and the selector of the container where the gem will insert the new fields

# Customizing link_to_add_nested
#### Link text
The default value is `Add <name of the associated model>`, but it can be changed using the parameter `link_text`:

``` Ruby
link_to_add_nested(form, :order_items, '#order-items', link_text: I18n.t(:some_key))
```
This way you can, for example, internationalize the text.

#### Link class
By default, the link to add new fields has the class `vanilla-nested-add` which is required, but you can add more classes passing a string:
``` Ruby
link_to_add_nested(form, :order_items, '#order-items', link_classes: 'btn btn-primary')
```
This way you can style the link with no need of targeting the specific vanilla nested class.

#### Insert position
By default, new fields are appended to the container, you can chage that with the `insert_method` option. For now, only `:append` and `:prepend` are supported:
``` Ruby
link_to_add_nested(form, :order_items, '#order-items', insert_method: :prepend)
```

#### Partial name
The default partial's name is infered using the association's class name. If your Order has_many :order_items and the class of those items is OrderItem, then the infered name is `order_item_fields`. You can use any partial name you like, though:
``` Ruby
link_to_add_nested(form, :order_items, '#order-items', partial: 'my_partial')
```

#### Form variable used in the partial
`link_to_add_nested` needs to render an empty template in order to later append/prepend it. To do that, it passes the form as a local variable. If your partial uses `form`, you don't have to do anything, but if you using another variable name, just customize it here.

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
#### Link text
The default value is "X", but it can be changed using the parameter `link_text`:

``` Ruby
link_to_remove_nested(form, link_text: "remove")
```

#### Fields wrapper
By default, the link to remove the fields assumes it's a direct child of the wrapper of the fields. You can customize this if you can't make it a direct child.

``` HTML+ERB
# orders/_order_item_fields.html.erb
<div class="wrapper-div">
  <fieldset>
    <%= ff.text_field :attr1 %>
    <%= ff.select :attr2 ..... %>
  </fieldset>
  <span><%= link_to_remove_nested(ff, fields_wrapper_selector: 'wrapper-div') # if we don't set this, it will only hide the span %></span>
</div>
```
Note that:
* The link MUST be a descendant of the fields wrapper, it may not be a direct child, but the look up of the wrapper uses javascript's `closest()` method, so it looks on the ancestors.
* Since this uses javascript's `closest()`, there is no IE supported (https://caniuse.com/#search=closest). You may want to add a polyfill or define the method manually if you need to support it.

#### Undoing
You can tell the plugin to add an "undo" link right after removing the fields (as a direct child of the fields wrapper! this is not customizable!).

```link_to_remove_nested(ff, undo_link_timeout: 2000, undo_link_text: I18n.t('undo_remove_fields'), undo_link_classes: 'btn btn-secondary')```

Options are:
* undo_link_timeout: miliseconds, greater than 0 to turn the feature on, default: `nil`
* undo_link_text: string with the text of the link, great for internationalization, default: `'Undo'`
* undo_link_classes: space separated string, default: `''`

# Events
There are some events that you can listen to add custom callbacks on different moments. All events bubbles up the dom, so you can listen for them on any ancestor.

#### 'vanilla-nested:fields-added'
Triggered right after the fields wrapper was inserted on the container.

```
  document.addEventListener('vanilla-nested:fields-added', function(e){
    // e.type == 'vanilla-nested:fields-added'
    // e.target == container div of the fields
    // e.detail.triggerdBy == the "add" link
    // e.detail.added == the fields wrapper just inserted
  })
```

#### 'vanilla-nested:fields-removed'
Triggered when the fields wrapper if fully hidden (aka ""removed""), that is: after clicking the "remove" link with no timeout OR after the timeout finished.

```
  document.addEventListener('vanilla-nested:fields-added', function(e){
    // e.type == 'vanilla-nested:fields-removed'
    // e.target == fields wrapper ""removed""
    // e.detail.triggerdBy == the "remove" link if no undo action, the 'undo' link if it was triggered by the timeout })
```

#### 'vanilla-nested:fields-hidden'
Triggered when the fields wrapper if hidden with an undo option.

```
  document.addEventListener('vanilla-nested:fields-hidden', function(e){
    // e.type == 'vanilla-nested:fields-hidden'
    // e.target == fields wrapper hidden
    // e.detail.triggerdBy == the "remove" link
  })
```

> **Remove vs Hidden**
>
> Behind the scene, the wrapper is never actually removed, because we need to send the `[_destroy]` parameter. But there are 2 different stages when removing it.
> * If there's no "undo" action configured, the wrapped is set to `display: none` and considered "removed".
> * If you use the "undo" feature, first the children of the wrapper are hidden (triggering the `hidden` event) and then, after the timeout passes, the wrapper is set to `display: none` (triggering the `removed` event).

#### 'vanila-nested:fields-hidden-undo'
Triggered when the user undo the removal using the "undo" link.

```
  document.addEventListener('vanilla-nested:fields-hidden-undo', function(e){
    // e.type == 'vanilla-nested:fields-hidden'
    // e.target == fields wrapper unhidden
    // e.detail.triggerdBy == the "undo" link
  })
```
