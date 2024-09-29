# frozen_string_literal: true

require 'rails_helper'
require 'rubocop'

RSpec.describe PlayersController do
  let(:team) { create(:team) }

  it 'has no nested method definitions' do
    result = RuboCop::CLI.new.run(['--only', 'Style/NestedMethodDefinition', 'app/controllers'])
    expect(result).to eq(0), 'Rubocop detected nested method definitions in controllers.'
  end

  it 'defines required actions' do
    expect(described_class.instance_methods(false)).to match_array %i[index show new edit create update
                                                                      destroy]
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { team_id: team }
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index, params: { team_id: team }
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let!(:player) { create(:player) }

    it 'returns a success response' do
      get :show, params: { id: player, team_id: player.team }
      expect(response).to be_successful
    end

    it 'renders the show template' do
      get :show, params: { id: player, team_id: player.team }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { team_id: team }
      expect(response).to be_successful
    end

    it 'renders the new template' do
      get :new, params: { team_id: team }
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let!(:player) { create(:player) }

    it 'returns a success response' do
      get :edit, params: { id: player, team_id: player.team }
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      get :edit, params: { id: player, team_id: player.team }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Player' do
        expect do
          post :create, params: { player: attributes_for(:player), team_id: team }
        end.to change(Player, :count).by(1)
      end

      it 'redirects to the created player' do
        post :create, params: { player: attributes_for(:player), team_id: team }
        expect(response).to redirect_to(team_players_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Player' do
        expect do
          post :create, params: { player: attributes_for(:player, first_name: nil), team_id: team }
        end.not_to change(Player, :count)
      end

      it 're-renders the new template' do
        post :create, params: { player: attributes_for(:player, first_name: nil), team_id: team }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:player) { create(:player, team:) }

    context 'with valid parameters' do
      it 'updates the requested player' do
        patch :update, params: { id: player, player: { first_name: 'New Name' }, team_id: team }
        player.reload
        expect(player.first_name).to eq('New Name')
      end

      it 'redirects to the player' do
        patch :update, params: { id: player, player: attributes_for(:player), team_id: team }
        expect(response).to redirect_to(team_player_url(team, player))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the player' do
        original_first_name = player.first_name
        patch :update, params: { id: player, player: { first_name: nil }, team_id: team }
        player.reload
        expect(player.first_name).to eq(original_first_name)
      end

      it 're-renders the edit template' do
        patch :update, params: { id: player, player: { first_name: nil }, team_id: team }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:player) { create(:player) }

    it 'destroys the requested player' do
      expect do
        delete :destroy, params: { id: player, team_id: player.team }
      end.to change(Player, :count).by(-1)
    end

    it 'redirects to the players list' do
      delete :destroy, params: { id: player, team_id: player.team }
      expect(response).to redirect_to(team_players_url)
    end
  end
end
