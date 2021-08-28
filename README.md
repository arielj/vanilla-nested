# vanilla-nested

Rails dynamic nested forms using vanilla JS

Similar to cocoon, but with no jquery dependency!

# Installation

Just add it to your gemfile

```ruby
gem 'vanilla_nested'
# or gem 'vanilla_nested', github: 'arielj/vanilla-nested'
```

If you are using Sprockets, just require the js

```
//= require vanilla_nested
```

If you use Webpacker, add the package also (gem is required for the helper methods) using:

```sh
yarn add arielj/vanilla-nested
```

And then use it in your application.js as:

```js
import "vanilla-nested";
```

# Update

To update the gem use either:

```
gem update vanilla_nested # if using the gem from RubyGems

# or

gem update --source vanilla_nested # if using the gem from github
```

If using webpacker, you need to update the node package too with:

```
yarn upgrade vanilla-nested
```

> You can clear the webpacker cache just in case if changes are not reflecting with `rails webpacker:clobber`

# Usage

```HTML+ERB
# orders/_order_item_fields.html.erb
<div class="wrapper-div">
  <%= form.text_field :attr1 %>
  <%= form.select :attr2 ..... %>
  <%= link_to_remove_nested(form) # adds a link to remove the element %>
</div>
```

```HTML+ERB
# order/form.html.erb
<%= form_for product do |form| %>
  <%= form.text_field :attr %>

  <%= link_to_add_nested(form, :order_items, '#order-items') # adds a link to add more items %>
  <div id='order-items'>
    <%= form.fields_for :order_items do |order_item_f| %>
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

```Ruby
link_to_add_nested(form, :order_items, '#order-items', link_text: I18n.t(:some_key))
```

This way you can, for example, internationalize the text.

#### Link classes

By default, the link to add new fields has the class `vanilla-nested-add` which is required, but you can add more classes passing a string:

```Ruby
link_to_add_nested(form, :order_items, '#order-items', link_classes: 'btn btn-primary')
```

This way you can style the link with no need of targeting the specific vanilla nested class.

#### Insert position

By default, new fields are appended to the container, you can change that with the `insert_method` option. For now, only `:append` and `:prepend` are supported:

```Ruby
link_to_add_nested(form, :order_items, '#order-items', insert_method: :prepend)
```

#### Partial name

The default partial's name is inferred using the association's class name. If your Order has_many :order_items and the class of those items is OrderItem, then the inferred name is `order_item_fields`. You can use any partial name you like, though:

```Ruby
link_to_add_nested(form, :order_items, '#order-items', partial: 'my_partial')
```

#### Form variable used in the partial

`link_to_add_nested` needs to render an empty template in order to later append/prepend it. To do that, it passes the form as a local variable. If your partial uses `form`, you don't have to do anything, but if you using another variable name, just customize it here.

```HTML+ERB
# orders/_order_item_fields.html.erb
<div class="wrapper-div">
  <%= ff.text_field :attr1 %>
  <%= ff.select :attr2 ..... %>
  <%= link_to_remove_nested(ff) # adds a link to remove the element %>
</div>
```

```Ruby
link_to_add_nested(form, :order_items, '#order-items', partial_form_variable: :ff)
```

#### Tag

The HTML tag that will be generated. An `<a>` tag by default.

```Ruby
link_to_add_nested(form, :order_items, '#order-items', tag: 'span')
```

#### Link content

If you need html content, you can use a block:

```erb
<%= link_to_add_nested(form, :order_items, '#order-items') do %>
  <i class='fa fa-plus'>
<% end %>
```

# Customizing link_to_remove_nested

#### Link text

The default value is `"X"`, but it can be changed using the parameter `link_text`:

```Ruby
link_to_remove_nested(form, link_text: "remove")
```

#### Link content

If you need html content, you can use a block:

```erb
<%= link_to_remove_nested(form) do %>
  <i class='fa fa-trash'>
<% end %>
```

#### Link classes

By default, the link to remove fields has the class `vanilla-nested-remove` which is required, but you can add more classes passing a space separated string:

```Ruby
link_to_remove_nested(form, link_classes: 'btn btn-primary')
```

This way you can style the link with no need of targeting the specific vanilla nested class.

#### Fields wrapper

By default, the link to remove the fields assumes it's a direct child of the wrapper of the fields. You can customize this if you can't make it a direct child.

```HTML+ERB
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

- The link MUST be a descendant of the fields wrapper, it may not be a direct child, but the look up of the wrapper uses JavaScript's `closest()` method, so it looks on the ancestors.
- Since this uses JavaScript's `closest()`, there is no IE supported (https://caniuse.com/#search=closest). You may want to add a polyfill or define the method manually if you need to support it.

#### Tag

The HTML tag that will be generated. An `<a>` tag by default.

```Ruby
link_to_remove_nested(ff, tag: 'p')
```

#### Undoing

You can tell the plugin to add an "undo" link right after removing the fields (as a direct child of the fields wrapper! this is not customizable!).

```Ruby
link_to_remove_nested(ff, undo_link_timeout: 2000, undo_link_text: I18n.t('undo_remove_fields'), undo_link_classes: 'btn btn-secondary')
```

Options are:

- `undo_link_timeout`: milliseconds, greater than 0 to turn the feature on, default: `nil`
- `undo_link_text`: string with the text of the link, great for internationalization, default: `'Undo'`
- `undo_link_classes`: space separated string, default: `''`

# Events

There are some events that you can listen to add custom callbacks on different moments. All events bubbles up the dom, so you can listen for them on any ancestor.

