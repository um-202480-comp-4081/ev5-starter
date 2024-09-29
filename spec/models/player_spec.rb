# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id         :bigint           not null, primary key
#  first_name :string
#  last_name  :string
#  position   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint           not null
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
require 'rails_helper'

RSpec.describe Player do
  it 'has seeds' do
    load Rails.root.join('db/seeds.rb').to_s

    expect(described_class.count).to eq 9

    team_ids = Team.pluck(:id)
    expect(described_class.order(:last_name).pluck(:first_name, :last_name, :position, :team_id))
      .to eq [['Jayden', 'Hardaway', 'G', team_ids[0]],
              ['Aaron', 'Henry', 'F', team_ids[2]],
              ['D.J.', 'Jeffries', 'F', team_ids[0]],
              ['Jalen', 'Johnson', 'F', team_ids[1]],
              ['Joshua', 'Langford', 'G', team_ids[2]],
              ['Alex', 'Lomax', 'G', team_ids[0]],
              ['Wendell', 'Moore, Jr.', 'F', team_ids[1]],
              ['DJ', 'Steward', 'G', team_ids[1]],
              ['Rocket', 'Watts', 'G', team_ids[2]]]
  end
end
