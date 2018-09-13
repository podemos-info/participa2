# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Extends Decidim's Form builder to add a form input for campaigns.
    class ::Decidim::FormBuilder
      include ::ActionView::Helpers::FormTagHelper
      include ::ActionView::Helpers::NumberHelper

      def amount_selector(name, html_options)
        output = "".html_safe
        amounts = html_options.delete(:amounts)

        amounts.each do |amount|
          output.concat(input_amount_for(name, amount))
        end
        output.concat(input_other_amounts(name, amounts))
        output.concat(amount_input_tag(name, html_options))
        output.concat(error_and_help_text(name))
        output
      end

      private

      def input_other_amounts(name, amounts)
        amount = object.send(name)
        checked = amount.present? && !amounts.include?(amount)

        content_tag :label, for: "#{name}_selector_other" do
          concat radio_button_tag "#{name}_selector".to_sym, "other", checked
          concat amount_label(I18n.t("support_tag.other", scope: "decidim.form_builder"))
        end
      end

      def input_amount_for(name, amount)
        checked = object.send(name) == amount

        content_tag :label, for: "#{name}_selector_#{amount}" do
          concat radio_button_tag "#{name}_selector".to_sym, amount, checked
          concat amount_label(amount)
        end
      end

      def amount_label(amount)
        content_tag :div do
          if amount.is_a? Integer
            number_to_currency(amount,
                               unit: Decidim.currency_unit,
                               precision: 0,
                               format: "%n %u")
          else
            amount
          end
        end
      end

      def amount_input_tag(name, html_options)
        minimum = html_options.delete(:minimum)
        label = options.delete(:label)
        label_options = options.delete(:label_options)
        content_tag :div, class: "field" do
          custom_label(name, label, label_options) do
            @template.number_field(
              @object_name,
              name,
              html_options.merge(min: minimum, step: 5)
            )
          end
        end
      end
    end
  end
end
