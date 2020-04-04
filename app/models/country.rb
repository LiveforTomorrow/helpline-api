# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :organizations, dependent: :destroy
  has_many :subdivisions, dependent: :destroy
  validates :code, presence: true, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, uniqueness: true
  delegate :name, to: :iso_3166_country

  def code=(code)
    super(code&.upcase)
  end

  def iso_3166_country
    ISO3166::Country.new(code)
  end
end
