module ApplicationHelper  
  # Railsでは自動的にヘルパーモジュールを読み込んでくれる=>includeをわざわざ書く必要がない。
  # カスタムヘルパー
  # ページごとの完全なタイトルを返します。
  def full_title(page_title = '')   # オプション引数('')も設定
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title                    # 暗黙の戻り値
    else
      page_title + " | " + base_title
    end
  end
end
