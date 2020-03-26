# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization::CsvImportService, type: :service do
  let(:valid_organization_csv) { file_fixture('services/organization/csv_import_service/valid_organization.csv') }

  describe '.import' do
    let(:organization) { Organization.first }
    let(:attributes) do
      {
        'name' => 'Youthline',
        'country_code' => 'NZ',
        'region' => 'Auckland',
        'phone_word' => '0800 YOUTHLINE',
        'phone_number' => '0800 376 633',
        'sms_word' => 'WORD',
        'sms_number' => '234',
        'chat_url' => 'https://www.youthline.co.nz/web-chat-counselling.html',
        'url' => 'https://www.youthline.co.nz',
        'slug' => 'youthline',
        'notes' => 'no notes needed',
        'timezone' => 'Auckland'
      }
    end

    it 'creates organization' do
      expect { described_class.import(valid_organization_csv) }.to change(Organization, :count).by(1)
    end

    it 'has the correct attributes' do
      described_class.import(valid_organization_csv)
      expect(organization.attributes).to include(attributes)
    end

    it 'has the correct human_support_type_list' do
      described_class.import(valid_organization_csv)
      expect(organization.human_support_type_list).to match_array ['Volunteers', 'Paid Staff']
    end

    it 'has the correct issue_list' do
      described_class.import(valid_organization_csv)
      expect(organization.issue_list).to match_array %w[Anxiety Bullying]
    end

    it 'has the correct category_list' do
      described_class.import(valid_organization_csv)
      expect(organization.category_list).to match_array ['All issues', 'For youth']
    end

    context 'when organization already exists' do
      let!(:organization) { create(:organization, name: 'Youthline', country_code: 'NZ') }

      it 'does not create organization' do
        expect { described_class.import(valid_organization_csv) }.not_to change(Organization, :count)
      end

      it 'has the correct attributes' do
        described_class.import(valid_organization_csv)
        expect(organization.reload.attributes).to include(attributes)
      end
    end
  end
end
