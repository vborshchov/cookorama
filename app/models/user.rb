class User < ActiveRecord::Base
  before_save { self.email = email.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false }, email: true
end
