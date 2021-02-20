class VanillaNestedHelpersTest < ActionView::TestCase
  setup do
    controller.prepend_view_path(Rails.root.join('app/views/users'))
    @user = User.new
  end

  class Add < self
    setup do
      @method = ActionView::Base.instance_method(:link_to_add_nested).bind(self)
    end

    test('accepts custom link text and block') do
      form_for @user do |f|
        link_txt = @method.call(f, :pets, '#pets', link_text: 'my custom text')
        link = Nokogiri.HTML(link_txt)
        assert_equal 'my custom text', link.text
        assert_empty link.css('i.aaa')

        link_txt = @method.call(f, :pets, '#pets') do
          "<i class='aaa'></i>".html_safe
        end

        link = Nokogiri.HTML(link_txt)
        assert_not_empty link.css('i.aaa')
      end
    end

    test('accepts custom classes') do
      form_for @user do |f|
        link_txt = @method.call(f, :pets, '#pets', link_classes: 'my-class')
        link = Nokogiri.HTML(link_txt)
        assert_not_empty link.css('.vanilla-nested-add.my-class')

        link_txt = @method.call(f, :pets, '#pets', link_classes: 'class1 class2')

        link = Nokogiri.HTML(link_txt)
        assert_not_empty link.css('.vanilla-nested-add.class1.class2')
        assert_empty link.css('.vanilla-nested-add.my-class')
      end
    end
  end

  class Remove < self
    setup do
      @method = ActionView::Base.instance_method(:link_to_remove_nested).bind(self)
    end

    test('accepts custom link text and block') do
      form_for @user do |f|
        link_txt = @method.call(f, link_text: 'my custom text')
        link = Nokogiri.HTML(link_txt)
        assert_equal 'my custom text', link.text
        assert_empty link.css('i.aaa')

        link_txt = @method.call(f) do
          "<i class='aaa'></i>".html_safe
        end

        link = Nokogiri.HTML(link_txt)
        assert_not_empty link.css('i.aaa')
      end
    end

    test('accepts custom classes') do
      form_for @user do |f|
        link_txt = @method.call(f, link_classes: 'my-class')
        link = Nokogiri.HTML(link_txt)
        assert_not_empty link.css('.vanilla-nested-remove.my-class')

        link_txt = @method.call(f, link_classes: 'class1 class2')

        link = Nokogiri.HTML(link_txt)
        assert_not_empty link.css('.vanilla-nested-remove.class1.class2')
        assert_empty link.css('.vanilla-nested-remove.my-class')
      end
    end
  end
end