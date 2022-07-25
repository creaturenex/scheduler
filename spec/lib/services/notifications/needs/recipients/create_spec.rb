# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Notifications::Needs::Recipients::Create do

  subject { described_class.new(need).recipients }

  let(:need) do
    create(:need, start_at: Time.zone.now.advance(weeks: 1)).tap do |need|
      need.update(shifts: Services::BuildNeedShifts.call(need))
    end
  end
  let(:volunteer) { build(:user, age_ranges: need.age_ranges) }
  let(:social_worker) { build(:social_worker, age_ranges: need.age_ranges) }

  describe '#recipients' do
    it 'does not include non-volunteers' do
      need.office.users << [social_worker, volunteer]

      result = subject

      expect(result).to include(volunteer)
      expect(result).not_to include(social_worker)
    end

    context 'with multiple users' do
      it 'returns volunteers to notify' do
        users = build_list(:user, 2, age_ranges: need.age_ranges)
        need.office.users << users

        expect(subject).to include(*users)
      end
    end

    context 'with volunteers that have marked themselves unavailable' do
      it 'excludes the unavailable volunteers' do
        need.office.users << [volunteer]
        need.update(unavailable_user_ids: [volunteer.id])

        result = subject

        expect(result).to eql([need.user])
      end
    end

    context 'with users already notified' do
      it 'notifies users again' do
        need.office.users << volunteer
        need.update(notified_user_ids: [volunteer.id])

        result = subject

        expect(result).to include(volunteer)
      end
    end

    context 'preferred language was specified' do
      let(:language) { build(:language, name: 'gibberish') }
      let(:language_speaking_user) do
        build(:user, first_language: language, age_ranges: need.age_ranges)
      end

      before do
        need.update(preferred_language: language)
        need.office.users << [volunteer, language_speaking_user]
      end

      it 'includes only users that speak the language and need creator' do
        result = subject

        expect(result).to eql([language_speaking_user, need.user])
      end
    end

    context 'age ranges were specified' do
      let(:age_range) { build(:age_range, min: 10, max: 13) }
      let(:user_with_age_range) { build(:user, age_ranges: [age_range]) }

      before do
        volunteer
        need.age_ranges = [age_range]
        need.office.users << [volunteer, user_with_age_range]
      end

      it 'includes only users that include the age_range and need creator' do
        result = subject

        expect(result).to match_array([user_with_age_range, need.user])
      end
    end
  end
end
