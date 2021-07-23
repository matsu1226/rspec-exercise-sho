module UsersHelper
  # 与えられたユーザーのGravatar (http://gravatar.com/) を返す。
  def gravatar_for(user, options = {size: 50})
    # GravatarのURLはMD5を用いてuserのemailをハッシュ化している
    # Rubyでは、Digestライブラリのhexdigest methodを使用したMD5ハッシュアルゴリズムが実装されている
    # (https://docs.ruby-lang.org/ja/latest/class/Digest=3a=3aBase.html)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url  = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
