class Permission < ActiveRecord::Base
  belongs_to :service
  belongs_to :item_type

  validates :write, inclusion: { in: [true, false] }

  validates :item_type, :service, presence: true
  validates :item_type, uniqueness: { scope: :service }
end
