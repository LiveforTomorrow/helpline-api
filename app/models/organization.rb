# frozen_string_literal: true

class Organization < ApplicationRecord
  acts_as_taggable_on :human_support_types, :issues, :categories
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :opening_hours, dependent: :destroy
  validates :name, presence: true
  validates :country_code, presence: true, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  validates :chat_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
end