# app/helpers/application_helper.rb
module ApplicationHelper
  # 既存のコードがあれば残す

  # フッタータブ共通パーツを生成するヘルパー
  def footer_tab(label, path, icon_name, active)
    classes = active ? "text-accentBlue" : "text-textSecondary"
    link_to path, class: "flex flex-col items-center #{classes}" do
      concat lucide_icon(icon_name, class: "w-6 h-6")
      concat content_tag(:span, label, class: "text-label-sm")
    end
  end
end
