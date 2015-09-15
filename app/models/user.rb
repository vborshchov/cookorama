class User < ActiveRecord::Base
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { minimum: 3, maximum: 20 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, email: true
  validates :password, length: { minimum: 5 }

  has_secure_password
end
