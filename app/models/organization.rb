# frozen_string_literal: true

class Organization < ApplicationRecord
  include Filterable
  acts_as_taggable_on :human_support_types, :topics, :categories
  extend FriendlyId
  friendly_id :name, use: :slugged
  belongs_to :country
  has_many :opening_hours, dependent: :destroy
  has_many :subdivision_connections, dependent: :destroy
  has_many :subdivisions, through: :subdivision_connections, class_name: 'Country::Subdivision'
  validates :name, presence: true, uniqueness: { scope: :country_id }
  validates :remote_id, uniqueness: true, allow_nil: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  validates :chat_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }, presence: true
  accepts_nested_attributes_for :opening_hours, allow_destroy: true
  scope :filter_by_country_code, ->(code) { joins(:country).where(countries: { code: code.upcase }) }
  scope :filter_by_subdivision_codes, lambda { |codes|
    if codes.empty?
      left_outer_joins(:subdivisions).where(country_subdivisions: { id: nil })
    else
      joins(:subdivisions).where(country_subdivisions: { code: codes.map(&:upcase) })
    end
  }
  scope :filter_by_categories, ->(tags) { tagged_with(tags, on: :categories) }
  scope :filter_by_human_support_types, ->(tags) { tagged_with(tags, on: :human_support_types) }
  scope :filter_by_topics, ->(tags) { tagged_with(tags, on: :topics) }

  def should_generate_new_friendly_id?
    name_changed?
  end

  def remote_id=(remote_id)
    super remote_id.presence
  end
end
