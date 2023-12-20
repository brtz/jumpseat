# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :lockable,
         :recoverable, :rememberable, :validatable

  self.implicit_order_column = :email

  validates :email, uniqueness: true
  validates :first_name, length: { in: 2..20 }
  validates :middle_name, length: { in: 0..20 }
  validates :last_name, length: { in: 2..20 }

  # associations
  belongs_to :tenant, optional: true, counter_cache: true
  has_many :reservations, dependent: :destroy

  encrypts :first_name
  encrypts :middle_name
  encrypts :last_name
end
