class User < ActiveRecord::Base
  before_save { self.email = email.downcase }

  validates :email, presence: true, uniqueness: true, email: true
end
