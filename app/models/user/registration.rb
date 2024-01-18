# == Schema Information
#
# Table name: user_registrations
#
#  id                   :bigint           not null, primary key
#  user_id              :bigint           not null
#  email                :string           not null
#  confirmation_token   :string
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  unconfirmed_email    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_user_registrations_on_email    (email) UNIQUE
#  index_user_registrations_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class User::Registration < ApplicationRecord
  belongs_to :user
  devise :confirmable

  def self.new_with_session(params, session)
    new(
      unconfirmed_email: params[:email],
    )
  end
end
