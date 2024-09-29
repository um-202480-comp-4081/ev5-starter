# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routes follow resource naming' do
  context 'when routing' do
    specify 'Teams index' do
      expect(get: teams_path).to route_to 'teams#index'
    end

    specify 'Teams show' do
      expect(get: team_path(1)).to route_to controller: 'teams', action: 'show', id: '1'
    end

    specify 'Teams new' do
      expect(get: new_team_path).to route_to 'teams#new'
    end

    specify 'Teams create' do
      expect(post: teams_path).to route_to 'teams#create'
    end

    specify 'Teams edit' do
      expect(get: edit_team_path(1)).to route_to controller: 'teams', action: 'edit', id: '1'
    end

    specify 'Teams update' do
      expect(patch: team_path(1)).to route_to controller: 'teams', action: 'update', id: '1'
    end

    specify 'Teams destroy' do
      expect(delete: team_path(1)).to route_to controller: 'teams', action: 'destroy', id: '1'
    end

    specify 'Players index' do
      expect(get: team_players_path(1)).to route_to 'players#index', team_id: '1'
    end

    specify 'Players show' do
      expect(get: team_player_path(1, 2)).to route_to controller: 'players', action: 'show', team_id: '1', id: '2'
    end

    specify 'Players new' do
      expect(get: new_team_player_path(1)).to route_to 'players#new', team_id: '1'
    end

    specify 'Players create' do
      expect(post: team_players_path(1)).to route_to 'players#create', team_id: '1'
    end

    specify 'Players edit' do
      expect(get: edit_team_player_path(1, 2)).to route_to controller: 'players', action: 'edit', team_id: '1', id: '2'
    end

    specify 'Players update' do
      expect(patch: team_player_path(1, 2)).to route_to controller: 'players', action: 'update', team_id: '1', id: '2'
    end

    specify 'Players destroy' do
      expect(delete: team_player_path(1, 2)).to route_to controller: 'players', action: 'destroy', team_id: '1', id: '2'
    end
  end

  context 'when creating path helpers' do
    specify 'teams_path' do
      expect(teams_path).to eq '/teams'
    end

    specify 'team_path' do
      expect(team_path(1)).to eq '/teams/1'
    end

    specify 'new_team_path' do
      expect(new_team_path).to eq '/teams/new'
    end

    specify 'edit_team_path' do
      expect(edit_team_path(1)).to eq '/teams/1/edit'
    end

    specify 'team_players_path' do
      expect(team_players_path(1)).to eq '/teams/1/players'
    end

    specify 'team_player_path' do
      expect(team_player_path(1, 2)).to eq '/teams/1/players/2'
    end

    specify 'new_team_player_path' do
      expect(new_team_player_path(1)).to eq '/teams/1/players/new'
    end

    specify 'edit_team_player_path' do
      expect(edit_team_player_path(1, 2)).to eq '/teams/1/players/2/edit'
    end
  end
end
