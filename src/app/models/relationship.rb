class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"    # user.follower が使える
  belongs_to :followed, class_name: "User"
  validates :followed_id, presence: true
  validates :follower_id, presence: true
end
