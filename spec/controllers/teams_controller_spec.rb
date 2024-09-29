# frozen_string_literal: true

require 'rails_helper'
require 'rubocop'

RSpec.describe TeamsController do
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
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let!(:team) { create(:team) }

    it 'returns a success response' do
      get :show, params: { id: team }
      expect(response).to be_successful
    end

    it 'renders the show template' do
      get :show, params: { id: team }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let!(:team) { create(:team) }

    it 'returns a success response' do
      get :edit, params: { id: team }
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      get :edit, params: { id: team }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Team' do
        expect do
          post :create, params: { team: attributes_for(:team) }
        end.to change(Team, :count).by(1)
      end

      it 'redirects to the created team' do
        post :create, params: { team: attributes_for(:team) }
        expect(response).to redirect_to(teams_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Team' do
        expect do
          post :create, params: { team: attributes_for(:team, name: nil) }
        end.not_to change(Team, :count)
      end

      it 're-renders the new template' do
        post :create, params: { team: attributes_for(:team, name: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:team) { create(:team) }

    context 'with valid parameters' do
      it 'updates the requested team' do
        patch :update, params: { id: team, team: { name: 'New Name' } }
        team.reload
        expect(team.name).to eq('New Name')
      end

      it 'redirects to the team' do
        patch :update, params: { id: team, team: attributes_for(:team) }
        expect(response).to redirect_to(team)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the team' do
        original_name = team.name
        patch :update, params: { id: team, team: { name: nil } }
        team.reload
        expect(team.name).to eq(original_name)
      end

      it 're-renders the edit template' do
        patch :update, params: { id: team, team: { name: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:team) { create(:team) }

    it 'destroys the requested team' do
      expect do
        delete :destroy, params: { id: team }
      end.to change(Team, :count).by(-1)
    end

    it 'redirects to the teams list' do
      delete :destroy, params: { id: team }
      expect(response).to redirect_to(teams_url)
    end
  end
end
