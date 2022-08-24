module FormattableCurrency
  extend ActiveSupport::Concern

  class_methods do
    # simple helper method that can be used in other models as well
    def formats_money(*attributes)
      attributes.each do |attribute|
        define_method("formatted_#{attribute}") do
          send(attribute.to_s).format
        end
      end
    end
  end
end
