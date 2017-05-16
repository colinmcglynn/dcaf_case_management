require 'csv'

# Methods pertaining to patient export
module Exportable
  extend ActiveSupport::Concern

  CSV_EXPORT_FIELDS = {
    "BSON ID" => :id,
    "Identifier" => :identifier,
    "Has Alt Contact?" => :has_alt_contact?,
    "Voicemail Preference" => :voicemail_preference,
    "Line" => :line,
    "Spanish?" => :spanish,
    "Age" => :age,
    "State" => :state,
    "County" => :county,
    "Race/Ethnicity" => :race_ethnicity,
    "Employment Status" => :employment_status,
    "Minors in Household" => :household_size_children,
    "Adults in Household" => :household_size_adults,
    "Insurance" => :insurance,
    "Income" => :income,
    "Referred By" => :referred_by,
    "Appointment Date" => :appointment_date,
    "Initial Call Date" => :initial_call_date,
    "Urgent?" => :urgent_flag,
    "Special Circumstances" => :special_circumstances 
  }

  def has_alt_contact?
    other_contact.present? || other_phone.present? || other_contact_relationship.present?
  end

  def get_field_value_for_serialization(field)
    value = public_send(field)
    if value.is_a?(Array)
      # Use simpler serialization for Array values than the default (`to_s`)
      value.reject(&:blank?).join(', ')
    else
      value
    end
  end

  class_methods do
    def to_csv
      CSV.generate(encoding: 'utf-8') do |csv|
        csv << CSV_EXPORT_FIELDS.keys # Header line
        all.each do |patient|
          csv << CSV_EXPORT_FIELDS.values.map do |field|
             patient.get_field_value_for_serialization(field)
          end
        end
      end
    end
  end
end
