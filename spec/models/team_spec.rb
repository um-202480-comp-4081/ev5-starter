# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  home_city  :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Team do
  it 'has seeds' do
    load Rails.root.join('db/seeds.rb').to_s

    expect(described_class.count).to eq 3
    expect(described_class.order(:name).pluck(:name, :home_city))
      .to eq [['Duke University', 'Durham, NC'], ['Michigan State University', 'East Lansing, MI'],
              ['University of Memphis', 'Memphis, TN']]
  end
end
