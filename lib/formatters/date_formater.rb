module Formatters
  class DateFormater
    class << self
      # returns -> Aug 22, 2022 @ 07:11PM
      def format_with_time(date)
        date = Time.parse(date) if date.is_a?(String)
        date&.strftime('%b %d, %Y @ %I:%M%p')
      end
    end
  end
end
