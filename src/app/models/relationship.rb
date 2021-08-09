class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"    # active_relationship.follower が使える
  belongs_to :followed, class_name: "User"    # active_relationship.followed	フォローを受けているユーザーを返します
  validates :followed_id, presence: true
  validates :follower_id, presence: true
end
