class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :api_keys, dependent: :destroy

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :email, uniqueness: true

  def self.login?(access_token)
    api_key = ApiKey.find_by_access_token(access_token)
    return false if !api_key || !api_key.before_expired? || !api_key.active
    !find(api_key.user_id).nil?
  end

  def activate
    return ApiKey.create(user_id: id) unless api_key
    api_key.set_active unless api_key.active
    api_key.set_expiration unless api_key.before_expired?
    api_key.save
    api_key
  end

  def inactivate
    api_key.active = false
    api_key.save
  end

  private

  def api_key
    @api_key ||= ApiKey.find_by_user_id(id)
  end
end
