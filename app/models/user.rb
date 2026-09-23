class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    validates :name, presence: true

  has_many :chores, dependent: :destroy
  has_many :chore_list_entries, dependent: :destroy
  has_many :chore_records, dependent: :destroy
end
