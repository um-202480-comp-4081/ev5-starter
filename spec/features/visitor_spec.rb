# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Visitor Features' do
  feature 'Browse Teams' do
    let!(:team_one) do
      create(:team, name: 'Peacocks', home_city: 'Dallas')
    end
    let!(:team_two) do
      create(:team, name: 'Rocs', home_city: 'Mobile')
    end

    scenario 'Viewing the team index page content' do
      visit teams_path

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Teams')
        within('table') do
          within('thead') do
            within('tr') do
              expect(page).to have_css('th', text: 'Name')
              expect(page).to have_css('th', text: 'Home City')
              expect(page).to have_css('th', exact_text: '', count: 1)
            end
          end
          within('tbody') do
            expect(page).to have_css('tr', count: 2)

            within('tr:nth-child(1)') do
              expect(page).to have_css('td', text: team_one.name)
              expect(page).to have_css('td', text: team_one.home_city)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end

            within('tr:nth-child(2)') do
              expect(page).to have_css('td', text: team_two.name)
              expect(page).to have_css('td', text: team_two.home_city)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end
          end
        end
        expect(page).to have_link('New Team')
      end
    end

    scenario 'Redirecting from the root page to the players page' do
      visit root_path

      expect(page).to have_current_path(teams_path, ignore_query: true)
    end
  end

  feature 'View Team Details' do
    let!(:team_one) do
      create(:team, name: 'Peacocks', home_city: 'Dallas')
    end

    scenario 'Viewing a team show page content' do
      visit team_path(team_one)

      aggregate_failures do
        expect(page).to have_css('h1', text: team_one.name.to_s)
        expect(page).to have_css('p', text: "Home city: #{team_one.home_city}")
        expect(page).to have_link('Edit')
        expect(page).to have_link('Roster')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Navigating to a team show page from the index page' do
      visit teams_path

      click_on 'Show', match: :first

      expect(page).to have_current_path(team_path(team_one), ignore_query: true)
    end

    scenario 'Navigating back to the team index page from the show page' do
      visit team_path(team_one)
      click_on 'Back'

      expect(page).to have_current_path(teams_path, ignore_query: true)
    end
  end

  feature 'Create New Team' do
    scenario 'Viewing the new team form page' do
      visit new_team_path

      aggregate_failures do
        expect(page).to have_css('h1', text: 'New Team')
        expect(page).to have_field('Name')
        expect(page).to have_field('Home city')
        expect(page).to have_button('Create Team')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Creating a new team with valid details' do
      visit new_team_path

      fill_in 'Name', with: 'New Team'
      fill_in 'Home city', with: 'New City'
      click_on 'Create Team'

      expect(Team.last).to have_attributes(name: 'New Team', home_city: 'New City')
      expect(page).to have_current_path(teams_path, ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Team was successfully created.')
      expect(page).to have_css('tbody tr', count: 1)
    end

    scenario 'Creating a new team with missing name', :js do
      visit new_team_path

      fill_in 'Home city', with: 'New City'
      click_on 'Create Team'

      expect(Team.count).to eq(0) # No new team should be created
      message = page.find_by_id('team_name').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Creating a new team with missing home city', :js do
      visit new_team_path

      fill_in 'Name', with: 'New Name'
      click_on 'Create Team'

      expect(Team.count).to eq(0) # No new team should be created
      message = page.find_by_id('team_home_city').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Navigating to the new team page from the index page' do
      visit teams_path

      click_on 'New Team'

      expect(page).to have_current_path(new_team_path, ignore_query: true)
    end

    scenario 'Navigating back to the team index page from the new team page' do
      visit new_team_path

      click_on 'Back'

      expect(page).to have_current_path(teams_path, ignore_query: true)
    end
  end

  feature 'Edit Team' do
    let!(:team) do
      create(:team, name: 'Peacocks', home_city: 'Dallas')
    end

    scenario 'Viewing the edit team form page' do
      visit edit_team_path(team)

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Edit Team')
        expect(page).to have_field('Name', with: team.name)
        expect(page).to have_field('Home city', with: team.home_city)
        expect(page).to have_button('Update Team')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Updating a team with valid details' do
      visit edit_team_path(team)

      expect do
        fill_in 'Name', with: 'Updated Team'
        fill_in 'Home city', with: 'Updated City'
        click_on 'Update Team'
      end.not_to change(Team, :count)

      team.reload
      expect(team).to have_attributes(name: 'Updated Team', home_city: 'Updated City')
      expect(page).to have_current_path(team_path(team), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Team was successfully updated.')
    end

    scenario 'Updating a team with missing name', :js do
      visit edit_team_path(team)

      fill_in 'Name', with: ''
      click_on 'Update Team'

      team.reload
      expect(team.name).to eq('Peacocks') # Team should not be updated
      message = page.find_by_id('team_name').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Updating a team with missing home city', :js do
      visit edit_team_path(team)

      fill_in 'Home city', with: ''
      click_on 'Update Team'

      team.reload
      expect(team.home_city).to eq('Dallas') # Team should not be updated
      message = page.find_by_id('team_home_city').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Navigating to a team edit page from the index page' do
      visit teams_path

      click_on 'Edit', match: :first

      expect(page).to have_current_path(edit_team_path(team), ignore_query: true)
    end

    scenario 'Navigating to a team edit page from the show page' do
      visit team_path(team)

      click_on 'Edit'

      expect(page).to have_current_path(edit_team_path(team), ignore_query: true)
    end

    scenario 'Navigating back to the team index page from the edit page' do
      visit edit_team_path(team)

      click_on 'Back'

      expect(page).to have_current_path(teams_path, ignore_query: true)
    end
  end

  feature 'Destroy Team' do
    let!(:team) { create(:team) }

    scenario 'Deleting an team from the index page' do
      visit teams_path

      expect(page).to have_content(team.name)
      expect do
        click_on 'Delete', match: :first
      end.to change(Team, :count).by(-1)

      expect(page).to have_current_path(teams_path, ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Team was successfully destroyed.')
      expect(page).to have_no_content(team.name)
    end
  end

  feature 'Browse Players' do
    let(:team) { Team.create!(name: 'Peacocks', home_city: 'Dallas') }
    let!(:player_one) do
      create(:player, first_name: 'Bob', last_name: 'Jones', position: 'G', team:)
    end
    let!(:player_two) do
      create(:player, first_name: 'Sam', last_name: 'Evans', position: 'F', team:)
    end

    scenario 'Viewing the player index page content' do
      visit team_players_path(team)

      aggregate_failures do
        expect(page).to have_css('h1', text: "#{team.name} Roster")
        within('table') do
          within('thead') do
            within('tr') do
              expect(page).to have_css('th', text: 'First Name')
              expect(page).to have_css('th', text: 'Last Name')
              expect(page).to have_css('th', text: 'Position')
              expect(page).to have_css('th', exact_text: '', count: 1)
            end
          end
          within('tbody') do
            expect(page).to have_css('tr', count: 2)

            within('tr:nth-child(1)') do
              expect(page).to have_css('td', text: player_one.first_name)
              expect(page).to have_css('td', text: player_one.last_name)
              expect(page).to have_css('td', text: player_one.position)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end

            within('tr:nth-child(2)') do
              expect(page).to have_css('td', text: player_two.first_name)
              expect(page).to have_css('td', text: player_two.last_name)
              expect(page).to have_css('td', text: player_two.position)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end
          end
        end
        expect(page).to have_link('New Player')
        expect(page).to have_link('Back to Team')
      end
    end

    scenario 'Navigating to the player index page from the team show page' do
      visit team_path(team)

      click_on 'Roster'

      expect(page).to have_current_path(team_players_path(team), ignore_query: true)
    end

    scenario 'Navigating back to the team show page from the player index page' do
      visit team_players_path(team)

      click_on 'Back to Team'

      expect(page).to have_current_path(team_path(team), ignore_query: true)
    end
  end

  feature 'View Player Details' do
    let(:team) { Team.create!(name: 'Peacocks', home_city: 'Dallas') }
    let!(:player_one) do
      create(:player, first_name: 'Bob', last_name: 'Jones', position: 'G', team:)
    end

    scenario 'Viewing a player show page content' do
      visit team_player_path(team, player_one)

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Bob Jones')
        expect(page).to have_css('p', text: "Position: #{player_one.position}")
        expect(page).to have_link('Back')
      end
    end

    scenario 'Navigating to a player show page from the index page' do
      visit team_players_path(team)

      click_on 'Show', match: :first

      expect(page).to have_current_path(team_player_path(team, player_one), ignore_query: true)
    end

    scenario 'Navigating back to the player index page from the show page' do
      visit team_player_path(team, player_one)
      click_on 'Back'

      expect(page).to have_current_path(team_players_path(team), ignore_query: true)
    end
  end

  feature 'Create New Player' do
    let(:team) { Team.create!(name: 'Peacocks', home_city: 'Dallas') }

    scenario 'Viewing the new player form page' do
      visit new_team_player_path(team)

      aggregate_failures do
        expect(page).to have_css('h1', text: "New Player for #{team.name}")
        expect(page).to have_field('First name')
        expect(page).to have_field('Last name')
        expect(page).to have_field('Position')
        expect(page).to have_button('Create Player')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Creating a new player with valid details' do
      visit new_team_player_path(team)

      fill_in 'First name', with: 'New Player First'
      fill_in 'Last name', with: 'New Player Last'
      select 'G', from: 'Position'
      click_on 'Create Player'

      expect(Player.last).to have_attributes(first_name: 'New Player First', last_name: 'New Player Last',
                                             position: 'G')
      expect(page).to have_current_path(team_players_path(team), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Player was successfully created.')
      expect(page).to have_css('tbody tr', count: 1)
    end

    scenario 'Creating a new player with missing first name', :js do
      visit new_team_player_path(team)

      fill_in 'Last name', with: 'New Name Last'
      select 'G', from: 'Position'
      click_on 'Create Player'

      expect(Player.count).to eq(0) # No new player should be created
      message = page.find_by_id('player_first_name').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Creating a new player with missing last name', :js do
      visit new_team_player_path(team)

      fill_in 'First name', with: 'New Name First'
      select 'G', from: 'Position'
      click_on 'Create Player'

      expect(Player.count).to eq(0) # No new player should be created
      message = page.find_by_id('player_last_name').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Creating a new player with no position' do
      visit new_team_player_path(team)

      fill_in 'First name', with: 'New Name First'
      fill_in 'Last name', with: 'New Name Last'
      click_on 'Create Player'

      expect(Player.count).to eq(0) # No new player should be created
      expect(page).to have_css('.alert-danger', text: 'Error! Unable to create player.')
      expect(page).to have_content('Position G F is not included in the list', normalize_ws: true)
    end

    scenario 'Navigating to the new player page from the index page' do
      visit team_players_path(team)

      click_on 'New Player'

      expect(page).to have_current_path(new_team_player_path(team), ignore_query: true)
    end

    scenario 'Navigating back to the player index page from the new page' do
      visit new_team_player_path(team)

      click_on 'Back'

      expect(page).to have_current_path(team_players_path(team), ignore_query: true)
    end
  end

  feature 'Edit Player' do
    let(:team) { Team.create!(name: 'Peacocks', home_city: 'Dallas') }
    let!(:player) do
      create(:player, first_name: 'Bob', last_name: 'Jones', position: 'G', team:)
    end

    scenario 'Viewing the edit player form page' do
      visit edit_team_player_path(team, player)

      aggregate_failures do
        expect(page).to have_css('h1', text: "Edit Player for #{team.name}")
        expect(page).to have_field('First name', with: player.first_name)
        expect(page).to have_field('Last name', with: player.last_name)
        expect(page).to have_field('Position', with: player.position)
        expect(page).to have_button('Update Player')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Updating a player with valid details' do
      visit edit_team_player_path(team, player)

      fill_in 'First name', with: 'Updated Player First'
      fill_in 'Last name', with: 'Updated Player Last'
      select 'F', from: 'Position'
      click_on 'Update Player'

      player.reload
      expect(player).to have_attributes(first_name: 'Updated Player First', last_name: 'Updated Player Last',
                                        position: 'F')
      expect(page).to have_current_path(team_player_path(team, player), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Player was successfully updated.')
    end

    scenario 'Updating a player with missing first name', :js do
      visit edit_team_player_path(team, player)

      fill_in 'First name', with: ''
      click_on 'Update Player'

      player.reload
      expect(player.first_name).to eq('Bob') # Player should not be updated
      message = page.find_by_id('player_first_name').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Updating a player with missing last name', :js do
      visit edit_team_player_path(team, player)

      fill_in 'Last name', with: ''
      click_on 'Update Player'

      player.reload
      expect(player.last_name).to eq('Jones') # Player should not be updated
      message = page.find_by_id('player_last_name').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Updating a player with no position' do
      visit edit_team_player_path(team, player)

      select '', from: 'Position'
      click_on 'Update Player'

      player.reload
      expect(player.position).to eq('G') # Player should not be updated
      expect(page).to have_css('.alert-danger', text: 'Error! Unable to update player.')
      expect(page).to have_content('Position G F is not included in the list', normalize_ws: true)
    end

    scenario 'Navigating to a player edit page from the index page' do
      visit team_players_path(team)

      click_on 'Edit', match: :first

      expect(page).to have_current_path(edit_team_player_path(team, player), ignore_query: true)
    end

    scenario 'Navigating back to the player index page from the edit page' do
      visit edit_team_player_path(team, player)

      click_on 'Back'

      expect(page).to have_current_path(team_players_path(team), ignore_query: true)
    end
  end

  feature 'Destroy Player' do
    let(:team) { Team.create!(name: 'Peacocks', home_city: 'Dallas') }
    let!(:player) do
      create(:player, first_name: 'Bob', last_name: 'Jones', position: 'G', team:)
    end

    scenario 'Deleting a player from the index page' do
      visit team_players_path(team)

      expect(page).to have_content(player.first_name)
      expect do
        click_on 'Delete', match: :first
      end.to change(Player, :count).by(-1)

      expect(page).to have_current_path(team_players_path(team), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Player was successfully destroyed.')
      expect(page).to have_no_content(player.first_name)
    end
  end
end
