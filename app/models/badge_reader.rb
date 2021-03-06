# == Schema Information
#
# Table name: badge_readers
#
#  id                            :bigint           not null, primary key
#  api_token                     :string
#  api_token_regenerated_at      :datetime
#  description                   :text
#  last_manual_open_at           :datetime
#  last_manual_open_requested_at :datetime
#  name                          :string
#  restricted_access             :boolean          default(FALSE), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class BadgeReader < ApplicationRecord
  API_TOKEN_LENGTH = 40

  has_paper_trail skip: [:api_token]

  has_many :badge_reader_certifications
  has_many :badge_reader_manual_users
  has_many :badge_scans

  has_many :certifications, through: :badge_reader_certifications
  has_many :manual_users, through: :badge_reader_manual_users, source: :user

  has_many :badge_access_grants
  has_many :badge_access_grant_users, through: :badge_access_grants, source: :user

  # Give every badge reader an API token on creation
  after_initialize do
    generate_api_token if new_record?
  end

  # Don't allow a restricted access badge reader to have any certifications
  before_save do
    self.certification_ids = [] if restricted_access?
  end

  def regenerate_api_token!
    generate_api_token
    save!

    # Disconnect any active websocket connections by this badge reader
    after_transaction_commit do
      ActionCable.server.remote_connections.where(client_resource: self).disconnect
    end
  end

  def generate_api_token
    self.api_token = SecureRandom.hex(API_TOKEN_LENGTH / 2) # because SecureRandom.hex expects a number of bytes, not characters
    self.api_token_regenerated_at = Time.now
  end

  def request_manual_open!
    update!(last_manual_open_requested_at: Time.now)

    after_transaction_commit do
      BadgeReaderChannel.broadcast_to(self, { type: 'manual_open_request' })
    end
  end

  def report_manually_opened!
    reload

    # Set last_manual_open_at to the max of the current time and
    # last_manual_open_requested_at to ensure backward clock skew on one server
    # doesn't cause us to report an open time that's less than an open request
    # that was served by another server (which would cause the frontend to
    # think that this open report is for a past open request and continue to
    # show the request as pending)
    update!(last_manual_open_at: [Time.now, last_manual_open_requested_at].max)
  end
end