#### 'vanilla-nested:fields-added'

Triggered right after the fields wrapper was inserted on the container.

```Javascript
  document.addEventListener('vanilla-nested:fields-added', function(e){
    // e.type == 'vanilla-nested:fields-added'
    // e.target == container div of the fields
    // e.detail.triggeredBy == the "add" link
    // e.detail.added == the fields wrapper just inserted
  })
```

#### 'vanilla-nested:fields-limit-reached'

Triggered right after the fields wrapper was inserted on the container if the current count is >= limit, where limit is the value configured on the model: `accepts_nested_attributes_for :assoc, limit: 5`. You can listen to this event to disable the "add" link for example, or to show a warning.

```Javascript
  document.addEventListener('vanilla-nested:fields-limit-reached', function(e){
    // e.type == 'vanilla-nested:fields-added'
    // e.target == container div of the fields
    // e.detail.triggeredBy == the "add" link
  })
```

#### 'vanilla-nested:fields-removed'

Triggered when the fields wrapper if fully hidden (aka ""removed""), that is: after clicking the "remove" link with no timeout OR after the timeout finished.

```Javascript
  document.addEventListener('vanilla-nested:fields-removed', function(e){
    // e.type == 'vanilla-nested:fields-removed'
    // e.target == fields wrapper ""removed""
    // e.detail.triggeredBy == the "remove" link if no undo action, the 'undo' link if it was triggered by the timeout })
```

#### 'vanilla-nested:fields-hidden'

Triggered when the fields wrapper if hidden with an undo option.

```Javascript
  document.addEventListener('vanilla-nested:fields-hidden', function(e){
    // e.type == 'vanilla-nested:fields-hidden'
    // e.target == fields wrapper hidden
    // e.detail.triggeredBy == the "remove" link
  })
```

> **Remove vs Hidden**
>
> Behind the scene, the wrapper is never actually removed, because we need to send the `[_destroy]` parameter. But there are 2 different stages when removing it.
>
> - If there's no "undo" action configured, the wrapped is set to `display: none` and considered "removed".
> - If you use the "undo" feature, first the children of the wrapper are hidden (triggering the `hidden` event) and then, after the timeout passes, the wrapper is set to `display: none` (triggering the `removed` event).

#### 'vanilla-nested:fields-hidden-undo'

Triggered when the user undo the removal using the "undo" link.

```Javascript
  document.addEventListener('vanilla-nested:fields-hidden-undo', function(e){
    // e.type == 'vanilla-nested:fields-hidden-undo'
    // e.target == fields wrapper unhidden
    // e.detail.triggeredBy == the "undo" link
  })
```

## Using Webpacker

For now, if you want to use this with webpacker, download the vanilla_nested.js file, put in inside `app/javascript` folder and import it on your `application.js` using `import '../vanilla_nested.js'`.

## Testing

You can run the tests following these commands:

- cd test/VanillaNestedTests # move to the rails app dir
- bin/setup # install bundler, gems and yarn packages
- rails test # unit tests
- rails test:system # system tests

> If you make changes in the JS files, you have to tell yarn to refresh the code inside the node_modules folder running `yarn upgrade vanilla-nested`, then clear webpacker cache with `rails webpacker:clobber`, and then restart the rails server or re-run the tests.

# Changes from 1.0.0 to 1.1.0

#### Change the method to infere the name of the partial

Before, it used `SomeClass.name.downcase`, this created a problem for classes with more than one word:

- User => 'user_fields'
- SomeClass => 'someclass_fields'

Now it uses `SomeClass.name.underscore`:

- User => 'user_fields'
- SomeClass => 'some_class_fields'

If you used the old version, you'll need to change the partial name or provide the old name as the `partial:` argument.

#### Fix some RuboCop style suggestions

Mostly single/double quotes, spacing, etc.

#### Added some Solagraph related doc for the view helpers

Just so Solargraph plugins on editors like VS-Code can give you some documentation.

#### Added some documentation on the code

Mostly on the javascript code

#### Added node module config

So it can be used as a node module using yarn to integrate it using webpacker.

# Changes from 1.1.0 to 1.2.0

#### New event for the "limit" option of `accepts_nested_attributes_for`

You can listen to the `vanilla-nested:fields-limit-reached` event that will fire when container has more or equals the amount of children than the `limit` option set on the `accepts_nested_attributes_for` configuration.

# Changes from 1.2.0 to 1.2.1

#### Removed "onclick" attribute for helpers and add event listeners within js

If you were using webpacker, remember to replace the vanilla_nested.js file in your app/javascript folder

# Changes from 1.2.1 to 1.2.2

#### Added "link_classes" option to "link_to_remove_nested"

You can set multiple classes for the "X" link

#### Added a "link_content" block parameter for both link helpers

You can pass a block to use as the content for the add and remove links

# Changes from 1.2.2 to 1.2.3

#### Fix using nested html elements as the content for buttons

There was an error when using the helpers with things like:

```erb
<%= link_to_add_nested(form, :pets, '#pets') do %>
  <span>Add Pet</span>
<% end %>
```

It would detect the wrong element for the click event, making the JS fail.

# Changes from 1.2.3 to 1.2.4

Play nicely with Turbolinks' `turbolinks:load` event.

# Changes from 1.2.4 to 1.2.5

License change from GPL to MIT

# Changes for next release:

- Custom generated HTML element tag
- Extra class added to dynamically added fields

> Remember to update both gem and package https://github.com/arielj/vanilla-nested/tree/master#update
