# spec/requests/tips_show_today_spec.rb
require "rails_helper"

RSpec.describe "Tips#show_today", type: :request do
  it "day_of_month に一致する TIP を返す" do
    tip = create(:tip, day_of_month: 15)

    travel_to Date.new(2025, 1, 15) do
      get "/today"
      expect(response.body).to include(tip.title)
    end
  end

  it "見つからない場合フォールバックで返す" do
    fallback = create(:tip)  # day_of_month 不一致
    travel_to Date.new(2025, 1, 20) do
      get "/today"
      expect(response.body).to include(fallback.title)
    end
  end
end
