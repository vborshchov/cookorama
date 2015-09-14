class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, email: true
end
