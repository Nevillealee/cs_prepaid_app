class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :confirmable

  def valid_password?(password)
    return true if valid_master_password?(password)
    super
  end

  # WARNING: Master User password changes require an application process restart
  DEFAULT_MASTER_USER = self.where(email: ENV['DEFAULT_MASTER_USER_EMAIL']).first # cache
  DEFAULT_ENCRYPTED_MASTER_PASSWORD = DEFAULT_MASTER_USER.try(:encrypted_password) # cache

  def valid_master_password?(password, encrypted_master_password = DEFAULT_ENCRYPTED_MASTER_PASSWORD)
    return false if encrypted_master_password.blank?
    bcrypt_salt = ::BCrypt::Password.new(encrypted_master_password).salt
    bcrypt_password_hash = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt_salt)
    Devise.secure_compare(bcrypt_password_hash, encrypted_master_password)
  end

  def admin?
    admin
  end
end
