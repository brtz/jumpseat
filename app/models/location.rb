# frozen_string_literal: true

class Location < ApplicationRecord
  self.implicit_order_column = :name

  scope :limit_tenant, ->(tenant) { where("tenant_id = ?", tenant.id) }

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  validates :street, length: { in: 2..30 }
  validates :house_number, length: { in: 0..10 }
  validates :zip_code, length: { in: 2..10 }
  validates :city, length: { in: 2..30 }
  validates :state, length: { in: 2..20 }
  validates :country, length: { in: 2..20 }

  # associations
  belongs_to :tenant
  has_many :floors, dependent: :destroy
  has_many :limitations, as: :limitable

  encrypts :street
  encrypts :house_number
  encrypts :zip_code
  encrypts :city
  encrypts :state
  encrypts :country
end
