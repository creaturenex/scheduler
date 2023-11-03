# frozen_string_literal: true

ActiveAdmin.register ShiftSurvey do
  before_filter do
    ShiftSurvey.class_eval do
      def to_param
        id.to_s
      end
    end
  end

  config.sort_order = 'id_asc'

  # :nocov:
  form do |f|
    f.semantic_errors
    inputs 'Details' do
      input :status, as: :select, collection: %w(Incomplete Complete)
    end
    f.actions
  end
  index do
    id_column
    column 'User' do |shift_survey|
      shift_survey.user.name
    end
    column :status
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row 'Shift Survey ID', &:id
      row 'Survey Status', &:status
      row 'Questions' do
        table_for shift_survey do
          column 'Did you have adequate supplies to care for the child(ren) during your time at the office?',
                 &:supplies
          column 'Comments', &:supplies_text
        end
        table_for shift_survey do
          column 'Did the assigned social worker respond to questions or concerns in a timely manner?',
                 &:response_time
          column 'Comments', &:response_time_text
        end
        table_for shift_survey do
          column 'Did the hours you signed up for match the hours you volunteered?', &:hours_match
          column 'Comments', &:hours_match_text
        end
        table_for shift_survey do
          column 'How are you feeling after your shift at the child welfare office? (check all that apply)' do |s|
            s.ratings.nil? ? nil : JSON.parse(s.ratings)
          end
          column 'Comments', &:ratings_text
        end
        table_for shift_survey do
          column 'Your feedback is important to us, and we love hearing from our volunteers! Do you have any comments or kudos you’d like to pass along?',
                 &:comments
        end
        table_for shift_survey do
          column 'Any questions for your Volunteer Coordinator?', &:questions
        end
      end

      row :created_at
      row :updated_at
    end
  end

  sidebar 'Shift Details', only: :show do
    attributes_table_for shift_survey do
      row :date do |shift_survey|
        shift_survey.need.start_at.strftime('%A, %B %d, %Y')
      end
      row :shifts do
        table_for shift_survey.need.shifts.where(user_id: shift_survey.user_id) do
          column 'Shift Duration(s)', &:duration_in_words
        end
      end
      row 'Children' do |shift_survey|
        shift_survey.need.number_of_children
      end
      row 'Volunteer' do |shift_survey|
        shift_survey.need.user.name
      end
    end
  end
  # :nocov:

  menu priority: 9
end
