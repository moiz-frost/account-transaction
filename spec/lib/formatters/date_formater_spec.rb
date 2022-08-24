require 'rails_helper'

RSpec.describe Formatters::DateFormater, type: :lib do
  describe 'Date Format Methods' do
    it 'should return formatted date time' do
      date_time = Time.parse('Mon, 10 Jan 2022 22:46:51 PST -08:00')
      expect(Formatters::DateFormater.format_with_time(date_time)).to eq('Jan 10, 2022 @ 10:46PM')
    end
  end
end
