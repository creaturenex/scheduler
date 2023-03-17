# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Notifications::Shifts::Message::Destroy do

  let(:object) { described_class.new(shift, event_data) }
  let(:event_data) { {} }
  let(:shift) { create(:shift, start_at: starts, duration: 120) }
  let(:starts) { Time.zone.parse('2019-05-23 11:15:00 PDT -07:00') }

  describe '#message' do
    it 'returns expected string' do
      result = object.message

      expect(result).to eql('The shift from 11:15am to 01:15pm has been '\
                              'removed from a need at your local office. '\
                              'http://localhost:3000/needs')
    end
  end
end
